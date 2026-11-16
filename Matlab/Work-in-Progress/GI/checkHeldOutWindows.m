clear variables; close all; clc;

% Evaluates the estimates of an inversion on all averaging windows of its data
% file: the windows used in the inversion and the held-out windows. The source
% range of each window is the estimated range of the reference window plus the
% GPS range difference to the reference window; environment, source depth, and
% tilt are those of the estimate. Nothing is fitted to the held-out windows.
%
% Works for the results of mainData14L1HJoint.m and for the results of an
% inversion of a single window (mainData14L1H.m, mainData14L1HContinuous.m); in
% the second case all windows except the inverted one are held out.
%
% A change of the model is an improvement if the values of the held-out windows
% improve (correlation coefficients and log-likelihood per window).

resultsFile = 'resultsDataJoint_run20261114T1102_30000samples';     % see the list of results files in showResultsData.m
numBurnIn = 5000;                   % samples removed at the beginning
numPosteriorSamples = 100;          % samples of the posterior evaluated on all windows (one KRAKEN run each); 0: MAP estimate only

load(resultsFile,'samples','logLikelihoods','logPriors','scenario');
codeFolder = fileparts(mfilename('fullpath'));
dataFolder = fullfile(codeFolder,'..','..','Data','acoustic');
processedFolder = fullfile(codeFolder,'..','..','Data','processed');
addpath(fullfile(codeFolder,'..','MFP'));

numTotal = sum(samples(1,1,:)>0);
isValid = numBurnIn+1:numTotal;
samples1 = permute(samples(:,1,isValid),[1,3,2]);
[~,maxIndex] = max(logLikelihoods(1,isValid) + logPriors(1,isValid));
mapEstimate = samples1(:,maxIndex);


%% averaging windows of the file and their GPS ranges (as in mainData14L1HJoint.m)

data.samplingFrequency = 25000;
data.fftLength = 2^14;
data.toneFrequencies = scenario.freqs;
data.toneSearchHalfWidth = 3;
data.numHydrophones = numel(scenario.hydrophoneHeights);

numWindowsFile = 12;
numSnapshots = 15;
snapshotHop = data.fftLength/2/data.samplingFrequency;
windowStartsFile = ((1:numWindowsFile)'-1)*numSnapshots*snapshotHop;

if(isfield(scenario,'windowIndexesFit'))
    windowIndexesFit = scenario.windowIndexesFit;
else
    windowIndexesFit = round(scenario.windowStart/(numSnapshots*snapshotHop)) + 1;     % inversion of a single window
end
isFit = false(numWindowsFile,1);
isFit(windowIndexesFit) = true;
referenceWindow = windowIndexesFit(1);

vlaLatitude = 40.048467;
vlaLongitude = -70.884167;
trackXbtNumbers = (9:11)';
layback = 180;
sspDepths = (0:1:200)';
[~,salinityCast] = readSoundSpeedCastMFP(processedFolder,'CTD',16,sspDepths);
trackTimes = NaT(numel(trackXbtNumbers),1);
trackLatitudes = zeros(numel(trackXbtNumbers),1);
trackLongitudes = zeros(numel(trackXbtNumbers),1);
for xbtIndex = 1:numel(trackXbtNumbers)
    [~,xbtCast] = readSoundSpeedCastMFP(processedFolder,'XBT',trackXbtNumbers(xbtIndex),sspDepths,salinityCast.salinity);
    trackTimes(xbtIndex) = xbtCast.time;
    trackLatitudes(xbtIndex) = xbtCast.latitude;
    trackLongitudes(xbtIndex) = xbtCast.longitude;
end
timeValues = str2double(regexp(scenario.fileName,'\.(\d{2})(\d{3})(\d{2})(\d{2})(\d{2})\.sio$','tokens','once'));
fileStart = datetime(2000+timeValues(1),1,timeValues(2),timeValues(3),timeValues(4),timeValues(5));
windowTimes = fileStart + seconds(windowStartsFile + scenario.windowDuration/2);
sourceRangesGPS = getSourceTrackMFP(windowTimes,layback,trackTimes,trackLatitudes,trackLongitudes,vlaLatitude,vlaLongitude);


%% data matrices of all windows, stacked as in mainData14L1HJoint.m

numFreqs = numel(scenario.freqs);
dataMatrixes = zeros(data.numHydrophones,data.numHydrophones,numFreqs*numWindowsFile);
correlationCaps = zeros(numFreqs,numWindowsFile);       % largest value any replica can reach
for windowIndex = 1:numWindowsFile
    columns = (windowIndex-1)*numFreqs+(1:numFreqs);
    dataMatrixes(:,:,columns) = getDataMatrixesSBCEXP22(fullfile(dataFolder,scenario.fileName),windowStartsFile(windowIndex),scenario.windowDuration,data);
    for freqIndex = 1:numFreqs
        correlationCaps(freqIndex,windowIndex) = max(real(eig(dataMatrixes(:,:,columns(freqIndex))))) / real(trace(dataMatrixes(:,:,columns(freqIndex))));
    end
end

scenarioAll = scenario;
scenarioAll.sourceRangeOffsets = sourceRangesGPS - sourceRangesGPS(referenceWindow);


%% MAP estimate on all windows

[logLikelihoodsMap,correlationsMap] = evaluateState(mapEstimate,scenarioAll,dataMatrixes,numFreqs,numWindowsFile);

toneNames = compose('%g Hz',scenario.freqs);
fprintf('%s: MAP estimate (sample %d), reference window %d\n\n',resultsFile,isValid(maxIndex),referenceWindow);
fprintf('%-7s %-9s %9s %9s |','window','','GPS [m]','model [m]'); fprintf('%8s',toneNames{:}); fprintf(' |%8s %8s %8s\n','mean','cap','logL');
for windowIndex = 1:numWindowsFile
    label = 'held out';
    if(isFit(windowIndex)), label = 'fit'; end
    fprintf('%-7d %-9s %9.1f %9.1f |',windowIndex,label,sourceRangesGPS(windowIndex),mapEstimate(1)+scenarioAll.sourceRangeOffsets(windowIndex));
    fprintf('%8.3f',correlationsMap(:,windowIndex)); fprintf(' |%8.3f %8.3f %8.1f\n',mean(correlationsMap(:,windowIndex)),mean(correlationCaps(:,windowIndex)),logLikelihoodsMap(windowIndex));
end
fprintf('\n%-28s','mean over the windows'); fprintf('%8s',toneNames{:}); fprintf(' |%8s %8s %8s\n','mean','cap','logL');
sets = {isFit,~isFit};
setNames = {sprintf('fit (%d windows)',sum(isFit)),sprintf('held out (%d windows)',sum(~isFit))};
for setIndex = 1:2
    fprintf('%-28s',setNames{setIndex}); fprintf('%8.3f',mean(correlationsMap(:,sets{setIndex}),2));
    fprintf(' |%8.3f %8.3f %8.1f\n',mean(correlationsMap(:,sets{setIndex}),'all'),mean(correlationCaps(:,sets{setIndex}),'all'),mean(logLikelihoodsMap(sets{setIndex})));
end


%% samples of the posterior on all windows

if(numPosteriorSamples > 0)
    sampleIndexes = round(linspace(1,size(samples1,2),numPosteriorSamples));
    logLikelihoodsSamples = zeros(numWindowsFile,numPosteriorSamples);
    correlationsSamples = zeros(numWindowsFile,numPosteriorSamples);
    for sampleIndex = 1:numPosteriorSamples
        [logLikelihoodsSamples(:,sampleIndex),correlations] = evaluateState(samples1(:,sampleIndexes(sampleIndex)),scenarioAll,dataMatrixes,numFreqs,numWindowsFile);
        correlationsSamples(:,sampleIndex) = mean(correlations,1)';
    end

    fprintf('\n%d samples of the posterior: mean over the samples (standard deviation over the samples)\n',numPosteriorSamples);
    fprintf('%-28s %22s %22s\n','','correlation coefficient','logL per window');
    for setIndex = 1:2
        setCorrelations = mean(correlationsSamples(sets{setIndex},:),1);
        setLogLikelihoods = mean(logLikelihoodsSamples(sets{setIndex},:),1);
        fprintf('%-28s %14.3f (%.3f) %15.1f (%.1f)\n',setNames{setIndex},mean(setCorrelations),std(setCorrelations),mean(setLogLikelihoods),std(setLogLikelihoods));
    end

    figure(1)
    plot(1:numWindowsFile,mean(correlationCaps,1),'k-.','Linewidth',1.5)
    hold on
    errorbar(1:numWindowsFile,mean(correlationsSamples,2),std(correlationsSamples,0,2),'r--','Linewidth',1)
    plot(1:numWindowsFile,mean(correlationsMap,1),'b-','Linewidth',1.5)
    plot(find(isFit),mean(correlationsMap(:,isFit),1),'bo','MarkerFaceColor','b')
    plot(find(~isFit),mean(correlationsMap(:,~isFit),1),'bo','MarkerFaceColor','w')
    legend({'cap','posterior samples (mean and std)','MAP','MAP, fit windows','MAP, held-out windows'},'Location','best')
    xlabel('averaging window')
    ylabel('correlation coefficient (mean over the tones)')
    ylim([0 1])
    title(strrep(resultsFile,'_','\_'))
end


function [logLikelihoods,correlations] = evaluateState(state,scenario,dataMatrixes,numFreqs,numWindows)
% log-likelihood of each window (numWindows x 1) and correlation coefficients (numFreqs x numWindows)
modelledPressure = getPressuresFromStateSBCEXP22(state,scenario,1);
[logLikelihoodsAll,correlationsAll] = evaluateLogLikelihood(modelledPressure,dataMatrixes,nan,scenario.likelihoodConstantSNR);
logLikelihoods = sum(reshape(logLikelihoodsAll,numFreqs,numWindows),1)';
correlations = reshape(correlationsAll,numFreqs,numWindows);
end
