clear variables; close all; clc; addpath('../'); rng(1); delete(gcp('nocreate')); 

% SBCEXP17 12:30 J88

%% set general parameters

freqsNoise = (190:20:590)';
freqsTones = [53; 103; 203; 253; 303; 403; 503; 703; 953];
freqsTonesUpper = [303; 403; 503; 703; 953];

scenario.freqs = freqsTonesUpper;
scenario.maxModes = 50;
scenario.receiverDepths = [14.0000;17.7500;21.5000;25.2500;29.0000;32.7500;36.5000;40.2500;44.0000;47.7500;51.5000;55.2500;59.0000;62.7500;66.5000;70.2500];
scenario.likelihoodConstantSNR = 10;
scenario.modelMode = 'L2HM1N';
scenario.templateName = '88';

sourceRange = 1857.4;
sourceDepth = 44.3;   

tilt = 0;
waterDepth = 75;

speedTop1 = 1445;
density1 = 1.612;
attenuation1 = 0.04;
speedBottom1 = 1500;
thickness1 = 9;

speedTop2 = 1500;
density2 = 1.7;
attenuation2 = 0.15;
speedBottom2 = 1750;
thickness2 = 1.3;

scenario.knownState = [sourceRange;sourceDepth;tilt;waterDepth;speedTop1;density1;attenuation1;speedBottom1;thickness1;speedTop2;density2;attenuation2;speedBottom2;thickness2];      % this is the the order of parameters we use all the time
numParameters = size(scenario.knownState,1);

scenario.isKnown = false(numParameters,1);
scenario.isKnown(13) = true;

%scenario.coupling = [10,8];
scenario.coupling = zeros(0,2);

%% load data

load('data1FirstWAcousticSnapshots')
scenario.snapshotIndex = 4;
dataMatrixes = dataMatrixHighTones(:,:,5:9,scenario.snapshotIndex);


%% perform inversion

% general parameters
numParameters = numel(scenario.isKnown);
numParametersUnkown = sum(~scenario.isKnown) - size(scenario.coupling,1);
numAcceptanceDimensionInit = 5*numParametersUnkown;
numSamples = 70000;

% parameters for parallel tempering
temperatureFactor = 1.25;   %multiplicative increase in temperature
numTemperatures = 10;
tempering.temperatures = temperatureFactor.^(0:numTemperatures-1)';
tempering.isSwap = true;
parpool('local',numTemperatures);

% mcmc parameters
mcmc.scalingFactor = (2.4)^2/numParametersUnkown;
mcmc.regularizationFactor = 1e-7;
mcmc.priorScaling = 1/5;
mcmc.isFastInit = false;

% define prior
scenario.prior.sourceRange = [1500;2100];
scenario.prior.sourceDepth = [30;60];
scenario.prior.tilt = [-3;3];
scenario.prior.waterDepths = [73;78];

scenario.prior.topSpeed1 = [1400;1750];
scenario.prior.density1 = [1.00;2.50];
scenario.prior.attenuation1 = [0;0.5];
scenario.prior.bottomSpeed1 = [1400;1750];
scenario.prior.thickness1 = [5;15];

scenario.prior.topSpeed2 = [1400;1750];
scenario.prior.density2 = [1.00;2.50];
scenario.prior.attenuation2 = [0;0.5];
scenario.prior.bottomSpeed2 = [1400;1750];
scenario.prior.thickness2 = [.5;4];

scenario.priorMean = nan(numParameters,1);
%scenario.priorMean(7) = .1;
%scenario.priorMean(12) = .2;

scenario.priorStds = inf(numParameters,1);
scenario.priorStds(1) = 100;
%scenario.priorStds(7) = .05;
%scenario.priorStds(12) = .05;


% initialize prior and initial proposal distribution
[scenario.priorMean,priorCovariance,priorRotation,priorVariances] = getPriorCovariance(scenario,mcmc);

% initialize covariance matrix
sampleMean = nan(numParameters,numTemperatures);
sampleCorrelation = nan(numParameters,numParameters,numTemperatures);
numSamplesCovariance = 5*numParametersUnkown*ones(numTemperatures,1);

% initialize covariance matrix used as a proposal distribution; the method based on sampling us slower but typically more accurate
proposalCovariances = zeros(numParameters,numParameters,numTemperatures,numSamples);
if(mcmc.isFastInit)
    [proposalCovariances(:,:,:,1),proposalRotations,proposalVariances] = getCovariancesDifferences(scenario,tempering.temperatures,mcmc);
else
    [proposalCovariances(:,:,:,1),proposalRotations,proposalVariances] = getCovariancesSampling(priorRotation,priorVariances,dataMatrixes,scenario,numAcceptanceDimensionInit,tempering.temperatures,mcmc);
end




% initialize first sample and proposal
samples = zeros(numParameters,numTemperatures,numSamples);
logPriors = zeros(numTemperatures,numSamples);
logLikelihoods = zeros(numTemperatures,numSamples);
isAccepted = false(numTemperatures,numSamples);
swapIndexes = nan(2,numTemperatures,numSamples);
samples(:,:,1) = repmat(scenario.priorMean,[1,numTemperatures]);
isAccepted(:,1) = true;

modelledPressure = getPressuresFromStateSBCEXP17(samples(:,1,1),scenario,1);

for currentTemp = 1:numTemperatures
    logLikelihoods(currentTemp,1) = sum(evaluateLogLikelihood(modelledPressure,dataMatrixes,nan,scenario.likelihoodConstantSNR)) * 1/tempering.temperatures(currentTemp);
    logPriors(currentTemp,1) = evaluateLogPrior(scenario,samples(:,currentTemp,1)) * 1/tempering.temperatures(currentTemp);
end


% main inversion loop
tic
for currentIndex = 2:numSamples

    logLikelihoodsCurrent = logLikelihoods(:,currentIndex-1);
    samplesCurrent = permute(samples(:,:,1:currentIndex-1),[1,3,2]);
    logPriorsCurrent = logPriors(:,currentIndex-1);
    proposalCovariancesCurrent = proposalCovariances(:,:,:,currentIndex-1);
    acceptancePatterns = zeros(numParametersUnkown,numTemperatures);

    parfor currentTemp = 1:numTemperatures

        % define current order
        currentOrder = randperm(numParametersUnkown);

        % get proposal covariance
        [sampleMean(:,currentTemp),sampleCorrelation(:,:,currentTemp),proposalCovariances(:,:,currentTemp,currentIndex),proposalRotations(:,:,currentTemp),proposalVariances(:,currentTemp)] = getProposalCovariance(sampleMean(:,currentTemp),sampleCorrelation(:,:,currentTemp),proposalCovariancesCurrent(:,:,currentTemp),proposalRotations(:,:,currentTemp),proposalVariances(:,currentTemp),samplesCurrent(:,:,currentTemp),numSamplesCovariance(currentTemp),currentIndex-1,mcmc);

        % sample, compute likelihood, and accept/reject
        [samples(:,currentTemp,currentIndex),logLikelihoods(currentTemp,currentIndex),logPriors(currentTemp,currentIndex),acceptancePatterns(:,currentTemp)] = getNextSample(dataMatrixes,samplesCurrent(:,end,currentTemp),logLikelihoodsCurrent(currentTemp),logPriorsCurrent(currentTemp),proposalRotations(:,:,currentTemp),proposalVariances(:,currentTemp),currentOrder,[tempering.temperatures(currentTemp);currentTemp],scenario,currentIndex);
        isAccepted(currentTemp,currentIndex) = any(acceptancePatterns(:,currentTemp));
    end

    % plot diagnostic info for individual temperature
    printOutputStrings(samples(:,:,currentIndex),proposalCovariances(:,:,:,currentIndex),currentIndex,isAccepted,acceptancePatterns,tempering.temperatures,numSamplesCovariance,nan,scenario);

    % perform swaps and plot diagnostic info of swap
    [samples(:,:,currentIndex),logLikelihoods(:,currentIndex),logPriors(:,currentIndex),swapIndexes(:,:,currentIndex)] = performSwap(samples(:,:,currentIndex),logLikelihoods(:,currentIndex),logPriors(:,currentIndex),tempering,currentIndex);

    if( mod(currentIndex,10000) == 0 && currentIndex ~= numSamples )
        save('resultsDataTmp','samples','logLikelihoods','logPriors','proposalCovariances','isAccepted','swapIndexes','tempering','scenario','mcmc')
    end

end
toc

[sensitivityY,sensitivityX] = getSensitivitySBCEXP17(scenario.prior,scenario,25);

save('resultsData','samples','logLikelihoods','logPriors','proposalCovariances','isAccepted','swapIndexes','tempering','scenario','mcmc','sensitivityY','sensitivityX');