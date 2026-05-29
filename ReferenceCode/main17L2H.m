clear variables; close all; clc; addpath('../'); rng(1); delete(gcp('nocreate'));

%% set general parameters

freqsNoise = (190:20:590)';
freqsSource = [53; 103; 203; 253; 303; 403; 503; 703; 953];

scenario.freqs = freqsSource;
% scenario.freqs = freqsNoise;
scenario.maxModes = 50;
scenario.receiverDepths = [14.0000;17.7500;21.5000;25.2500;29.0000;32.7500;36.5000;40.2500;44.0000;47.7500;51.5000;55.2500;59.0000;62.7500;66.5000;70.2500];
scenario.likelihoodConstantSNR = 5;
scenario.modelMode = 'L2HM1';
scenario.templateName = '88';

sourceRange = 2000;
sourceDepth = 45;
tilt = 1;
waterDepth = 75;

speedH = 1750;
densityH = 1.8;
attenuationH = 0.15;

speedTop1 = 1445;
density1 = 1.612;
attenuation1 = 0.04;
speedBottom1 = 1446;
thickness1 = 10.2;

speedTop2 = 1446;
density2 = 1.7;
attenuation2 = 0.15;
speedBottom2 = 1710;
thickness2 = 2;

scenario.knownState = [sourceRange;sourceDepth;tilt;waterDepth;speedH;densityH;attenuationH;speedTop1;density1;attenuation1;speedBottom1;thickness1;speedTop2;density2;attenuation2;speedBottom2;thickness2];      % this is the the order of parameters we use all the time
numParameters = size(scenario.knownState,1);

scenario.isKnown = false(numParameters,1);
scenario.isKnown(5:7) = true;

scenario.coupling = zeros(0,2);

%% compute fake data

SNR = scenario.likelihoodConstantSNR;

truePressure = getPressuresFromStateSBCEXP17(scenario.knownState,scenario,1);

numReceivers = size(scenario.receiverDepths,1);
numFreqs = size(scenario.freqs,1);
noiseVariances = zeros(numFreqs,1);
fakeData = zeros(numReceivers,numFreqs);
dataMatrixes = zeros(numReceivers,numReceivers,numFreqs);

for indexF = 1:numFreqs
    signalPower = sum(abs(truePressure(:,indexF)).^2)/numReceivers;
    noiseVariances(indexF)  = signalPower/(10^(SNR/10));
    noise = sqrt(noiseVariances(indexF)/2) * ( randn(numReceivers,1) + 1i*randn(numReceivers,1) );

    fakeData(:,indexF) = truePressure(:,indexF) + noise;

    dataMatrixes(:,:,indexF) = fakeData(:,indexF)*fakeData(:,indexF)';
end


%% perform inversion

% general parameters
numParameters = numel(scenario.isKnown);
numParametersUnkown = sum(~scenario.isKnown) - size(scenario.coupling,1);
numAcceptanceDimensionInit = 5*numParametersUnkown;
numSamples = 100000;

% parameters for parallel tempering
temperatureFactor = 2;   %multiplicative increase in temperature
numTemperatures = 4;
tempering.temperatures = temperatureFactor.^(0:numTemperatures-1)';
tempering.isSwap = true;
parpool('local',numTemperatures);

% mcmc parameters
mcmc.scalingFactor = (2.4)^2/numParametersUnkown;
mcmc.regularizationFactor = 1e-7;
mcmc.priorScaling = 1/5;
mcmc.isFastInit = true;

% define prior
scenario.prior.sourceRange = [1700;2300];
scenario.prior.sourceDepth = [30;60];
scenario.prior.tilt = [-3;3];
scenario.prior.waterDepths = [73;88];

scenario.prior.speedH = [1650;1900];
scenario.prior.densityH = [1.00;4.00];
scenario.prior.attenuationH = [0;0.3];

scenario.prior.topSpeed1 = [1400;1500];
scenario.prior.density1 = [1.00;2.00];
scenario.prior.attenuation1 = [0;0.1];
scenario.prior.bottomSpeed1 = [1400;1500];
scenario.prior.thickness1 = [5;15];

scenario.prior.topSpeed2 = [1400;1500];
scenario.prior.density2 = [1.00;2.00];
scenario.prior.attenuation2 = [0;0.2];
scenario.prior.bottomSpeed2 = [1600;1800];
scenario.prior.thickness2 = [.5;4];

scenario.priorMean = nan(numParameters,1);

scenario.priorStds = inf(numParameters,1);
scenario.priorStds(1) = 100;
scenario.priorStds(2) = 1;
% scenario.priorStds(7) = .05;
% scenario.priorStds(12) = .05;


% initialize prior and initial proposal distribution
[scenario.priorMean,priorCovariance,priorRotation,priorVariances] = getPriorCovariance(scenario,mcmc);


% initialize covariance matrix
sampleMean = nan(numParameters,numTemperatures);
sampleCorrelation = nan(numParameters,numParameters,numTemperatures);
numSamplesCovariance = numAcceptanceDimensionInit*ones(numTemperatures,1);

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
        save('resultsTmp','samples','logLikelihoods','logPriors','proposalCovariances','isAccepted','swapIndexes','tempering','scenario','mcmc')
    end

end
toc

prior = scenario.prior;
[sensitivityY,sensitivityX] = getSensitivitySBCEXP17(prior,scenario,25);

save('results','samples','logLikelihoods','logPriors','proposalCovariances','isAccepted','swapIndexes','tempering','scenario','mcmc','sensitivityY','sensitivityX')