clear variables; close all; clc; rng(1); delete(gcp('nocreate'));

% SBCEXP22 shelf break, VLA1 (200 m contour): synthetic data, one sediment
% layer with gradients in speed, density, and attenuation over a halfspace

%% set general parameters

freqsTonesLF = [503; 653; 803; 1003; 1253];         % M71 tonals

scenario.freqs = freqsTonesLF;
scenario.hydrophoneHeights = 5.5 + 1.75 + 3.75*(0:15)';    % above the seafloor, hydrophone 1 first (trip report, Fig. B.3.3)
scenario.snrDb = 10;                                % SNR of the synthetic data in dB
scenario.likelihoodConstantSNR = 10^(scenario.snrDb/10) + 1;      % linear factor expected by evaluateLogLikelihood, i.e., E[trace(R)]/(numReceivers*noiseVariance)

% sound speed profile: downcast of CTD #20 (JD 148, 1828Z)
ctd = load('SBCEXP22_ssp_ctd020.mat');
[~,deepestIndex] = max(ctd.ctd_Depth);
[sspDepths,uniqueIndexes] = unique(ctd.ctd_Depth(1:deepestIndex));
scenario.ssp.depths = sspDepths(:);
scenario.ssp.speeds = ctd.ctd_ssp(uniqueIndexes);
scenario.ssp.speeds = scenario.ssp.speeds(:);
scenario.numSSPPoints = 500;

sourceRange = 2500;
sourceDepth = 120;
tilt = 1;
waterDepth = 200;

% sediment layer and halfspace of the MFP environment (shelf-break cores
% AC-18 to AC-23, Ballard et al., 2024, Fig. 13)
speedTop = 1550;
speedBottom = 1620;
densityTop = 1.60;
densityBottom = 1.80;
attenuationTop = 0.30;
attenuationBottom = 0.55;
thickness = 1.5;

speedH = 1650;
densityH = 1.85;
attenuationH = 0.65;

scenario.knownState = [sourceRange;sourceDepth;tilt;waterDepth;speedTop;speedBottom;densityTop;densityBottom;attenuationTop;attenuationBottom;thickness;speedH;densityH;attenuationH];      % this is the order of parameters we use all the time
numParameters = size(scenario.knownState,1);

scenario.isKnown = false(numParameters,1);

scenario.coupling = zeros(0,2);

%% compute fake data

SNR = scenario.snrDb;

truePressure = getPressuresFromStateSBCEXP22(scenario.knownState,scenario,1);

numReceivers = size(scenario.hydrophoneHeights,1);
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
parpool('local',min(numTemperatures,parcluster('local').NumWorkers));    % parfor spreads the temperatures over the available workers

% mcmc parameters
mcmc.scalingFactor = (2.4)^2/numParametersUnkown;
mcmc.regularizationFactor = 1e-7;
mcmc.priorScaling = 1/5;
mcmc.isFastInit = true;

% define prior (the order of the fields has to match the order of the state)
sourceRangeCenter = sourceRange;                    % from GPS or the MFP peak for real data
scenario.prior.sourceRange = sourceRangeCenter + [-500;500];
scenario.prior.sourceDepth = [100;140];             % tow depth ~120 m
scenario.prior.tilt = [-3;3];
scenario.prior.waterDepth = [195;205];

scenario.prior.speedTop = [1450;1750];
scenario.prior.speedBottom = [1450;1850];
scenario.prior.densityTop = [1.2;2.2];
scenario.prior.densityBottom = [1.2;2.2];
scenario.prior.attenuationTop = [0;1.0];
scenario.prior.attenuationBottom = [0;1.0];
scenario.prior.thickness = [0.5;5];

scenario.prior.speedH = [1550;1900];
scenario.prior.densityH = [1.5;2.3];
scenario.prior.attenuationH = [0;1.0];

scenario.priorMean = nan(numParameters,1);

scenario.priorStds = inf(numParameters,1);
scenario.priorStds(1) = 100;


% initialize prior and initial proposal distribution
[scenario.priorMean,priorCovariance,priorRotation,priorVariances] = getPriorCovariance(scenario,mcmc);


% initialize covariance matrix
sampleMean = nan(numParameters,numTemperatures);
sampleCorrelation = nan(numParameters,numParameters,numTemperatures);
numSamplesCovariance = numAcceptanceDimensionInit*ones(numTemperatures,1);

% initialize covariance matrix used as a proposal distribution; the method based on sampling us slower but typically more accurate
% current proposal covariances; a thinned history is kept to limit memory (entry i belongs to sample (i-1)*covarianceHistoryInterval+1)
proposalCovariances = zeros(numParameters,numParameters,numTemperatures);
covarianceHistoryInterval = 1000;
proposalCovarianceHistory = zeros(numParameters,numParameters,numTemperatures,floor((numSamples-1)/covarianceHistoryInterval)+1);
if(mcmc.isFastInit)
    [proposalCovariances,proposalRotations,proposalVariances] = getCovariancesDifferences(scenario,tempering.temperatures,mcmc);
else
    [proposalCovariances,proposalRotations,proposalVariances] = getCovariancesSampling(priorRotation,priorVariances,dataMatrixes,scenario,numAcceptanceDimensionInit,tempering.temperatures,mcmc);
end
proposalCovarianceHistory(:,:,:,1) = proposalCovariances;


% initialize first sample and proposal
samples = zeros(numParameters,numTemperatures,numSamples);
logPriors = zeros(numTemperatures,numSamples);
logLikelihoods = zeros(numTemperatures,numSamples);
isAccepted = false(numTemperatures,numSamples);
swapIndexes = nan(2,numTemperatures,numSamples);
samples(:,:,1) = repmat(scenario.priorMean,[1,numTemperatures]);
isAccepted(:,1) = true;

modelledPressure = getPressuresFromStateSBCEXP22(samples(:,1,1),scenario,1);

for currentTemp = 1:numTemperatures
    logLikelihoods(currentTemp,1) = sum(evaluateLogLikelihood(modelledPressure,dataMatrixes,nan,scenario.likelihoodConstantSNR)) * 1/tempering.temperatures(currentTemp);

    logPriors(currentTemp,1) = evaluateLogPrior(scenario,samples(:,currentTemp,1)) * 1/tempering.temperatures(currentTemp);
end


% main inversion loop
tic
for currentIndex = 2:numSamples

    logLikelihoodsCurrent = logLikelihoods(:,currentIndex-1);
    % pass only the samples getProposalCovariance needs: the initial block once, afterwards only the last sample
    if(any(currentIndex-1 == numSamplesCovariance))
        samplesCurrent = permute(samples(:,:,1:currentIndex-1),[1,3,2]);
    else
        samplesCurrent = permute(samples(:,:,currentIndex-1),[1,3,2]);
    end
    logPriorsCurrent = logPriors(:,currentIndex-1);
    proposalCovariancesCurrent = proposalCovariances;
    acceptancePatterns = zeros(numParametersUnkown,numTemperatures);

    parfor currentTemp = 1:numTemperatures

        % define current order
        currentOrder = randperm(numParametersUnkown);

        % get proposal covariance
        [sampleMean(:,currentTemp),sampleCorrelation(:,:,currentTemp),proposalCovariances(:,:,currentTemp),proposalRotations(:,:,currentTemp),proposalVariances(:,currentTemp)] = getProposalCovariance(sampleMean(:,currentTemp),sampleCorrelation(:,:,currentTemp),proposalCovariancesCurrent(:,:,currentTemp),proposalRotations(:,:,currentTemp),proposalVariances(:,currentTemp),samplesCurrent(:,:,currentTemp),numSamplesCovariance(currentTemp),currentIndex-1,mcmc);

        % sample, compute likelihood, and accept/reject
        [samples(:,currentTemp,currentIndex),logLikelihoods(currentTemp,currentIndex),logPriors(currentTemp,currentIndex),acceptancePatterns(:,currentTemp)] = getNextSample(dataMatrixes,samplesCurrent(:,end,currentTemp),logLikelihoodsCurrent(currentTemp),logPriorsCurrent(currentTemp),proposalRotations(:,:,currentTemp),proposalVariances(:,currentTemp),currentOrder,[tempering.temperatures(currentTemp);currentTemp],scenario,currentIndex);
        isAccepted(currentTemp,currentIndex) = any(acceptancePatterns(:,currentTemp));
    end

    % plot diagnostic info for individual temperature
    printOutputStrings(samples(:,:,currentIndex),proposalCovariances,currentIndex,isAccepted,acceptancePatterns,tempering.temperatures,numSamplesCovariance,nan,scenario);

    % perform swaps and plot diagnostic info of swap
    [samples(:,:,currentIndex),logLikelihoods(:,currentIndex),logPriors(:,currentIndex),swapIndexes(:,:,currentIndex)] = performSwap(samples(:,:,currentIndex),logLikelihoods(:,currentIndex),logPriors(:,currentIndex),tempering,currentIndex);

    if(mod(currentIndex-1,covarianceHistoryInterval) == 0)
        proposalCovarianceHistory(:,:,:,(currentIndex-1)/covarianceHistoryInterval+1) = proposalCovariances;
    end

    if( mod(currentIndex,10000) == 0 && currentIndex ~= numSamples )
        save('resultsTmp','samples','logLikelihoods','logPriors','proposalCovariances','proposalCovarianceHistory','covarianceHistoryInterval','isAccepted','swapIndexes','tempering','scenario','mcmc')
    end

end
toc

prior = scenario.prior;
[sensitivityY,sensitivityX] = getSensitivitySBCEXP22(prior,scenario,25);

save('results','samples','logLikelihoods','logPriors','proposalCovariances','proposalCovarianceHistory','covarianceHistoryInterval','isAccepted','swapIndexes','tempering','scenario','mcmc','sensitivityY','sensitivityX')
