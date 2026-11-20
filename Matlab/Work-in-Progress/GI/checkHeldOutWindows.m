clear variables; close all; clc;

% Evaluates the estimates of an inversion on all averaging windows of its data
% file: the windows used in the inversion and the held-out windows. The source
% range of each window is the estimated range of the reference window plus the
% GPS range difference to the reference window; environment, source depth, and
% tilt are those of the estimate. Nothing is fitted to the held-out windows.
%
% Works for the results of mainData14L1HJoint.m and for the results of an
% inversion of a single window (mainData14L1H.m, mainData14L1HContinuous.m); in
% the second case all windows except the inverted one are held out. For the
% results of mainData14L1HTwoFiles.m all windows of each of its files are
% evaluated, with the GPS ranges stored in the results file.
%
% A change of the model is an improvement if the values of the held-out windows
% improve (correlation coefficients and log-likelihood per window).

resultsFile = 'resultsDataTwoFiles_run20261118T2114_20000samples';     % see the list of results files in showResultsData.m
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

isSeveralFiles = isfield(scenario,'files');         % results of mainData14L1HTwoFiles.m
if(isSeveralFiles)
    % the GPS ranges of all windows of each file are in the results file (GPS of the ship, getSourceRangesGPSSBCEXP22.m)
    fileNames = {scenario.files.fileName}';
    sourceRangeIndexes = [scenario.files.sourceRangeIndex]';
    numFiles = numel(fileNames);
    sourceRangesGPS = zeros(numWindowsFile,numFiles);
    for fileIndex = 1:numFiles
        sourceRangesGPS(:,fileIndex) = scenario.files(fileIndex).sourceRangesGPSFile;
    end
else
    % as in mainData14L1HJoint.m: positions of the XBT launches of the tow
    fileNames = {scenario.fileName};
    sourceRangeIndexes = 1;
    numFiles = 1;
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
    sourceRangesGPS = sourceRangesGPS(:);
end
sourceRangeOffsets = sourceRangesGPS - sourceRangesGPS(referenceWindow,:);      % GPS range of each window minus that of the reference window of its file


%% data matrices of all windows, stacked as in mainData14L1HJoint.m (several files: all windows of the first file first)

numFreqs = numel(scenario.freqs);
dataMatrixes = zeros(data.numHydrophones,data.numHydrophones,numFreqs*numWindowsFile*numFiles);
correlationCaps = zeros(numFreqs,numWindowsFile,numFiles);       % largest value any replica can reach
for fileIndex = 1:numFiles
    for windowIndex = 1:numWindowsFile
        columns = ((fileIndex-1)*numWindowsFile + windowIndex-1)*numFreqs+(1:numFreqs);
        dataMatrixes(:,:,columns) = getDataMatrixesSBCEXP22(fullfile(dataFolder,fileNames{fileIndex}),windowStartsFile(windowIndex),scenario.windowDuration,data);
        for freqIndex = 1:numFreqs
            correlationCaps(freqIndex,windowIndex,fileIndex) = max(real(eig(dataMatrixes(:,:,columns(freqIndex))))) / real(trace(dataMatrixes(:,:,columns(freqIndex))));
        end
    end
end

scenarioAll = scenario;
if(isSeveralFiles)
    for fileIndex = 1:numFiles
        scenarioAll.files(fileIndex).sourceRangeOffsets = sourceRangeOffsets(:,fileIndex);
    end
else
    scenarioAll.sourceRangeOffsets = sourceRangeOffsets;
end


%% MAP estimate on all windows

[logLikelihoodsMap,correlationsMap] = evaluateState(mapEstimate,scenarioAll,dataMatrixes,numFreqs,numWindowsFile,numFiles);

toneNames = compose('%g Hz',scenario.freqs);
fprintf('%s: MAP estimate (sample %d), reference window %d\n',resultsFile,isValid(maxIndex),referenceWindow);
for fileIndex = 1:numFiles
    fprintf('\n');
    if(numFiles > 1), fprintf('%s\n',fileNames{fileIndex}); end
    fprintf('%-7s %-9s %9s %9s |','window','','GPS [m]','model [m]'); fprintf('%8s',toneNames{:}); fprintf(' |%8s %8s %8s\n','mean','cap','logL');
    for windowIndex = 1:numWindowsFile
        label = 'held out';
        if(isFit(windowIndex)), label = 'fit'; end
        fprintf('%-7d %-9s %9.1f %9.1f |',windowIndex,label,sourceRangesGPS(windowIndex,fileIndex),mapEstimate(sourceRangeIndexes(fileIndex))+sourceRangeOffsets(windowIndex,fileIndex));
        fprintf('%8.3f',correlationsMap(:,windowIndex,fileIndex)); fprintf(' |%8.3f %8.3f %8.1f\n',mean(correlationsMap(:,windowIndex,fileIndex)),mean(correlationCaps(:,windowIndex,fileIndex)),logLikelihoodsMap(windowIndex,fileIndex));
    end
end

% means over the windows: each file, and all files together
sets = {isFit,~isFit};
setNames = {sprintf('fit (%d windows)',sum(isFit)),sprintf('held out (%d windows)',sum(~isFit))};
fileSets = num2cell(1:numFiles);
fileSetNames = fileNames';
if(numFiles > 1)
    fileSets{end+1} = 1:numFiles;
    fileSetNames{end+1} = 'all files';
end
rowNames = cell(2,numel(fileSets));
for fileSetIndex = 1:numel(fileSets)
    for setIndex = 1:2
        rowNames{setIndex,fileSetIndex} = setNames{setIndex};
        if(numFiles > 1), rowNames{setIndex,fileSetIndex} = [fileSetNames{fileSetIndex},', ',setNames{setIndex}]; end
    end
end
nameWidth = num2str(max(28,max(cellfun(@numel,rowNames(:)))+2));
fprintf(['\n%-',nameWidth,'s'],'mean over the windows'); fprintf('%8s',toneNames{:}); fprintf(' |%8s %8s %8s\n','mean','cap','logL');
for fileSetIndex = 1:numel(fileSets)
    for setIndex = 1:2
        fprintf(['%-',nameWidth,'s'],rowNames{setIndex,fileSetIndex}); fprintf('%8.3f',mean(correlationsMap(:,sets{setIndex},fileSets{fileSetIndex}),[2,3]));
        fprintf(' |%8.3f %8.3f %8.1f\n',mean(correlationsMap(:,sets{setIndex},fileSets{fileSetIndex}),'all'),mean(correlationCaps(:,sets{setIndex},fileSets{fileSetIndex}),'all'),mean(logLikelihoodsMap(sets{setIndex},fileSets{fileSetIndex}),'all'));
    end
end


%% samples of the posterior on all windows

if(numPosteriorSamples > 0)
    sampleIndexes = round(linspace(1,size(samples1,2),numPosteriorSamples));
    logLikelihoodsSamples = zeros(numWindowsFile,numFiles,numPosteriorSamples);
    correlationsSamples = zeros(numWindowsFile,numFiles,numPosteriorSamples);      % mean over the tones
    for sampleIndex = 1:numPosteriorSamples
        [logLikelihoodsSamples(:,:,sampleIndex),correlations] = evaluateState(samples1(:,sampleIndexes(sampleIndex)),scenarioAll,dataMatrixes,numFreqs,numWindowsFile,numFiles);
        correlationsSamples(:,:,sampleIndex) = permute(mean(correlations,1),[2,3,1]);
    end

    fprintf('\n%d samples of the posterior: mean over the samples (standard deviation over the samples)\n',numPosteriorSamples);
    fprintf(['%-',nameWidth,'s %22s %22s\n'],'','correlation coefficient','logL per window');
    for fileSetIndex = 1:numel(fileSets)
        for setIndex = 1:2
            setCorrelations = squeeze(mean(correlationsSamples(sets{setIndex},fileSets{fileSetIndex},:),[1,2]));
            setLogLikelihoods = squeeze(mean(logLikelihoodsSamples(sets{setIndex},fileSets{fileSetIndex},:),[1,2]));
            fprintf(['%-',nameWidth,'s %14.3f (%.3f) %15.1f (%.1f)\n'],rowNames{setIndex,fileSetIndex},mean(setCorrelations),std(setCorrelations),mean(setLogLikelihoods),std(setLogLikelihoods));
        end
    end

    figure(1)
    for fileIndex = 1:numFiles
        subplot(numFiles,1,fileIndex)
        plot(1:numWindowsFile,mean(correlationCaps(:,:,fileIndex),1),'k-.','Linewidth',1.5)
        hold on
        errorbar(1:numWindowsFile,mean(correlationsSamples(:,fileIndex,:),3),std(correlationsSamples(:,fileIndex,:),0,3),'r--','Linewidth',1)
        plot(1:numWindowsFile,mean(correlationsMap(:,:,fileIndex),1),'b-','Linewidth',1.5)
        plot(find(isFit),mean(correlationsMap(:,isFit,fileIndex),1),'bo','MarkerFaceColor','b')
        plot(find(~isFit),mean(correlationsMap(:,~isFit,fileIndex),1),'bo','MarkerFaceColor','w')
        if(fileIndex == 1)
            legend({'cap','posterior samples (mean and std)','MAP','MAP, fit windows','MAP, held-out windows'},'Location','best')
        end
        xlabel('averaging window')
        ylabel('correlation coefficient (mean over the tones)')
        ylim([0 1])
        if(numFiles > 1)
            title(sprintf('%s, %s',strrep(resultsFile,'_','\_'),fileNames{fileIndex}))
        else
            title(strrep(resultsFile,'_','\_'))
        end
    end
end


function [logLikelihoods,correlations] = evaluateState(state,scenario,dataMatrixes,numFreqs,numWindows,numFiles)
% log-likelihood of each window (numWindows x numFiles) and correlation coefficients (numFreqs x numWindows x numFiles)
modelledPressure = getPressuresFromStateSBCEXP22(state,scenario,1);
[logLikelihoodsAll,correlationsAll] = evaluateLogLikelihood(modelledPressure,dataMatrixes,nan,scenario.likelihoodConstantSNR);
logLikelihoods = reshape(sum(reshape(logLikelihoodsAll,numFreqs,numWindows,numFiles),1),numWindows,numFiles);
correlations = reshape(correlationsAll,numFreqs,numWindows,numFiles);
end
