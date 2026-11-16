clear variables; close all; clc;

% Shows the results of mainData14L1H.m, mainData14L1HContinuous.m, mainData14L1HJoint.m, or
% mainData14L1HRangeDependent.m: estimates,
% marginal posteriors, sound speed profile of the seabed, sample traces,
% posterior correlations of the unknown parameters, and the correlation
% coefficients (Bartlett values) of the estimates at each tone. For the results
% of mainData14L1HRangeDependent.m also the sound speed profile of the water at
% the array and at the source and the check of the adiabatic modes.

% results files (local copies of the files written on the server):
%   'resultsDataTmp'                                        mainData14L1H.m, started 2026-11-11, first 30000 samples (run stopped by a reboot)
%   'resultsDataContinuous_run20261113T2237_30000samples'   mainData14L1HContinuous.m, started 2026-11-13 22:37 PST, complete run (30000 samples)
%   'resultsDataJointTmp_run20261114T1102_10000samples'     mainData14L1HJoint.m, started 2026-11-14 11:02 PST, first 10000 samples
%   'resultsDataJoint_run20261114T1102_30000samples'        mainData14L1HJoint.m, started 2026-11-14 11:02 PST, complete run (30000 samples)
% (the results files of a run on the server are 'resultsDataJoint' and 'resultsDataJointTmp'; give the local copy the start time of the run in its name)
resultsFile = 'resultsDataJoint_run20261114T1102_30000samples';
numBurnIn = 5000;                   % samples removed at the beginning
numBins = 50;
temperaturesToShow = 1;             % indexes of the temperatures whose marginals are shown (1: posterior), e.g., 1:numTemperatures
isShowFit = true;                   % compute the correlation coefficients of the estimates (needs the SIO file in Matlab/Data/acoustic and KRAKEN)
numPairingSamples = 20;             % results of mainData14L1HRangeDependent.m: samples of the posterior for which the adiabatic modes are checked (three KRAKEN runs each); 0: MAP estimate only
plotTitle = strrep(resultsFile,'_','\_');     % the figures carry the name of the results file

load(resultsFile);

numTotal = sum(samples(1,1,:)>0);   % an intermediate file holds zeros after the last computed sample
numTemperatures = size(samples,2);
isValid = numBurnIn+1:numTotal;


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

fprintf('%s: %d samples, %d used after burn-in, %d temperatures\n\n',resultsFile,numTotal,numel(isValid),numTemperatures);
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
    % along the third dimension as the columns of the modelled pressure
    data.samplingFrequency = 25000;
    data.fftLength = 2^14;
    data.toneFrequencies = scenario.freqs;
    data.toneSearchHalfWidth = 3;
    data.numHydrophones = numel(scenario.hydrophoneHeights);
    dataFolder = fullfile(fileparts(mfilename('fullpath')),'..','..','Data','acoustic');
    windowStarts = scenario.windowStart;
    if(isfield(scenario,'windowStarts'))
        windowStarts = scenario.windowStarts;
    end
    numFreqs = numel(scenario.freqs);
    numWindows = numel(windowStarts);
    dataMatrixes = zeros(data.numHydrophones,data.numHydrophones,numFreqs*numWindows);
    for windowIndex = 1:numWindows
        dataMatrixes(:,:,(windowIndex-1)*numFreqs+(1:numFreqs)) = getDataMatrixesSBCEXP22(fullfile(dataFolder,scenario.fileName),windowStarts(windowIndex),scenario.windowDuration,data);
    end

    % correlation coefficients and caps are averaged over the windows (checkHeldOutWindows.m lists each window)
    fitStates = [mapEstimate,mmseEstimate,scenario.knownState];
    fitNames = {'MAP','MMSE','reference'};
    correlationCoefficients = zeros(numFreqs,size(fitStates,2));
    correlationCaps = zeros(numFreqs,numWindows);    % largest value any replica can reach: largest eigenvalue of the cross-spectral matrix over its trace
    for fitIndex = 1:size(fitStates,2)
        modelledPressure = getPressuresFromStateSBCEXP22(fitStates(:,fitIndex),scenario,1);
        [~,correlationCoefficientsAll] = evaluateLogLikelihood(modelledPressure,dataMatrixes,nan,scenario.likelihoodConstantSNR);
        correlationCoefficients(:,fitIndex) = mean(reshape(correlationCoefficientsAll,numFreqs,numWindows),2);
    end
    for matrixIndex = 1:numFreqs*numWindows
        correlationCaps(matrixIndex) = max(real(eig(dataMatrixes(:,:,matrixIndex)))) / real(trace(dataMatrixes(:,:,matrixIndex)));
    end
    correlationCaps = mean(correlationCaps,2);

    fprintf('correlation coefficients (Bartlett values), mean over %d averaging window(s)\n',numWindows);
    fprintf('%-12s',''); fprintf('%10s',fitNames{:},'cap'); fprintf('\n');
    for freqIndex = 1:numFreqs
        fprintf('%-12s',sprintf('%g Hz',scenario.freqs(freqIndex))); fprintf('%10.3f',correlationCoefficients(freqIndex,:),correlationCaps(freqIndex)); fprintf('\n');
    end
    fprintf('%-12s','mean'); fprintf('%10.3f',mean(correlationCoefficients,1),mean(correlationCaps)); fprintf('\n\n');

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
        binEdges = linspace(priorIntervals(parameterIndex,1),priorIntervals(parameterIndex,2),numBins+1);

        subplot(2,numColumns,plotIndex)
        h = histogram(currentSamples(parameterIndex,:),'BinEdges',binEdges,'Normalization','probability');
        hold on
        xlabel(parameterNames{parameterIndex})
        ylabel('estimated probability')
        xlim(priorIntervals(parameterIndex,:))      % the horizontal axis is the prior interval
        ylim([0 1.1*max(h.Values)])
        lineMmse = xline(mmseEstimate(parameterIndex),'r--','Linewidth',1.5);
        lineMap = xline(mapEstimate(parameterIndex),'b-','Linewidth',1.5);
        lineReference = xline(scenario.knownState(parameterIndex),'k-.','Linewidth',1.5);
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
end


%% sample traces at temperature 1 (all samples, including the burn-in)

currentFigure = figure(numTemperatures+1);
currentFigure.WindowState = 'maximized';
for plotIndex = 1:numUnknown
    parameterIndex = indexesUnknown(plotIndex);
    subplot(numUnknown+1,1,plotIndex)
    plot(1:numTotal,squeeze(samples(parameterIndex,1,1:numTotal)))
    hold on
    xline(numBurnIn,'k--');
    ylabel(parameterNames{parameterIndex})
    ylim(priorIntervals(parameterIndex,:))
    set(gca,'XTickLabel',[])
end
subplot(numUnknown+1,1,numUnknown+1)
plot(1:numTotal,logLikelihoods(1,1:numTotal))
hold on
xline(numBurnIn,'k--');
ylabel('log-likelihood')
xlabel('sample')
ylim([min(logLikelihoods1) max(logLikelihoods1)])
sgtitle(sprintf('%s samples at temperature 1',plotTitle))


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
