clear variables; close all; clc; rng(1); delete(gcp('nocreate'));

% SBCEXP22 shelf break, VLA1 (200 m contour), source tow Track 8 (JD 147,
% 1929Z-0000Z): one sediment layer with gradients in speed, density, and
% attenuation over a halfspace. The data file, averaging window, sound speed
% profile, and GPS source range are those of MFP/MFP.m at 2100Z.
%
% Joint version of mainData14L1HContinuous.m: several averaging windows of the
% 2100Z file are inverted together with one environment, one source depth, and
% one tilt. The state holds the source range of the reference window; the range
% of every other window follows from the GPS range difference to the reference
% window (scenario.sourceRangeOffsets), so an error of the layback that is the
% same in all windows is still estimated. The remaining windows of the file are
% held out: checkHeldOutWindows.m evaluates the estimates on them. A change of
% the model counts as an improvement only if the fit of the held-out windows improves.
%
% The modes do not depend on the source range: each proposal still needs one
% KRAKEN run, as in the inversion of a single window.
%
% Seabed as in mainData14L1HContinuous.m: the speed at the bottom of the layer
% is equal to the speed of the halfspace (scenario.coupling). Unknown seabed
% parameters: speedTop, thickness, speedH.

%% set general parameters

freqsTonesLF = [503; 653; 803; 1003; 1253];         % M71 tonals

scenario.freqs = freqsTonesLF;
scenario.hydrophoneHeights = 5.5 + 1.75 + 3.75*(0:15)';    % above the seafloor, hydrophone 1 first (trip report, Fig. B.3.3)
scenario.likelihoodConstantSNR = nan;               % nan: unknown noise variance at each frequency, integrated out (evaluateLogLikelihood); a number is used as a fixed linear SNR factor (not dB)

% data folders and MFP functions (sound speed casts and source track)
dataFolder = fullfile(fileparts(mfilename('fullpath')),'..','..','Data','acoustic');
processedFolder = fullfile(fileparts(mfilename('fullpath')),'..','..','Data','processed');
addpath(fullfile(fileparts(mfilename('fullpath')),'..','MFP'));

% data: averaging windows of the 2100Z file, processed as in MFP.m
scenario.fileName = 'RAVA01.22147210000.sio';      % JD 147, 2100Z
data.samplingFrequency = 25000;
data.fftLength = 2^14;
data.toneFrequencies = scenario.freqs;
data.toneSearchHalfWidth = 3;                      % search for the Doppler-shifted tonal [Hz]
data.numHydrophones = numel(scenario.hydrophoneHeights);

scenario.windowIndexesFit = (1:2:11)';             % averaging windows used in the inversion, counted as in MFP.m (12 windows per file); the first one is the reference window
scenario.windowIndexesHeldOut = (2:2:12)';         % averaging windows not used in the inversion (checkHeldOutWindows.m)
numWindowsFile = 12;
numSnapshots = 15;                                 % snapshots per averaging window (MFP.m: 5 s averaging)
snapshotHop = data.fftLength/2/data.samplingFrequency;              % snapshots overlap by 50% [s]
scenario.windowStartsFile = ((1:numWindowsFile)'-1)*numSnapshots*snapshotHop;      % start of each averaging window of the file [s] since file start
scenario.windowStarts = scenario.windowStartsFile(scenario.windowIndexesFit);    % windows used in the inversion
scenario.windowStart = scenario.windowStarts(1);                    % reference window
scenario.windowDuration = (numSnapshots+1)*snapshotHop;             % averaging window [s]

% sound speed profile as in MFP.m: XBT #11 (JD 147, 2133Z, launched during the
% tow 3.4 km east of VLA1) with the salinity of CTD #16 (JD 147, 1312Z, at
% VLA1) in 1 m depth bins down to 200 m; in deeper water the deepest value is held
sspDepths = (0:1:200)';
[~,salinityCast] = readSoundSpeedCastMFP(processedFolder,'CTD',16,sspDepths);
scenario.ssp.depths = sspDepths;
scenario.ssp.speeds = readSoundSpeedCastMFP(processedFolder,'XBT',11,sspDepths,salinityCast.salinity);
scenario.numSSPPoints = 500;

% source range from the ship's GPS as in MFP.m: VLA1 position (trip report,
% Table 2), ship positions at the launches of XBT #9 to #11 (JD 147, 1932Z,
% 2033Z, 2133Z; App. D), and the source 180 m behind the ship along the track
vlaLatitude = 40.048467;                           % [deg]
vlaLongitude = -70.884167;                         % [deg]
trackXbtNumbers = (9:11)';
layback = 180;                                     % [m]
trackTimes = NaT(numel(trackXbtNumbers),1);
trackLatitudes = zeros(numel(trackXbtNumbers),1);
trackLongitudes = zeros(numel(trackXbtNumbers),1);
for xbtIndex = 1:numel(trackXbtNumbers)
    [~,xbtCast] = readSoundSpeedCastMFP(processedFolder,'XBT',trackXbtNumbers(xbtIndex),sspDepths,salinityCast.salinity);
    trackTimes(xbtIndex) = xbtCast.time;
    trackLatitudes(xbtIndex) = xbtCast.latitude;
    trackLongitudes(xbtIndex) = xbtCast.longitude;
end
timeValues = str2double(regexp(scenario.fileName,'\.(\d{2})(\d{3})(\d{2})(\d{2})(\d{2})\.sio$','tokens','once'));      % RAVA01.YYDDDHHMMSS.sio
fileStart = datetime(2000+timeValues(1),1,timeValues(2),timeValues(3),timeValues(4),timeValues(5));                 % UTC
windowTimes = fileStart + seconds(scenario.windowStartsFile + scenario.windowDuration/2);                           % centers of the averaging windows
scenario.sourceRangesGPSFile = getSourceTrackMFP(windowTimes,layback,trackTimes,trackLatitudes,trackLongitudes,vlaLatitude,vlaLongitude);     % all windows of the file
scenario.sourceRangeGPS = scenario.sourceRangesGPSFile(scenario.windowIndexesFit(1));                               % reference window
scenario.sourceRangeOffsets = scenario.sourceRangesGPSFile(scenario.windowIndexesFit) - scenario.sourceRangeGPS;    % GPS range of each window used in the inversion minus the GPS range of the reference window

% reference state used for comparison in the plots: MFP environment, GPS
% source range of the reference window, and depth of the MFP peak at 2100Z (nominal tow depth 120 m)
sourceRange = scenario.sourceRangeGPS;
sourceDepth = 125;
tilt = 0;
waterDepth = 200;

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
scenario.isKnown([7;8;9;10;13;14]) = true;          % densities and attenuations of the layer and the halfspace have limited sensitivity at this range (getSensitivitySBCEXP22); they are kept at their values in scenario.knownState

scenario.coupling = [6,12];                         % each row [a,b]: state entry a is set equal to state entry b; here speedBottom = speedH (no speed jump at the interface)

%% load data

% the data matrices of the windows are stacked along the third dimension (all tones
% of the first window, all tones of the second window, ...), as the columns of the
% modelled pressure (getPressuresFromStateSBCEXP22); the log-likelihood is the sum
% over all windows and tones, with an unknown noise variance for each of them
numFreqs = numel(scenario.freqs);
numWindows = numel(scenario.windowStarts);
dataMatrixes = zeros(data.numHydrophones,data.numHydrophones,numFreqs*numWindows);
scenario.selectedFrequencies = zeros(numFreqs,numWindows);
for windowIndex = 1:numWindows
    [dataMatrixes(:,:,(windowIndex-1)*numFreqs+(1:numFreqs)),scenario.selectedFrequencies(:,windowIndex)] = getDataMatrixesSBCEXP22(fullfile(dataFolder,scenario.fileName),scenario.windowStarts(windowIndex),scenario.windowDuration,data);
end


%% perform inversion

% general parameters
numParameters = numel(scenario.isKnown);
numParametersUnkown = sum(~scenario.isKnown) - size(scenario.coupling,1);
numAcceptanceDimensionInit = 5*numParametersUnkown;
numSamples = 30000;

% parameters for parallel tempering
temperatureFactor = 1.25;   %multiplicative increase in temperature
numTemperatures = 10;
tempering.temperatures = temperatureFactor.^(0:numTemperatures-1)';
tempering.isSwap = true;
parpool('local',min(numTemperatures,parcluster('local').NumWorkers));    % parfor spreads the temperatures over the available workers

% mcmc parameters
mcmc.scalingFactor = (2.4)^2/numParametersUnkown;
mcmc.regularizationFactor = 1e-7;
mcmc.priorScaling = 1/5;
mcmc.isFastInit = false;
mcmc.fastInitSNR = 2;                               % linear SNR factor assumed by the fast initialization when the noise variance is integrated out; about 1/(1-B) for the Bartlett values B of 0.4-0.5 reached in the MFP

% define prior (the order of the fields has to match the order of the state)
sourceRangeCenter = scenario.sourceRangeGPS;        % GPS source range of the reference window
scenario.prior.sourceRange = sourceRangeCenter + [-500;500];
scenario.prior.sourceDepth = [100;140];             % tow depth ~120 m
scenario.prior.tilt = [-3;3];
scenario.prior.waterDepth = [195;205];

scenario.prior.speedTop = [1450;1750];
scenario.prior.speedBottom = [1550;1900];           % coupled to speedH: same interval as speedH
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
scenario.priorMean(scenario.coupling(:,1)) = scenario.priorMean(scenario.coupling(:,2));       % the first sample is the prior mean; it has to satisfy the coupling

% initialize covariance matrix
sampleMean = nan(numParameters,numTemperatures);
sampleCorrelation = nan(numParameters,numParameters,numTemperatures);
numSamplesCovariance = 5*numParametersUnkown*ones(numTemperatures,1);

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
        save('resultsDataJointTmp','samples','logLikelihoods','logPriors','proposalCovariances','proposalCovarianceHistory','covarianceHistoryInterval','isAccepted','swapIndexes','tempering','scenario','mcmc')
    end

end
toc

[sensitivityY,sensitivityX] = getSensitivitySBCEXP22(scenario.prior,rmfield(scenario,'sourceRangeOffsets'),25);      % sensitivity for the reference window

save('resultsDataJoint','samples','logLikelihoods','logPriors','proposalCovariances','proposalCovarianceHistory','covarianceHistoryInterval','isAccepted','swapIndexes','tempering','scenario','mcmc','sensitivityY','sensitivityX');
