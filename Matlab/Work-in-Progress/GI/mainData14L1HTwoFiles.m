clear variables; close all; clc; rng(1); delete(gcp('nocreate'));

% SBCEXP22 shelf break, VLA1 (200 m contour), source tow Track 8 (JD 147,
% 1929Z-0000Z): one sediment layer with gradients in speed, density, and
% attenuation over a halfspace.
%
% Joint inversion of two files in which the source is about 1 km from the
% array on opposite sides of it: 2100Z (source to the east-southeast, leaving)
% and 2030Z (source to the west, approaching). As in mainData14L1HJoint.m,
% six averaging windows of each file are inverted together and the other six
% are held out; the range of each window follows from the range of the
% reference window of its file and the GPS range differences.
%
% Shared by the two files: the seabed, the water depth, the tilt of the array,
% and the roughness of the seafloor. Separate for each file: source range and
% source depth, the sound speed profile of the water, and the roughness of the
% sea surface. The state holds, after the 14 entries of mainData14L1HJoint.m
% (source range and source depth of the first file in entries 1 and 2),
%   sourceRange2, sourceDepth2:  source range of the reference window and
%                                source depth of the second file
%   roughnessSeafloor:           rms roughness of the seafloor [m]
% (getPressuresFromStateSBCEXP22.m, scenario.files).
%
% Differences to the earlier scripts (CHANGES.md, Sections 38 to 43):
% - Sound speed profile of the water at the time of each file from the
%   temperature loggers of the array, with XBT #11 above the loggers
%   (getLoggerProfileSBCEXP22.m).
% - Roughness of the sea surface and of the seafloor as a loss of the coherent
%   field (KRAKEN). The roughness of the sea surface is known from the wave
%   radar of the ship; the roughness of the seafloor is an unknown. With two
%   files and one seabed the roughness raises the fit and changes the seabed
%   that is found (Section 41).
% - The water depth is kept at the measured value. Left free it trades off with
%   the source range (Section 39).
% - Source ranges from the GPS of the ship instead of the positions of the XBT
%   launches (getSourceRangesGPSSBCEXP22.m), and a prior of the source depth
%   that follows the depth sensor of the source.
%
% Seabed as in mainData14L1HContinuous.m: the speed at the bottom of the layer
% is equal to the speed of the halfspace (scenario.coupling). Unknown seabed
% parameters: speedTop, thickness, speedH, roughnessSeafloor.

%% set general parameters

freqsTonesLF = [503; 653; 803; 1003; 1253];         % M71 tonals

scenario.freqs = freqsTonesLF;
scenario.hydrophoneHeights = 5.5 + 1.75 + 3.75*(0:15)';    % above the seafloor, hydrophone 1 first (trip report, Fig. B.3.3)
scenario.likelihoodConstantSNR = nan;               % nan: unknown noise variance at each frequency, integrated out (evaluateLogLikelihood); a number is used as a fixed linear SNR factor (not dB)

% propagation model (getModesSBCEXP22.m): 'kraken_env' (kraken.exe with an
% environment file and a mode file), 'kraken_mex' (the same solver as a MEX
% function without files, Matlab/KrakenMex), or 'orca' (files not part of the
% repository). The roughness is implemented for the two KRAKEN versions only.
scenario.model = 'kraken_mex';                       % default since 2026-11-19; 'kraken_env' gives the same field to 0.999999 and is about 1.4 times slower
resultsFile = 'resultsDataTwoFiles';                % the intermediate file has the same name with Tmp at the end

% data folders and MFP functions (sound speed casts)
dataFolder = fullfile(fileparts(mfilename('fullpath')),'..','..','Data','acoustic');
processedFolder = fullfile(fileparts(mfilename('fullpath')),'..','..','Data','processed');
loggerFolder = fullfile(processedFolder,'TLoggers_HOBO','HOBOs_matfiles');            % temperature loggers of the arrays (experiment folder, processed/TLoggers_HOBO)
shipPositionsFile = fullfile(processedFolder,'shipPositions','SBCEXP22_shipGPS.mat');  % GPS of the ship, one position per minute (experiment folder, processed/shipPositions)
addpath(fullfile(fileparts(mfilename('fullpath')),'..','MFP'));

% the two files; the first one is the file of the earlier scripts
fileNames = {'RAVA01.22147210000.sio';'RAVA01.22147203000.sio'};       % JD 147, 2100Z and 2030Z
roughnessSurface = [1.66;1.50]/4;                   % rms roughness of the sea surface [m]: significant wave height of the wave radar of the ship at 2100Z and at 2030Z (ancillaryData/cruise_data_legC/wave_radar/2022_05_27_wave_cur_params.csv) divided by 4
numFiles = numel(fileNames);

% data: averaging windows of each file, processed as in MFP.m
data.samplingFrequency = 25000;
data.fftLength = 2^14;
data.toneFrequencies = scenario.freqs;
data.toneSearchHalfWidth = 3;                      % search for the Doppler-shifted tonal [Hz]
data.numHydrophones = numel(scenario.hydrophoneHeights);

scenario.windowIndexesFit = (1:2:11)';             % averaging windows of each file used in the inversion, counted as in MFP.m (12 windows per file); the first one is the reference window
scenario.windowIndexesHeldOut = (2:2:12)';         % averaging windows of each file not used in the inversion
numWindowsFile = 12;
numSnapshots = 15;                                 % snapshots per averaging window (MFP.m: 5 s averaging)
snapshotHop = data.fftLength/2/data.samplingFrequency;              % snapshots overlap by 50% [s]
scenario.windowStartsFile = ((1:numWindowsFile)'-1)*numSnapshots*snapshotHop;      % start of each averaging window of a file [s] since file start
scenario.windowStarts = scenario.windowStartsFile(scenario.windowIndexesFit);    % windows used in the inversion
scenario.windowDuration = (numSnapshots+1)*snapshotHop;             % averaging window [s]
fileDuration = scenario.windowStartsFile(end) + scenario.windowDuration;          % part of a file that is used [s]

% reference sound speed profile as in MFP.m: XBT #11 (JD 147, 2133Z, launched
% during the tow 3.4 km east of VLA1) with the salinity of CTD #16 (JD 147,
% 1312Z, at VLA1) in 1 m depth bins down to 200 m; in deeper water the deepest
% value is held. Where the temperature loggers of the array are, the profile of
% each file comes from the loggers at the time of the file (scenario.loggers
% and scenario.files(f).loggerTemperatures, getLoggerProfileSBCEXP22.m).
sspDepths = (0:1:200)';
[~,salinityCast] = readSoundSpeedCastMFP(processedFolder,'CTD',16,sspDepths);
scenario.ssp.depths = sspDepths;
scenario.ssp.speeds = readSoundSpeedCastMFP(processedFolder,'XBT',11,sspDepths,salinityCast.salinity);
scenario.ssp.salinities = salinityCast.salinity;
scenario.numSSPPoints = 500;

% source range from the GPS of the ship: VLA1 position (trip report, Table 2)
% and the source at the point where the ship was when it was the straight-line
% distance layback away (155 m fits the MFP ranges of the two files, CHANGES.md,
% Section 36.3; a joint fit gave 147 m, Section 37.3). The layback only sets
% the centre of the prior of the source ranges; the range differences between
% the windows hardly depend on it.
vlaLatitude = 40.048467;                           % [deg]
vlaLongitude = -70.884167;                         % [deg]
layback = 155;                                     % [m]

% state entries: source range and source depth of each file
sourceRangeIndexes = [1;15];
sourceDepthIndexes = [2;16];
scenario.roughnessSeafloorIndex = 17;
scenario.roughness = [0;0];                         % sea surface and seafloor [m]; set for each file and from the state in getPressuresFromStateSBCEXP22.m

for fileIndex = 1:numFiles
    file.fileName = fileNames{fileIndex};
    timeValues = str2double(regexp(file.fileName,'\.(\d{2})(\d{3})(\d{2})(\d{2})(\d{2})\.sio$','tokens','once'));       % RAVA01.YYDDDHHMMSS.sio
    file.fileStart = datetime(2000+timeValues(1),1,timeValues(2),timeValues(3),timeValues(4),timeValues(5));          % UTC
    windowTimes = file.fileStart + seconds(scenario.windowStartsFile + scenario.windowDuration/2);                    % centres of the averaging windows
    file.sourceRangesGPSFile = getSourceRangesGPSSBCEXP22(shipPositionsFile,windowTimes,layback,vlaLatitude,vlaLongitude);       % all windows of the file
    file.sourceRangeGPS = file.sourceRangesGPSFile(scenario.windowIndexesFit(1));                                     % reference window
    file.sourceRangeOffsets = file.sourceRangesGPSFile(scenario.windowIndexesFit) - file.sourceRangeGPS;              % GPS range of each window used in the inversion minus the GPS range of the reference window
    file.sourceRangeIndex = sourceRangeIndexes(fileIndex);
    file.sourceDepthIndex = sourceDepthIndexes(fileIndex);
    [file.loggerTemperatures,scenario.loggers.heights] = getLoggerTemperaturesSBCEXP22(loggerFolder,scenario.hydrophoneHeights,file.fileStart,seconds(fileDuration));
    file.roughnessSurface = roughnessSurface(fileIndex);
    scenario.files(fileIndex) = file;
end
scenario.sourceRangeGPS = scenario.files(1).sourceRangeGPS;         % reference window of the first file

% reference state used for comparison in the plots: MFP environment, GPS source
% ranges of the reference windows, source depths near the depth sensor of the
% source (120.6 m at 2100Z, 120.5 m at 2030Z; experiment folder,
% processed/sourceDepth), and the measured water depth at VLA1 (204.0 m in the
% 25 m bathymetry; echosounder and loggers 204 to 205 m; CHANGES.md, Section 38.4)
sourceRange = scenario.files(1).sourceRangeGPS;
sourceDepth = 121;
tilt = 0;
waterDepth = 204.0;

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

sourceRange2 = scenario.files(2).sourceRangeGPS;
sourceDepth2 = 121;
roughnessSeafloor = 0;

scenario.knownState = [sourceRange;sourceDepth;tilt;waterDepth;speedTop;speedBottom;densityTop;densityBottom;attenuationTop;attenuationBottom;thickness;speedH;densityH;attenuationH;sourceRange2;sourceDepth2;roughnessSeafloor];      % this is the order of parameters we use all the time
numParameters = size(scenario.knownState,1);

scenario.isKnown = false(numParameters,1);
scenario.isKnown([7;8;9;10;13;14]) = true;          % densities and attenuations of the layer and the halfspace: free values raise the fit by 0.005 or less and run to their bounds (CHANGES.md, Section 37.7); they are kept at their values in scenario.knownState
scenario.isKnown(4) = true;                         % water depth: kept at the measured value

scenario.coupling = [6,12];                         % each row [a,b]: state entry a is set equal to state entry b; here speedBottom = speedH (no speed jump at the interface)

%% load data

% the data matrices are stacked along the third dimension: all windows of the
% first file (all tones of its first window, all tones of its second window,
% ...), then all windows of the second file, as the columns of the modelled
% pressure (getPressuresFromStateSBCEXP22); the log-likelihood is the sum over
% all files, windows, and tones, with an unknown noise variance for each of them
numFreqs = numel(scenario.freqs);
numWindows = numel(scenario.windowStarts);
dataMatrixes = zeros(data.numHydrophones,data.numHydrophones,numFreqs*numWindows*numFiles);
scenario.selectedFrequencies = zeros(numFreqs,numWindows,numFiles);
for fileIndex = 1:numFiles
    for windowIndex = 1:numWindows
        columnIndexes = ((fileIndex-1)*numWindows + windowIndex-1)*numFreqs + (1:numFreqs);
        [dataMatrixes(:,:,columnIndexes),scenario.selectedFrequencies(:,windowIndex,fileIndex)] = getDataMatrixesSBCEXP22(fullfile(dataFolder,scenario.files(fileIndex).fileName),scenario.windowStarts(windowIndex),scenario.windowDuration,data);
    end
end


%% perform inversion

% general parameters
numParameters = numel(scenario.isKnown);
numParametersUnkown = sum(~scenario.isKnown) - size(scenario.coupling,1);
numAcceptanceDimensionInit = 5*numParametersUnkown;
numSamples = 20000;                                 % 9 unknowns and two KRAKEN runs per proposal (one for each file)

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
scenario.prior.sourceRange = scenario.files(1).sourceRangeGPS + [-500;500];       % GPS source range of the reference window of the first file
scenario.prior.sourceDepth = [116;128];             % depth sensor of the source: 120.6 m at 2100Z; its offset to the transducer is not known (acoustic estimates 121 to 122 m)
scenario.prior.tilt = [-3;3];
scenario.prior.waterDepth = [195;212];              % known (scenario.isKnown)

scenario.prior.speedTop = [1450;1750];
scenario.prior.speedBottom = [1550;1900];           % coupled to speedH: same interval as speedH
scenario.prior.densityTop = [1.2;2.2];
scenario.prior.densityBottom = [1.2;2.2];
scenario.prior.attenuationTop = [0;1.0];
scenario.prior.attenuationBottom = [0;1.0];
scenario.prior.thickness = [0.5;15];                % the single-file fits found 2 to 9 m (CHANGES.md, Section 41)

scenario.prior.speedH = [1550;1900];
scenario.prior.densityH = [1.5;2.3];
scenario.prior.attenuationH = [0;1.0];

scenario.prior.sourceRange2 = scenario.files(2).sourceRangeGPS + [-500;500];      % GPS source range of the reference window of the second file
scenario.prior.sourceDepth2 = [116;128];            % depth sensor of the source: 120.5 m at 2030Z (acoustic estimates 124 m)
scenario.prior.roughnessSeafloor = [0;1.5];         % [m]

scenario.priorMean = nan(numParameters,1);

scenario.priorStds = inf(numParameters,1);
scenario.priorStds([1;15]) = 100;                   % source ranges: Gaussian around the GPS ranges


% initialize prior and initial proposal distribution
[scenario.priorMean,priorCovariance,priorRotation,priorVariances] = getPriorCovariance(scenario,mcmc);
scenario.priorMean(scenario.coupling(:,1)) = scenario.priorMean(scenario.coupling(:,2));       % the prior mean has to satisfy the coupling

% first sample (getCovariancesSampling and all chains): best state of two local
% searches with this model (log-likelihood 638.6; the other search ended at
% 620.3 with a layer of 1.5 m and a halfspace of 1657 m/s; CHANGES.md, Section
% 43). A run of an earlier model that started at the centre of the prior stayed
% in a secondary region (CHANGES.md, Section 26). [] starts at the centre of
% the prior, as the first scripts do. scenario.priorMean stays the centre of
% the prior, which evaluateLogPrior uses for the source ranges.
firstSampleUnknowns = [-12.0;121.8;-0.04;1495;3.15;1804;10.5;125.2;0.77];      % sourceRange minus its GPS range, sourceDepth, tilt, speedTop, thickness, speedH, sourceRange2 minus its GPS range, sourceDepth2, roughnessSeafloor
scenario.firstSample = scenario.priorMean;
if(~isempty(firstSampleUnknowns))
    scenario.firstSample([1;2;3;5;11;12;15;16;17]) = firstSampleUnknowns + [scenario.files(1).sourceRangeGPS;0;0;0;0;0;scenario.files(2).sourceRangeGPS;0;0];
    scenario.firstSample(scenario.coupling(:,1)) = scenario.firstSample(scenario.coupling(:,2));
end

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
samples(:,:,1) = repmat(scenario.firstSample,[1,numTemperatures]);
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

    if( mod(currentIndex,5000) == 0 && currentIndex ~= numSamples )
        save([resultsFile,'Tmp'],'samples','logLikelihoods','logPriors','proposalCovariances','proposalCovarianceHistory','covarianceHistoryInterval','isAccepted','swapIndexes','tempering','scenario','mcmc')
    end

end
toc

% sensitivity for the reference window of each file (third dimension: file)
numValuesSensitivity = 25;
sensitivityY = zeros(numValuesSensitivity,numParameters,numFiles);
for fileIndex = 1:numFiles
    scenarioSensitivity = scenario;
    scenarioSensitivity.files = scenario.files(fileIndex);
    scenarioSensitivity.files.sourceRangeOffsets = 0;
    [sensitivityY(:,:,fileIndex),sensitivityX] = getSensitivitySBCEXP22(scenario.prior,scenarioSensitivity,numValuesSensitivity);
end

save(resultsFile,'samples','logLikelihoods','logPriors','proposalCovariances','proposalCovarianceHistory','covarianceHistoryInterval','isAccepted','swapIndexes','tempering','scenario','mcmc','sensitivityY','sensitivityX');
