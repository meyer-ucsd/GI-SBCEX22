%% Bottom-Parameter Tuning by Matched-Field Processing
% Tunes the sediment layer and halfspace of the MFP environment so that the
% incoherent Bartlett correlation of the Track 8 tonals (VLA1, JD 147) increases.
% Objective: mean, over the tuning windows, of the highest incoherent Bartlett
% value at any range within the source-depth band of the tow (~120 m). The
% first averaging window of each file is used for tuning; all other windows are
% held out for validation. Water depth, sound speed profile, and array geometry
% are fixed, so the tuned bottom also absorbs mismatch in those; it is a check
% of how much the match can improve, not a calibrated inversion.

clear variables; close all; clc;

%% 1. Parameters

% data and spectral analysis (as in MFP.m, except for the 10 s averaging windows)
dataFolder = fullfile(fileparts(mfilename('fullpath')),'..','..','Data','acoustic');
fileNames = {'RAVA01.22147193000.sio';'RAVA01.22147203000.sio';'RAVA01.22147210000.sio'; ...
    'RAVA01.22147211000.sio';'RAVA01.22147212000.sio';'RAVA01.22147213000.sio'};
fs = 25000;
toneFrequencies = [503;653;803;1003;1253];
toneSearchHalfWidth = 3;
fftLength = 2^14;
hopLength = fftLength/2;
averagingDuration = 10;
resultsFolder = fullfile(fileparts(mfilename('fullpath')),'Results');

% VLA geometry (as in MFP.m) and sound speed profile (CTD #20, the profile of
% MFP.m before tuneSoundSpeedMFP.m selected XBT #11)
waterDepth = 200;
hydrophone1HeightAboveBottom = 5.5 + 1.75;
hydrophoneSpacing = 3.75;
numHydrophones = 16;
arrayTilt = 0;
sspFile = 'SBCEXP22_ssp_ctd020.mat';

% search grid: tow-depth band for the objective, full depth range for validation
searchRanges = (500:10:6000)';
towDepths = (100:1:140)';
validationDepths = (1:1:199)';

% bottom parameters: initial values (MFP environment) and bounds (GI priors)
parameterNames = {'speedTop';'speedBottom';'densityTop';'densityBottom';'attenuationTop'; ...
    'attenuationBottom';'thickness';'speedH';'densityH';'attenuationH'};
parameterUnits = {'m/s';'m/s';'g/cm^3';'g/cm^3';'dB/(m kHz)';'dB/(m kHz)';'m';'m/s';'g/cm^3';'dB/(m kHz)'};
initialParameters = [1550;1620;1.60;1.80;0.30;0.55;1.5;1650;1.85;0.65];
lowerBounds = [1450;1450;1.2;1.2;0;0;0.5;1550;1.5;0];
upperBounds = [1750;1850;2.2;2.2;1.0;1.0;5;1900;2.3;1.0];

% coordinate descent: each pass sweeps every parameter over numValuesPerSweep
% values; the sweep interval is halved after each pass
numValuesPerSweep = 9;
numPasses = 3;

% Acoustics Toolbox
atPath = fullfile(getenv('HOME'),'Desktop','Matlab','at');


%% 2. Acoustics Toolbox, Array Geometry, and Sound Speed Profile

if isempty(which('read_modes'))
    addpath(genpath(fullfile(atPath,'Matlab')));
end
if isempty(which('kraken.exe'))
    addpath(fullfile(atPath,'bin'));
end
krakenPath = which('kraken.exe');
if isempty(krakenPath) || isempty(which('read_modes'))
    error('Acoustics Toolbox not found; set atPath to its location')
end

environment.hydrophoneHeights = hydrophoneSpacing*(0:numHydrophones-1)';
environment.hydrophoneDepths = waterDepth - hydrophone1HeightAboveBottom - environment.hydrophoneHeights*cosd(arrayTilt);
environment.hydrophoneOffsets = environment.hydrophoneHeights*sind(arrayTilt);
environment.waterDepth = waterDepth;
environment.toneFrequencies = toneFrequencies;
environment.searchRanges = searchRanges;
environment.krakenPath = krakenPath;

ssp = load(sspFile);
[~,deepestIndex] = max(ssp.ctd_Depth);
[sspDepthsMeasured,uniqueIndexes] = unique(ssp.ctd_Depth(1:deepestIndex));
sspSpeedsMeasured = ssp.ctd_ssp(uniqueIndexes);
environment.sspDepths = linspace(0,waterDepth,500)';
environment.sspSpeeds = interp1(sspDepthsMeasured(:),sspSpeedsMeasured(:),environment.sspDepths,'pchip',nan);
environment.sspSpeeds(environment.sspDepths < sspDepthsMeasured(1)) = sspSpeedsMeasured(1);
environment.sspSpeeds(environment.sspDepths > sspDepthsMeasured(end)) = sspSpeedsMeasured(end);


%% 3. Cross-Spectral Matrices of All Averaging Windows

framesPerWindow = max(1,round(averagingDuration*fs/hopLength));
crossSpectralMatrices = zeros(numHydrophones,numHydrophones,numel(toneFrequencies),0);
windowTimes = NaT(0,1);
isTuningWindow = false(0,1);
for fileIndex = 1:numel(fileNames)
    timeTokens = regexp(fileNames{fileIndex},'\.(\d{2})(\d{3})(\d{2})(\d{2})(\d{2})\.sio$','tokens','once');
    timeValues = str2double(timeTokens);
    fileStart = datetime(2000+timeValues(1),1,timeValues(2),timeValues(3),timeValues(4),timeValues(5));    % UTC

    [fileMatrices,~,fileWindowTimes] = getToneCrossSpectraMFP(fullfile(dataFolder,fileNames{fileIndex}), ...
        numHydrophones,fs,fftLength,toneFrequencies,toneSearchHalfWidth,framesPerWindow);
    crossSpectralMatrices = cat(4,crossSpectralMatrices,fileMatrices);
    windowTimes = [windowTimes; fileStart + seconds(fileWindowTimes)]; %#ok<AGROW>
    isTuningWindow = [isTuningWindow; (1:numel(fileWindowTimes))' == 1]; %#ok<AGROW>
end
tuningMatrices = crossSpectralMatrices(:,:,:,isTuningWindow);
fprintf('%d averaging windows: %d for tuning, %d held out\n',numel(windowTimes),sum(isTuningWindow),sum(~isTuningWindow));


%% 4. Coordinate Descent

numParameters = numel(initialParameters);
currentParameters = initialParameters;
initialObjective = evaluateObjective(currentParameters,towDepths,tuningMatrices,environment);
currentObjective = initialObjective;
fprintf('initial objective: %.4f\n',initialObjective);

sweepValues = cell(numParameters,numPasses);
sweepObjectives = cell(numParameters,numPasses);
for passIndex = 1:numPasses
    halfWidths = (upperBounds-lowerBounds)/2/2^(passIndex-1);
    for parameterIndex = 1:numParameters
        values = linspace(max(lowerBounds(parameterIndex),currentParameters(parameterIndex)-halfWidths(parameterIndex)), ...
            min(upperBounds(parameterIndex),currentParameters(parameterIndex)+halfWidths(parameterIndex)),numValuesPerSweep)';
        values = unique([values;currentParameters(parameterIndex)]);
        objectives = zeros(size(values));
        for valueIndex = 1:numel(values)
            if values(valueIndex) == currentParameters(parameterIndex)
                objectives(valueIndex) = currentObjective;
                continue
            end
            candidate = currentParameters;
            candidate(parameterIndex) = values(valueIndex);
            objectives(valueIndex) = evaluateObjective(candidate,towDepths,tuningMatrices,environment);
        end
        [bestObjective,bestIndex] = max(objectives);
        if bestObjective > currentObjective
            currentParameters(parameterIndex) = values(bestIndex);
            currentObjective = bestObjective;
        end
        sweepValues{parameterIndex,passIndex} = values;
        sweepObjectives{parameterIndex,passIndex} = objectives;
        fprintf('pass %d, %-18s = %8.4g  objective %.4f\n',passIndex,parameterNames{parameterIndex},currentParameters(parameterIndex),currentObjective);
    end
end
tunedParameters = currentParameters;

fprintf('\n  %-18s %10s %10s   %s\n','parameter','initial','tuned','bounds');
for parameterIndex = 1:numParameters
    fprintf('  %-18s %10.4g %10.4g   [%g, %g] %s\n',parameterNames{parameterIndex},initialParameters(parameterIndex), ...
        tunedParameters(parameterIndex),lowerBounds(parameterIndex),upperBounds(parameterIndex),parameterUnits{parameterIndex});
end


%% 5. Validation on All Windows with the Full Depth Grid

[initialSurfaces] = evaluateSurfaces(initialParameters,validationDepths,crossSpectralMatrices,environment);
[tunedSurfaces] = evaluateSurfaces(tunedParameters,validationDepths,crossSpectralMatrices,environment);
inTowBand = validationDepths >= towDepths(1) & validationDepths <= towDepths(end);

numWindows = numel(windowTimes);
results = struct();
for caseName = ["initial","tuned"]
    if caseName == "initial", surfaces = initialSurfaces; else, surfaces = tunedSurfaces; end
    towPeaks = zeros(numWindows,1); globalPeaks = zeros(numWindows,1);
    peakRanges = zeros(numWindows,1); peakDepths = zeros(numWindows,1);
    for windowIndex = 1:numWindows
        surface = surfaces(:,:,windowIndex);
        towPeaks(windowIndex) = max(surface(inTowBand,:),[],'all');
        [globalPeaks(windowIndex),peakIndex] = max(surface(:));
        [depthIndex,rangeIndex] = ind2sub(size(surface),peakIndex);
        peakRanges(windowIndex) = searchRanges(rangeIndex);
        peakDepths(windowIndex) = validationDepths(depthIndex);
    end
    results.(caseName) = struct('towPeaks',towPeaks,'globalPeaks',globalPeaks,'peakRanges',peakRanges,'peakDepths',peakDepths);
end

fprintf('\n  mean Bartlett in the tow-depth band   tuning windows   held-out windows\n');
fprintf('  initial bottom                        %14.3f   %16.3f\n',mean(results.initial.towPeaks(isTuningWindow)),mean(results.initial.towPeaks(~isTuningWindow)));
fprintf('  tuned bottom                          %14.3f   %16.3f\n',mean(results.tuned.towPeaks(isTuningWindow)),mean(results.tuned.towPeaks(~isTuningWindow)));
fprintf('  windows with global peak in %d-%d m: initial %d of %d, tuned %d of %d\n',towDepths(1),towDepths(end), ...
    sum(results.initial.peakDepths >= towDepths(1) & results.initial.peakDepths <= towDepths(end)),numWindows, ...
    sum(results.tuned.peakDepths >= towDepths(1) & results.tuned.peakDepths <= towDepths(end)),numWindows);

fprintf('\n  Time (UTC)   initial: range [m] depth [m] Bartlett   tuned: range [m] depth [m] Bartlett   (* tuning window)\n');
for windowIndex = 1:numWindows
    tuningMarker = ' ';
    if isTuningWindow(windowIndex)
        tuningMarker = '*';
    end
    fprintf('  %s %s %15.0f %9.0f %8.3f %17.0f %9.0f %8.3f\n',string(windowTimes(windowIndex),'HH:mm:ss'),tuningMarker, ...
        results.initial.peakRanges(windowIndex),results.initial.peakDepths(windowIndex),results.initial.globalPeaks(windowIndex), ...
        results.tuned.peakRanges(windowIndex),results.tuned.peakDepths(windowIndex),results.tuned.globalPeaks(windowIndex));
end

if ~isfolder(resultsFolder)
    mkdir(resultsFolder);
end
save(fullfile(resultsFolder,'tunedBottom.mat'),'parameterNames','parameterUnits','initialParameters','tunedParameters', ...
    'lowerBounds','upperBounds','initialObjective','currentObjective','sweepValues','sweepObjectives','results','windowTimes','isTuningWindow');


%% 6. Visualization

% sensitivity of the objective to each parameter in the first pass (others at their initial values)
figure1 = figure('Name','Bottom Tuning Sweeps','Color','w','Position',[100,100,1500,700]);
for parameterIndex = 1:numParameters
    subplot(2,5,parameterIndex);
    plot(sweepValues{parameterIndex,1},sweepObjectives{parameterIndex,1},'k.-','MarkerSize',12);
    hold on
    xline(initialParameters(parameterIndex),'b--');
    xline(tunedParameters(parameterIndex),'r-','LineWidth',1.2);
    xlabel(sprintf('%s [%s]',parameterNames{parameterIndex},parameterUnits{parameterIndex}));
    ylabel('objective');
    grid on
end
sgtitle('First tuning pass: mean tow-depth Bartlett peak vs. each bottom parameter (blue: initial, red: tuned)');
print(figure1,fullfile(resultsFolder,'tuning_sweeps.png'),'-dpng','-r150');

% peak Bartlett and global-peak depth for all windows
figure2 = figure('Name','Bottom Tuning Validation','Color','w','Position',[150,150,1000,750]);
subplot(2,1,1);
plot(windowTimes,results.initial.towPeaks,'bo'); hold on
plot(windowTimes,results.tuned.towPeaks,'ro','MarkerFaceColor','r');
plot(windowTimes(isTuningWindow),results.tuned.towPeaks(isTuningWindow),'ks','MarkerSize',12);
ylabel('Bartlett peak, 100-140 m'); grid on
legend('initial bottom','tuned bottom','tuning windows','Location','best');
title('Highest incoherent Bartlett value in the tow-depth band');
subplot(2,1,2);
plot(windowTimes,results.initial.peakDepths,'bo'); hold on
plot(windowTimes,results.tuned.peakDepths,'ro','MarkerFaceColor','r');
yregion(towDepths(1),towDepths(end),'FaceColor',[0.85 0.85 0.85]);
set(gca,'YDir','reverse'); ylim([0 200]);
ylabel('Depth of global peak [m]'); xlabel('Time (UTC), JD 147'); grid on
legend('initial bottom','tuned bottom','tow-depth band','Location','best');
print(figure2,fullfile(resultsFolder,'tuning_validation.png'),'-dpng','-r150');

% incoherent surfaces of the first window of each file, initial and tuned bottom
figure3 = figure('Name','MFP with Tuned Bottom','Color','w','Position',[200,200,1400,800]);
firstWindows = find(isTuningWindow);
colorLimit = max(max(tunedSurfaces(:,:,firstWindows),[],'all'),max(initialSurfaces(:,:,firstWindows),[],'all'));
for fileIndex = 1:numel(firstWindows)
    windowIndex = firstWindows(fileIndex);
    subplot(2,numel(firstWindows),fileIndex);
    imagesc(searchRanges/1000,validationDepths,initialSurfaces(:,:,windowIndex)); caxis([0 colorLimit]); hold on
    plot(results.initial.peakRanges(windowIndex)/1000,results.initial.peakDepths(windowIndex),'wo','MarkerSize',8,'LineWidth',1.5);
    title(sprintf('%s initial',string(windowTimes(windowIndex),'HH:mm'))); xlabel('Range [km]'); ylabel('Depth [m]');
    subplot(2,numel(firstWindows),numel(firstWindows)+fileIndex);
    imagesc(searchRanges/1000,validationDepths,tunedSurfaces(:,:,windowIndex)); caxis([0 colorLimit]); hold on
    plot(results.tuned.peakRanges(windowIndex)/1000,results.tuned.peakDepths(windowIndex),'wo','MarkerSize',8,'LineWidth',1.5);
    title(sprintf('%s tuned',string(windowTimes(windowIndex),'HH:mm'))); xlabel('Range [km]'); ylabel('Depth [m]');
end
colorbar('Position',[0.93 0.11 0.012 0.8]);
sgtitle('Incoherent Bartlett MFP, first window of each file (top: initial bottom, bottom: tuned bottom)');
print(figure3,fullfile(resultsFolder,'tuning_surfaces.png'),'-dpng','-r150');


%% Local Functions

function [sediment,halfspace] = getBottom(parameters)

sediment.speeds = parameters(1:2);
sediment.densities = parameters(3:4);
sediment.attenuations = parameters(5:6);
sediment.thickness = parameters(7);
halfspace.speed = parameters(8);
halfspace.density = parameters(9);
halfspace.attenuation = parameters(10);

end


function surfaces = evaluateSurfaces(parameters,searchDepths,crossSpectralMatrices,environment)
% incoherent Bartlett surfaces (depths x ranges x windows) for a bottom

[sediment,halfspace] = getBottom(parameters);
numTones = numel(environment.toneFrequencies);
numWindows = size(crossSpectralMatrices,4);
modeDepths = unique(round([environment.hydrophoneDepths;searchDepths],3));
surfaces = zeros(numel(searchDepths),numel(environment.searchRanges),numWindows);
for toneIndex = 1:numTones
    modes = computeModesMFP(environment.toneFrequencies(toneIndex),modeDepths,environment.waterDepth,environment.sspDepths, ...
        environment.sspSpeeds,sediment,halfspace,environment.krakenPath);
    replicas = computeReplicasMFP(modes,environment.hydrophoneDepths,environment.hydrophoneOffsets,searchDepths,environment.searchRanges);
    for windowIndex = 1:numWindows
        bartlett = real(sum(conj(replicas).*(crossSpectralMatrices(:,:,toneIndex,windowIndex)*replicas),1));
        surfaces(:,:,windowIndex) = surfaces(:,:,windowIndex) + reshape(bartlett,numel(searchDepths),[])/numTones;
    end
end

end


function objective = evaluateObjective(parameters,towDepths,crossSpectralMatrices,environment)
% mean over windows of the highest incoherent Bartlett value in the tow-depth band

try
    surfaces = evaluateSurfaces(parameters,towDepths,crossSpectralMatrices,environment);
    objective = mean(max(reshape(surfaces,[],size(surfaces,3)),[],1));
catch err
    warning('Bottom %s rejected: %s',mat2str(parameters',4),err.message);
    objective = 0;
end

end
