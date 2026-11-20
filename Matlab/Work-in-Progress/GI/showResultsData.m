clear variables; close all; clc;

% Shows the results of mainData14L1H.m, mainData14L1HContinuous.m, mainData14L1HJoint.m,
% mainData14L1HRangeDependent.m, or mainData14L1HTwoFiles.m: estimates,
% marginal posteriors, sound speed profile of the seabed, sample traces,
% posterior correlations of the unknown parameters, and the correlation
% coefficients (Bartlett values) of the estimates at each tone. For the results
% of mainData14L1HRangeDependent.m also the sound speed profile of the water at
% the array and at the source, the EOFs of the sound speed of the water with
% what the inversion made of them, and the check of the adiabatic modes. For the
% results of mainData14L1HTwoFiles.m the correlation coefficients are listed for
% each file, and the source ranges are compared with the GPS ranges.

% results files (local copies of the files written on the server):
%   'resultsDataTmp'                                        mainData14L1H.m, started 2026-11-11, first 30000 samples (run stopped by a reboot)
%   'resultsDataContinuous_run20261113T2237_30000samples'   mainData14L1HContinuous.m, started 2026-11-13 22:37 PST, complete run (30000 samples)
%   'resultsDataJointTmp_run20261114T1102_10000samples'     mainData14L1HJoint.m, started 2026-11-14 11:02 PST, first 10000 samples
%   'resultsDataJoint_run20261114T1102_30000samples'        mainData14L1HJoint.m, started 2026-11-14 11:02 PST, complete run (30000 samples)
%   'resultsDataEOFRangeDependent_run20261115T2331_20000samples'   mainData14L1HRangeDependent.m, started 2026-11-15 23:31 PST, complete run (20000 samples);
%                                                           use lastSample = 10000: from about sample 11000 on the chain is in a region that exists only
%                                                           because of the adiabatic approximation (CHANGES.md, Section 42)
%   'resultsDataTwoFilesTmp_run20261118T2114_10000samples'  mainData14L1HTwoFiles.m, started 2026-11-18 21:14 PST, first 10000 samples
%   'resultsDataTwoFiles_run20261118T2114_20000samples'     mainData14L1HTwoFiles.m, started 2026-11-18 21:14 PST, complete run (20000 samples);
%                                                           use lastSample = inf and isZoomMarginals = true
% (the results files of a run on the server are 'resultsDataJoint' and 'resultsDataJointTmp'; give the local copy the start time of the run in its name)
resultsFile = 'resultsDataTwoFiles_run20261118T2114_20000samples';
numBurnIn = 5000;                   % samples removed at the beginning
lastSample = inf;                   % last sample that is used; inf: all samples of the file. The sample traces show all samples.
numBins = 50;
isZoomMarginals = true;             % false: the axis of each marginal and of each sample trace is the prior interval; true: the range of the samples (for posteriors that are much narrower than the prior)
temperaturesToShow = 1;             % indexes of the temperatures whose marginals are shown (1: posterior), e.g., 1:numTemperatures
isShowFit = true;                   % compute the correlation coefficients of the estimates (needs the SIO file in Matlab/Data/acoustic and KRAKEN)
numPairingSamples = 20;             % results of mainData14L1HRangeDependent.m: samples of the posterior for which the adiabatic modes are checked (three KRAKEN runs each); 0: MAP estimate only
plotTitle = strrep(resultsFile,'_','\_');     % the figures carry the name of the results file

load(resultsFile);

numTotal = sum(samples(1,1,:)>0);   % an intermediate file holds zeros after the last computed sample
numTemperatures = size(samples,2);
isValid = numBurnIn+1:min(numTotal,lastSample);


% extract prior information and parameter names
prior = scenario.prior;
parameterNames = fieldnames(prior);
priorCell = struct2cell(prior);
priorIntervals = [priorCell{:}]';
numParameters = size(priorIntervals,1);
isCoupled = false(numParameters,1);
isCoupled(scenario.coupling(:,1)) = true;           % coupled parameters are copies of other parameters and are not shown
indexesUnknown = find(~scenario.isKnown & ~isCoupled);
numUnknown = numel(indexesUnknown);


%% compute estimates (at temperature 1, logLikelihoods and logPriors are not tempered)

samples1 = permute(samples(:,1,isValid),[1,3,2]);
logLikelihoods1 = logLikelihoods(1,isValid)';
logPosteriors1 = logLikelihoods1 + logPriors(1,isValid)';

mmseEstimate = mean(samples1,2);
posteriorStds = std(samples1,0,2);
[~,maxIndex] = max(logPosteriors1);
mapEstimate = samples1(:,maxIndex);
credibleIntervals = quantile(samples1,[0.025,0.975],2);

fprintf('%s: %d samples, samples %d to %d used, %d temperatures\n\n',resultsFile,numTotal,isValid(1),isValid(end),numTemperatures);
fprintf('%-18s %10s %10s %10s %10s %10s %10s\n','parameter','MAP','MMSE','std','2.5%','97.5%','reference');
for parameterIndex = indexesUnknown'
    fprintf('%-18s %10.5g %10.5g %10.3g %10.5g %10.5g %10.5g\n',parameterNames{parameterIndex},mapEstimate(parameterIndex),mmseEstimate(parameterIndex),posteriorStds(parameterIndex),credibleIntervals(parameterIndex,1),credibleIntervals(parameterIndex,2),scenario.knownState(parameterIndex));
end
fprintf('\nlog-likelihood at the MAP estimate: %.2f (sample %d)\n',logLikelihoods1(maxIndex),isValid(maxIndex));
fprintf('known parameters: %s\n',strjoin(parameterNames(scenario.isKnown),', '));
for couplingIndex = 1:size(scenario.coupling,1)
    fprintf('coupled parameters: %s = %s\n',parameterNames{scenario.coupling(couplingIndex,1)},parameterNames{scenario.coupling(couplingIndex,2)});
end
fprintf('\n');

% results of mainData14L1HTwoFiles.m: source range of the reference window of each file against its GPS range
isSeveralFiles = isfield(scenario,'files');
if(isSeveralFiles)
    fprintf('source range of the reference window minus its GPS range [m]\n');
    fprintf('%-26s %10s %10s %10s %10s\n','file','MAP','median','2.5%','97.5%');
    for fileIndex = 1:numel(scenario.files)
        file = scenario.files(fileIndex);
        fprintf('%-26s %10.1f %10.1f %10.1f %10.1f\n',file.fileName,mapEstimate(file.sourceRangeIndex)-file.sourceRangeGPS,quantile(samples1(file.sourceRangeIndex,:)-file.sourceRangeGPS,[0.5,0.025,0.975]));
    end
    fprintf('\n');
end


%% sound speed profile of the seabed (state entries: 5 speedTop, 6 speedBottom, 11 thickness, 12 speedH)

profileDepths = (0:0.1:priorIntervals(11,2)+1)';    % depth below the seafloor [m]
profileDepthsTable = [0;0.5;1;2;3;priorIntervals(11,2)];
profileSpeeds = getSpeedProfile(samples1,profileDepths);
profileQuantiles = quantile(profileSpeeds,[0.025,0.5,0.975],2);
profileQuantilesTable = quantile(getSpeedProfile(samples1,profileDepthsTable),[0.025,0.5,0.975],2);

fprintf('sound speed of the seabed [m/s]\n');
fprintf('%-12s %10s %10s %10s\n','depth','median','2.5%','97.5%');
for depthIndex = 1:numel(profileDepthsTable)
    fprintf('%-12s %10.1f %10.1f %10.1f\n',sprintf('%g m',profileDepthsTable(depthIndex)),profileQuantilesTable(depthIndex,2),profileQuantilesTable(depthIndex,1),profileQuantilesTable(depthIndex,3));
end
fprintf('\n');


%% sound speed profile of the water (results of mainData14L1HRangeDependent.m)
% profile at the array: measured profile + EOFs * coefficients at the array;
% profile at the source: profile at the array + EOFs * differences of the coefficients

isEOFProfile = isfield(scenario,'sspIndexesArray');
if(isEOFProfile)
    waterDepths = scenario.ssp.depths;
    waterSpeedsArray = scenario.ssp.speeds + scenario.ssp.eofs*samples1(scenario.sspIndexesArray,:);
    waterSpeedsDifference = scenario.ssp.eofs*samples1(scenario.sspIndexesDifference,:);          % source minus array
    waterQuantilesArray = quantile(waterSpeedsArray,[0.025,0.5,0.975],2);
    waterQuantilesSource = quantile(waterSpeedsArray+waterSpeedsDifference,[0.025,0.5,0.975],2);
    waterQuantilesDifference = quantile(waterSpeedsDifference,[0.025,0.5,0.975],2);
    differenceRms = quantile(rms(waterSpeedsDifference,1),[0.025,0.5,0.975]);

    fprintf('sound speed of the water [m/s]: median (2.5%%, 97.5%%)\n');
    fprintf('%-8s %10s %30s %30s\n','depth','measured','at the array minus measured','at the source minus at the array');
    for depthValue = 0:20:waterDepths(end)
        depthIndex = find(waterDepths >= depthValue,1);
        fprintf('%-8s %10.1f %12.2f (%6.2f, %6.2f) %14.2f (%6.2f, %6.2f)\n',sprintf('%g m',waterDepths(depthIndex)),scenario.ssp.speeds(depthIndex), ...
            waterQuantilesArray(depthIndex,[2,1,3])-scenario.ssp.speeds(depthIndex),waterQuantilesDifference(depthIndex,[2,1,3]));
    end
    fprintf('rms over depth of the difference source minus array: %.2f m/s (%.2f, %.2f)\n\n',differenceRms([2,1,3]));

    % EOFs: share of the variance of the casts and largest value of each EOF, and the estimated coefficients
    numEOFs = size(scenario.ssp.eofs,2);
    eofVarianceShares = nan(numEOFs,1);
    if(isfield(scenario.ssp,'eofInfo'))
        eofVarianceShares = scenario.ssp.eofInfo.varianceShares(1:numEOFs);
    end
    coefficientQuantilesArray = quantile(samples1(scenario.sspIndexesArray,:),[0.025,0.5,0.975],2);
    coefficientQuantilesDifference = quantile(samples1(scenario.sspIndexesDifference,:),[0.025,0.5,0.975],2);
    fprintf('EOFs of the sound speed of the water (coefficients in standard deviations over the casts): median (2.5%%, 97.5%%)\n');
    fprintf('%-6s %18s %22s %30s %30s\n','EOF','share of variance','largest value [m/s]','coefficient at the array','source minus array');
    for eofIndex = 1:numEOFs
        [~,largestIndex] = max(abs(scenario.ssp.eofs(:,eofIndex)));
        fprintf('%-6d %17.0f%% %13.1f at %3.0f m %14.2f (%5.2f, %5.2f) %16.2f (%5.2f, %5.2f)\n',eofIndex,100*eofVarianceShares(eofIndex),scenario.ssp.eofs(largestIndex,eofIndex),waterDepths(largestIndex), ...
            coefficientQuantilesArray(eofIndex,[2,1,3]),coefficientQuantilesDifference(eofIndex,[2,1,3]));
    end
    fprintf('\n');
end


%% posterior correlation coefficients of the unknown parameters

posteriorCorrelation = corrcoef(samples1(indexesUnknown,:)');

fprintf('posterior correlation coefficients of the unknown parameters\n');
nameWidth = num2str(max(13,max(cellfun(@numel,parameterNames(indexesUnknown)))+1));      % column width of the table
fprintf(['%-',nameWidth,'s'],''); fprintf(['%',nameWidth,'s'],parameterNames{indexesUnknown}); fprintf('\n');
for rowIndex = 1:numUnknown
    fprintf(['%-',nameWidth,'s'],parameterNames{indexesUnknown(rowIndex)}); fprintf(['%',nameWidth,'.2f'],posteriorCorrelation(rowIndex,:)); fprintf('\n');
end
fprintf('\n');


%% correlation coefficients (Bartlett values) of the estimates at each tone

if(isShowFit)
    % cross-spectral matrices of the averaging windows used in the inversion, processed as in
    % mainData14L1H.m; a joint inversion (mainData14L1HJoint.m) has several windows, stacked
    % along the third dimension as the columns of the modelled pressure; with several files
    % (mainData14L1HTwoFiles.m) all windows of the first file come first
    data.samplingFrequency = 25000;
    data.fftLength = 2^14;
    data.toneFrequencies = scenario.freqs;
    data.toneSearchHalfWidth = 3;
    data.numHydrophones = numel(scenario.hydrophoneHeights);
    dataFolder = fullfile(fileparts(mfilename('fullpath')),'..','..','Data','acoustic');
    if(isfield(scenario,'windowStarts'))
        windowStarts = scenario.windowStarts;
    else
        windowStarts = scenario.windowStart;
    end
    if(isSeveralFiles)
        fileNames = {scenario.files.fileName}';
    else
        fileNames = {scenario.fileName};
    end
    numFiles = numel(fileNames);
    numFreqs = numel(scenario.freqs);
    numWindows = numel(windowStarts);
    dataMatrixes = zeros(data.numHydrophones,data.numHydrophones,numFreqs*numWindows*numFiles);
    for fileIndex = 1:numFiles
        for windowIndex = 1:numWindows
            columnIndexes = ((fileIndex-1)*numWindows + windowIndex-1)*numFreqs + (1:numFreqs);
            dataMatrixes(:,:,columnIndexes) = getDataMatrixesSBCEXP22(fullfile(dataFolder,fileNames{fileIndex}),windowStarts(windowIndex),scenario.windowDuration,data);
        end
    end

    % correlation coefficients and caps are averaged over the windows (checkHeldOutWindows.m lists each window and the held-out windows)
    fitStates = [mapEstimate,mmseEstimate,scenario.knownState];
    fitNames = {'MAP','MMSE','reference'};
    correlationCoefficients = zeros(numFreqs,size(fitStates,2),numFiles);
    correlationCaps = zeros(numFreqs,numWindows,numFiles);    % largest value any replica can reach: largest eigenvalue of the cross-spectral matrix over its trace
    for fitIndex = 1:size(fitStates,2)
        modelledPressure = getPressuresFromStateSBCEXP22(fitStates(:,fitIndex),scenario,1);
        [~,correlationCoefficientsAll] = evaluateLogLikelihood(modelledPressure,dataMatrixes,nan,scenario.likelihoodConstantSNR);
        correlationCoefficients(:,fitIndex,:) = mean(reshape(correlationCoefficientsAll,numFreqs,numWindows,numFiles),2);
    end
    for matrixIndex = 1:numFreqs*numWindows*numFiles
        correlationCaps(matrixIndex) = max(real(eig(dataMatrixes(:,:,matrixIndex)))) / real(trace(dataMatrixes(:,:,matrixIndex)));
    end
    correlationCaps = mean(correlationCaps,2);

    for fileIndex = 1:numFiles
        fprintf('correlation coefficients (Bartlett values), mean over %d averaging window(s)',numWindows);
        if(numFiles > 1), fprintf(', %s',fileNames{fileIndex}); end
        fprintf('\n');
        fprintf('%-12s',''); fprintf('%10s',fitNames{:},'cap'); fprintf('\n');
        for freqIndex = 1:numFreqs
            fprintf('%-12s',sprintf('%g Hz',scenario.freqs(freqIndex))); fprintf('%10.3f',correlationCoefficients(freqIndex,:,fileIndex),correlationCaps(freqIndex,1,fileIndex)); fprintf('\n');
        end
        fprintf('%-12s','mean'); fprintf('%10.3f',mean(correlationCoefficients(:,:,fileIndex),1),mean(correlationCaps(:,1,fileIndex))); fprintf('\n\n');
    end
    if(numFiles > 1)
        fprintf('mean over the %d files\n',numFiles);
        fprintf('%-12s',''); fprintf('%10s',fitNames{:},'cap'); fprintf('\n');
        fprintf('%-12s','mean'); fprintf('%10.3f',mean(correlationCoefficients,[1,3]),mean(correlationCaps,'all')); fprintf('\n\n');
    end

    % check of the adiabatic modes: the modes of the profile at the source and of the profile at the
    % array are paired by their index (getModePairingSBCEXP22.m)
    if(isEOFProfile && ~all(scenario.isKnown(scenario.sspIndexesDifference)))
        pairingStates = [mapEstimate,samples1(:,round(linspace(1,size(samples1,2),numPairingSamples)))];
        pairingCorrelations = zeros(numFreqs,size(pairingStates,2));
        for stateIndex = 1:size(pairingStates,2)
            pairingCorrelations(:,stateIndex) = getModePairingSBCEXP22(pairingStates(:,stateIndex),scenario,1);
        end
        fprintf('correlation of the paired mode shapes of the two ends (adiabatic modes; about 0.9 and less: the pressure is not reliable)\n');
        fprintf('%-12s %10s','','MAP');
        if(numPairingSamples > 0), fprintf(' %30s',sprintf('%d samples: median (smallest)',numPairingSamples)); end
        fprintf('\n');
        for freqIndex = 1:numFreqs
            fprintf('%-12s %10.3f',sprintf('%g Hz',scenario.freqs(freqIndex)),pairingCorrelations(freqIndex,1));
            if(numPairingSamples > 0), fprintf(' %18.3f (%.3f)',median(pairingCorrelations(freqIndex,2:end)),min(pairingCorrelations(freqIndex,2:end))); end
            fprintf('\n');
        end
        fprintf('\n');
    end
end


%% marginal posteriors of the unknown parameters

numColumns = ceil(numUnknown/2);
for indexTemp = flip(temperaturesToShow(:)')

    currentSamples = permute(samples(:,indexTemp,isValid),[1,3,2]);

    currentFigure = figure(indexTemp);
    currentFigure.WindowState = 'maximized';
    for plotIndex = 1:numUnknown
        parameterIndex = indexesUnknown(plotIndex);
        axisInterval = priorIntervals(parameterIndex,:);     % the horizontal axis is the prior interval
        axisLabel = parameterNames{parameterIndex};
        if(isZoomMarginals)
            axisInterval = getZoomInterval(currentSamples(parameterIndex,:),priorIntervals(parameterIndex,:));
            axisLabel = sprintf('%s (prior %g to %g)',parameterNames{parameterIndex},priorIntervals(parameterIndex,:));
        end
        binEdges = linspace(axisInterval(1),axisInterval(2),numBins+1);

        subplot(2,numColumns,plotIndex)
        h = histogram(currentSamples(parameterIndex,:),'BinEdges',binEdges,'Normalization','probability');
        hold on
        xlabel(axisLabel)
        ylabel('estimated probability')
        xlim(axisInterval)
        ylim([0 1.1*max(h.Values)])
        lineMmse = xline(mmseEstimate(parameterIndex),'r--','Linewidth',1.5);
        lineMap = xline(mapEstimate(parameterIndex),'b-','Linewidth',1.5);
        lineReference = xline(scenario.knownState(parameterIndex),'k-.','Linewidth',1.5);     % outside the axis if isZoomMarginals is set and the samples are far from it
        if(plotIndex == 1)
            legend([lineMmse,lineMap,lineReference],{'MMSE','MAP','reference (MFP)'},'Location','best')
        end
    end
    sgtitle(sprintf('%s temperature %.2f',plotTitle,tempering.temperatures(indexTemp)))
end


%% sound speed profile of the seabed at temperature 1

speedEdges = linspace(min(priorIntervals([5,6,12],1)),max(priorIntervals([5,6,12],2)),101)';
speedCenters = (speedEdges(1:end-1) + speedEdges(2:end))/2;
profileDensity = zeros(numel(profileDepths),numel(speedCenters));
for depthIndex = 1:numel(profileDepths)
    profileDensity(depthIndex,:) = histcounts(profileSpeeds(depthIndex,:),speedEdges,'Normalization','probability');
end

figure(numTemperatures+3)
imagesc(speedCenters,profileDepths,profileDensity)
hold on
colormap(flipud(gray))
currentColorbar = colorbar;
currentColorbar.Label.String = 'estimated probability at each depth';
lineMedian = plot(profileQuantiles(:,2),profileDepths,'r-','Linewidth',1.5);
lineInterval = plot(profileQuantiles(:,[1,3]),profileDepths,'r--','Linewidth',1);
lineMap = plot(getSpeedProfile(mapEstimate,profileDepths),profileDepths,'b-','Linewidth',1.5);
lineReference = plot(getSpeedProfile(scenario.knownState,profileDepths),profileDepths,'k-.','Linewidth',1.5);
legend([lineMedian,lineInterval(1),lineMap,lineReference],{'median','95% interval','MAP','reference (MFP)'},'Location','southwest')
xlabel('sound speed [m/s]')
ylabel('depth below the seafloor [m]')
title(sprintf('%s sound speed profile of the seabed',plotTitle))


%% sound speed profile of the water at temperature 1 (results of mainData14L1HRangeDependent.m)

if(isEOFProfile)
    currentFigure = figure(numTemperatures+4);
    subplot(1,2,1)
    lineMeasured = plot(scenario.ssp.speeds,waterDepths,'k-.','Linewidth',1.5);
    hold on
    lineArray = plot(waterQuantilesArray(:,2),waterDepths,'r-','Linewidth',1.5);
    plot(waterQuantilesArray(:,[1,3]),waterDepths,'r--','Linewidth',1)
    lineSource = plot(waterQuantilesSource(:,2),waterDepths,'b-','Linewidth',1.5);
    plot(waterQuantilesSource(:,[1,3]),waterDepths,'b--','Linewidth',1)
    set(gca,'YDir','reverse')
    legend([lineMeasured,lineArray,lineSource],{'measured (reference)','at the array: median, 95% interval','at the source: median, 95% interval'},'Location','southwest')
    xlabel('sound speed [m/s]')
    ylabel('depth [m]')
    subplot(1,2,2)
    plot(waterQuantilesDifference(:,2),waterDepths,'b-','Linewidth',1.5)
    hold on
    plot(waterQuantilesDifference(:,[1,3]),waterDepths,'b--','Linewidth',1)
    xline(0,'k-.');
    set(gca,'YDir','reverse')
    xlabel('sound speed at the source minus at the array [m/s]')
    ylabel('depth [m]')
    sgtitle(sprintf('%s sound speed profile of the water',plotTitle))

    % EOFs of the sound speed of the water: the casts they are built from, the EOFs, and
    % what each EOF contributes to the estimated profile at the array
    currentFigure = figure(numTemperatures+5);
    currentFigure.WindowState = 'maximized';
    eofColors = lines(numEOFs);
    eofLines = gobjects(numEOFs,1);
    eofNames = cell(numEOFs,1);

    subplot(1,3,1)
    if(isfield(scenario.ssp,'eofInfo'))
        lineCasts = plot(scenario.ssp.eofInfo.castSpeeds,waterDepths,'-','Color',[0.7 0.7 0.7],'Linewidth',0.5);
        hold on
    end
    lineMeasured = plot(scenario.ssp.speeds,waterDepths,'k-.','Linewidth',1.5);
    hold on
    lineArray = plot(waterQuantilesArray(:,2),waterDepths,'r-','Linewidth',1.5);
    set(gca,'YDir','reverse')
    if(isfield(scenario.ssp,'eofInfo'))
        legend([lineCasts(1),lineMeasured,lineArray],{sprintf('the %d casts of the EOFs',size(scenario.ssp.eofInfo.castSpeeds,2)),'measured (reference)','estimated at the array (median)'},'Location','southwest')
    else
        legend([lineMeasured,lineArray],{'measured (reference)','estimated at the array (median)'},'Location','southwest')
    end
    xlabel('sound speed [m/s]')
    ylabel('depth [m]')
    title('casts and profiles')

    subplot(1,3,2)
    for eofIndex = 1:numEOFs
        eofLines(eofIndex) = plot(scenario.ssp.eofs(:,eofIndex),waterDepths,'-','Color',eofColors(eofIndex,:),'Linewidth',1.5);
        hold on
        eofNames{eofIndex} = sprintf('EOF %d (%.0f%% of the variance of the casts)',eofIndex,100*eofVarianceShares(eofIndex));
    end
    xline(0,'k-.');
    set(gca,'YDir','reverse')
    legend(eofLines,eofNames,'Location','southeast')
    xlabel('sound speed for a coefficient of 1 [m/s]')
    ylabel('depth [m]')
    title('EOFs (one standard deviation over the casts)')

    subplot(1,3,3)
    for eofIndex = 1:numEOFs
        eofLines(eofIndex) = plot(scenario.ssp.eofs(:,eofIndex)*coefficientQuantilesArray(eofIndex,2),waterDepths,'-','Color',eofColors(eofIndex,:),'Linewidth',1.5);
        hold on
        eofNames{eofIndex} = sprintf('EOF %d, coefficient %.2f (%.2f, %.2f)',eofIndex,coefficientQuantilesArray(eofIndex,[2,1,3]));
    end
    lineSum = plot(waterQuantilesArray(:,2)-scenario.ssp.speeds,waterDepths,'k-','Linewidth',1.5);
    plot(waterQuantilesArray(:,[1,3])-scenario.ssp.speeds,waterDepths,'k--','Linewidth',1)
    xline(0,'k-.');
    set(gca,'YDir','reverse')
    legend([eofLines;lineSum],[eofNames;{'all EOFs: median, 95% interval'}],'Location','southeast')
    xlabel('estimated profile at the array minus measured [m/s]')
    ylabel('depth [m]')
    title('contribution of each EOF (median coefficient)')
    sgtitle(sprintf('%s EOFs of the sound speed of the water',plotTitle))
end


%% sample traces at temperature 1 (all samples, including the burn-in)

currentFigure = figure(numTemperatures+1);
currentFigure.WindowState = 'maximized';
for plotIndex = 1:numUnknown
    parameterIndex = indexesUnknown(plotIndex);
    subplot(numUnknown+1,1,plotIndex)
    plot(1:numTotal,squeeze(samples(parameterIndex,1,1:numTotal)))
    hold on
    xline(numBurnIn,'r--','Linewidth',1.5);
    if(lastSample < numTotal), xline(lastSample,'r--','Linewidth',1.5); end
    ylabel(parameterNames{parameterIndex},'Rotation',0,'HorizontalAlignment','right','VerticalAlignment','middle')
    if(isZoomMarginals)
        ylim(getZoomInterval(squeeze(samples(parameterIndex,1,1:numTotal)),priorIntervals(parameterIndex,:)))
    else
        ylim(priorIntervals(parameterIndex,:))
    end
    set(gca,'XTickLabel',[])
end
subplot(numUnknown+1,1,numUnknown+1)
plot(1:numTotal,logLikelihoods(1,1:numTotal))
hold on
xline(numBurnIn,'r--','Linewidth',1.5);
if(lastSample < numTotal), xline(lastSample,'r--','Linewidth',1.5); end
ylabel('log-likelihood','Rotation',0,'HorizontalAlignment','right','VerticalAlignment','middle')
xlabel('sample')
ylim([min(logLikelihoods(1,numBurnIn+1:numTotal)) max(logLikelihoods(1,numBurnIn+1:numTotal))])
sgtitle(sprintf('%s samples at temperature 1 (red lines: first and last sample used)',plotTitle))


%% posterior correlation coefficients

figure(numTemperatures+2)
imagesc(posteriorCorrelation,[-1 1])
axis square
colormap(parula)
currentColorbar = colorbar;
currentColorbar.Label.String = 'correlation coefficient';
set(gca,'XTick',1:numUnknown,'XTickLabel',parameterNames(indexesUnknown),'YTick',1:numUnknown,'YTickLabel',parameterNames(indexesUnknown))
xtickangle(45)
for rowIndex = 1:numUnknown
    for columnIndex = 1:numUnknown
        text(columnIndex,rowIndex,sprintf('%.2f',posteriorCorrelation(rowIndex,columnIndex)),'HorizontalAlignment','center')
    end
end
title(sprintf('%s posterior correlation coefficients',plotTitle))


function interval = getZoomInterval(values,priorInterval)
% axis interval for isZoomMarginals: range of the values with a margin of 5% on each side, not beyond the prior interval
margin = 0.05*max(max(values)-min(values),eps(max(abs(priorInterval))));
interval = [max(min(values)-margin,priorInterval(1)),min(max(values)+margin,priorInterval(2))];
end


function speeds = getSpeedProfile(states,depths)
% sound speed at the depths below the seafloor (rows) for each state (columns):
% linear from speedTop to speedBottom inside the layer, speedH below it
speedTop = states(5,:);
speedBottom = states(6,:);
thickness = states(11,:);
speedH = states(12,:);
isLayer = depths < thickness;
speeds = speedTop + (speedBottom-speedTop).*(depths./thickness);
speedsH = repmat(speedH,[numel(depths),1]);
speeds(~isLayer) = speedsH(~isLayer);
end
