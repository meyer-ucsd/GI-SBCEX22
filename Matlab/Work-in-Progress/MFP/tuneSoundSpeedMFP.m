%% Sound-Speed Profile Selection by Matched-Field Processing
% Selects the sound speed profile that best matches the Track 8 tonals (VLA1,
% JD 147) at the known source position. The ship's GPS positions at the XBT
% launches during the tow define its track (trip report, App. D); the ship
% moved at constant speed along a straight line, and the source follows the
% track at an unknown layback that is estimated together with each profile.
% Objective: mean, over the averaging windows, of the highest incoherent
% Bartlett value within positionTolerance of the source range and within the
% tow-depth band (~120 m). Candidates are all CTD and XBT casts along the 200 m
% contour; the best one is then refined with the leading EOFs of all
% candidates. The profile and the layback are chosen on the tuning files only;
% the other files are held out for validation. The seabed is that of MFP.m.

clear variables; close all; clc;

%% 1. Parameters

% data and spectral analysis (as in MFP.m, except for the 10 s averaging windows)
dataFolder = fullfile(fileparts(mfilename('fullpath')),'..','..','Data','acoustic');
processedFolder = fullfile(fileparts(mfilename('fullpath')),'..','..','Data','processed');
fileNames = {'RAVA01.22147193000.sio';'RAVA01.22147203000.sio';'RAVA01.22147210000.sio'; ...
    'RAVA01.22147211000.sio';'RAVA01.22147212000.sio';'RAVA01.22147213000.sio'};
fs = 25000;
toneFrequencies = [503;653;803;1003;1253];
toneSearchHalfWidth = 3;
fftLength = 2^14;
hopLength = fftLength/2;
averagingDuration = 10;
resultsFolder = fullfile(fileparts(mfilename('fullpath')),'Results');

% VLA geometry (as in MFP.m) and VLA1 position (trip report, Table 2)
waterDepth = 200;
hydrophone1HeightAboveBottom = 5.5 + 1.75;
hydrophoneSpacing = 3.75;
numHydrophones = 16;
arrayTilt = 0;
vlaLatitude = 40.048467;                      % [deg]
vlaLongitude = -70.884167;                    % [deg]

% seabed of MFP.m (order as in tuneBottomMFP.m: speeds, densities, and
% attenuations at the top and bottom of the sediment layer, its thickness, and
% speed, density, and attenuation of the halfspace)
bottomParameters = [1550;1620;1.60;1.80;0.30;0.55;1.5;1650;1.85;0.65];
tunedBottomFile = fullfile(resultsFolder,'tunedBottom.mat');    % compared if present

% candidate casts along the 200 m contour (CTD #17 and #19 are at other sites)
ctdNumbers = [15;16;18;20;21];
xbtNumbers = (9:21)';
salinityCtdNumber = 16;                       % CTD at VLA1 (JD 147, 1312Z), salinity for the XBTs
baselineCastName = 'CTD 20';                  % profile of MFP.m before this selection

% ship track: GPS positions at the launches of the XBTs during the data files
trackXbtNumbers = (9:11)';                    % JD 147 1932Z, 2033Z, 2133Z

% source position
laybacks = (0:20:600)';                       % distance of the source behind the ship along the track [m]
positionTolerance = 50;                       % VLA position, GPS, and track interpolation [m]
towDepths = (100:1:140)';                     % tow depth ~120 m (trip report, App. F) [m]

% search grid of the validation
searchRanges = (500:10:6000)';
validationDepths = (1:1:199)';

% tuning files (2030Z, 2110Z, 2130Z); the others (1930Z, 2100Z, 2120Z) are held
% out, so both sets cover the approaching and the receding source
tuningFiles = [2;4;6];

% EOF refinement of the best cast: coefficients in units of their standard
% deviation over the candidates; coordinate descent as in tuneBottomMFP.m
numEofs = 4;
eofBound = 2;
numValuesPerSweep = 9;
numPasses = 3;

% Acoustics Toolbox
atPath = fullfile(getenv('HOME'),'Desktop','Matlab','at');


%% 2. Acoustics Toolbox and Array Geometry

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
environment.sspDepths = (0:1:waterDepth)';


%% 3. Candidate Sound Speed Profiles

[~,salinityCast] = readSoundSpeedCastMFP(processedFolder,'CTD',salinityCtdNumber,environment.sspDepths);
castNames = [arrayfun(@(number) sprintf('CTD %d',number),ctdNumbers,'UniformOutput',false); ...
    arrayfun(@(number) sprintf('XBT %d',number),xbtNumbers,'UniformOutput',false)];
numCasts = numel(castNames);
castSpeeds = zeros(numel(environment.sspDepths),numCasts);
castCells = cell(numCasts,1);
for castIndex = 1:numCasts
    nameParts = split(castNames{castIndex});
    [castSpeeds(:,castIndex),castCells{castIndex}] = readSoundSpeedCastMFP(processedFolder,nameParts{1}, ...
        str2double(nameParts{2}),environment.sspDepths,salinityCast.salinity);
end
casts = [castCells{:}]';
baselineIndex = find(strcmp(castNames,baselineCastName));


%% 4. Cross-Spectral Matrices of All Averaging Windows

framesPerWindow = max(1,round(averagingDuration*fs/hopLength));
crossSpectralMatrices = zeros(numHydrophones,numHydrophones,numel(toneFrequencies),0);
windowTimes = NaT(0,1);
windowFiles = zeros(0,1);
for fileIndex = 1:numel(fileNames)
    timeTokens = regexp(fileNames{fileIndex},'\.(\d{2})(\d{3})(\d{2})(\d{2})(\d{2})\.sio$','tokens','once');
    timeValues = str2double(timeTokens);
    fileStart = datetime(2000+timeValues(1),1,timeValues(2),timeValues(3),timeValues(4),timeValues(5));    % UTC

    [fileMatrices,~,fileWindowTimes] = getToneCrossSpectraMFP(fullfile(dataFolder,fileNames{fileIndex}), ...
        numHydrophones,fs,fftLength,toneFrequencies,toneSearchHalfWidth,framesPerWindow);
    crossSpectralMatrices = cat(4,crossSpectralMatrices,fileMatrices);
    windowTimes = [windowTimes; fileStart + seconds(fileWindowTimes)]; %#ok<AGROW>
    windowFiles = [windowFiles; fileIndex*ones(numel(fileWindowTimes),1)]; %#ok<AGROW>
end
numWindows = numel(windowTimes);
isTuningWindow = ismember(windowFiles,tuningFiles);
fprintf('%d averaging windows: %d for tuning, %d held out\n',numWindows,sum(isTuningWindow),sum(~isTuningWindow));

% upper bound of the Bartlett value: the largest eigenvalue of the unit-trace
% cross-spectral matrix (a single plane-wave-like source gives rank one)
largestEigenvalues = zeros(numWindows,numel(toneFrequencies));
for windowIndex = 1:numWindows
    for toneIndex = 1:numel(toneFrequencies)
        largestEigenvalues(windowIndex,toneIndex) = max(real(eig(crossSpectralMatrices(:,:,toneIndex,windowIndex))));
    end
end
bartlettBounds = mean(largestEigenvalues,2);


%% 5. Source Ranges from the Ship Track

trackCasts = casts(ismember(castNames,arrayfun(@(number) sprintf('XBT %d',number),trackXbtNumbers,'UniformOutput',false)));
[sourceRanges,track] = getSourceTrackMFP(windowTimes,laybacks,[trackCasts.time]',[trackCasts.latitude]', ...
    [trackCasts.longitude]',vlaLatitude,vlaLongitude);       % windows x laybacks
fprintf('ship speed %.2f m/s; XBT launch ranges from VLA1: %s m\n',track.shipSpeed,mat2str(round(hypot(track.fixEast,track.fixNorth))'));
if any(sourceRanges(:) < searchRanges(1) + positionTolerance | sourceRanges(:) > searchRanges(end) - positionTolerance)
    error('Source ranges exceed the search grid');
end


%% 6. Bartlett Value at the Source Position for Each Cast

castScores = zeros(numCasts,2);           % tuning and validation windows
castLaybacks = zeros(numCasts,1);
castWindowValues = zeros(numWindows,numCasts);
for castIndex = 1:numCasts
    surfaces = evaluateSurfaces(castSpeeds(:,castIndex),bottomParameters,towDepths,crossSpectralMatrices,environment);
    [castWindowValues(:,castIndex),castLaybacks(castIndex)] = sourceBartlett(surfaces,searchRanges,sourceRanges, ...
        laybacks,positionTolerance,isTuningWindow);
    castScores(castIndex,:) = [mean(castWindowValues(isTuningWindow,castIndex)),mean(castWindowValues(~isTuningWindow,castIndex))];
end
[~,castOrder] = sort(castScores(:,1),'descend');
bestIndex = castOrder(1);

fprintf('\n  Bartlett at the source position (upper bound: tuning %.3f, held out %.3f)\n', ...
    mean(bartlettBounds(isTuningWindow)),mean(bartlettBounds(~isTuningWindow)));
fprintf('  %-8s %-22s %8s %9s %12s\n','cast','launch (UTC)','tuning','held out','layback [m]');
for castIndex = castOrder'
    fprintf('  %-8s %-22s %8.3f %9.3f %12d\n',castNames{castIndex},string(casts(castIndex).time,'yyyy-MM-dd HH:mm'), ...
        castScores(castIndex,1),castScores(castIndex,2),castLaybacks(castIndex));
end


%% 7. EOF Refinement of the Best Cast

castAnomalies = castSpeeds - mean(castSpeeds,2);
[eofs,singularValues] = svd(castAnomalies,'econ');
eofScales = diag(singularValues)/sqrt(numCasts-1);
scaledEofs = eofs(:,1:numEofs).*eofScales(1:numEofs)';
fprintf('\nvariance of the candidates explained by %d EOFs: %.0f%%\n',numEofs,100*sum(eofScales(1:numEofs).^2)/sum(eofScales.^2));

tuningMatrices = crossSpectralMatrices(:,:,:,isTuningWindow);
tuningSourceRanges = sourceRanges(isTuningWindow,:);
refinementObjective = @(coefficients) mean(sourceBartlett(evaluateSurfaces(castSpeeds(:,bestIndex) + scaledEofs*coefficients, ...
    bottomParameters,towDepths,tuningMatrices,environment),searchRanges,tuningSourceRanges,laybacks,positionTolerance,true(sum(isTuningWindow),1)));
eofCoefficients = coordinateDescent(refinementObjective,zeros(numEofs,1),-eofBound*ones(numEofs,1),eofBound*ones(numEofs,1), ...
    numPasses,numValuesPerSweep);
refinedSpeeds = castSpeeds(:,bestIndex) + scaledEofs*eofCoefficients;


%% 8. Validation on All Windows with the Full Depth Grid

profileNames = {baselineCastName;castNames{bestIndex};[castNames{bestIndex},' + EOFs']};
profileSpeeds = [castSpeeds(:,baselineIndex),castSpeeds(:,bestIndex),refinedSpeeds];
inTowBand = validationDepths >= towDepths(1) & validationDepths <= towDepths(end);
results = struct();
for profileIndex = 1:numel(profileNames)
    surfaces = evaluateSurfaces(profileSpeeds(:,profileIndex),bottomParameters,validationDepths,crossSpectralMatrices,environment);
    [sourceValues,layback] = sourceBartlett(surfaces(inTowBand,:,:),searchRanges,sourceRanges,laybacks,positionTolerance,isTuningWindow);
    [peakValues,peakIndexes] = max(reshape(surfaces,[],numWindows),[],1);
    [depthIndexes,rangeIndexes] = ind2sub([numel(validationDepths),numel(searchRanges)],peakIndexes);
    results(profileIndex).name = profileNames{profileIndex};
    results(profileIndex).layback = layback;
    results(profileIndex).sourceValues = sourceValues;
    results(profileIndex).sourceRanges = sourceRanges(:,laybacks == layback);
    results(profileIndex).peakValues = peakValues(:);
    results(profileIndex).peakRanges = searchRanges(rangeIndexes);
    results(profileIndex).peakDepths = validationDepths(depthIndexes);
    results(profileIndex).firstSurfaces = surfaces(:,:,[true;diff(windowFiles) ~= 0]);    % first window of each file
end

% the tuned bottom of tuneBottomMFP.m was tuned with the baseline profile
tunedBottomScores = nan(2,2);
if isfile(tunedBottomFile)
    tunedBottom = load(tunedBottomFile,'tunedParameters');
    for profileIndex = 1:2
        surfaces = evaluateSurfaces(profileSpeeds(:,profileIndex),tunedBottom.tunedParameters,towDepths,crossSpectralMatrices,environment);
        windowValues = sourceBartlett(surfaces,searchRanges,sourceRanges,laybacks,positionTolerance,isTuningWindow);
        tunedBottomScores(profileIndex,:) = [mean(windowValues(isTuningWindow)),mean(windowValues(~isTuningWindow))];
    end
end

fprintf('\n  mean Bartlett at the source position   tuning   held out   layback [m]\n');
for profileIndex = 1:numel(profileNames)
    fprintf('  %-36s %8.3f %10.3f %13d\n',profileNames{profileIndex},mean(results(profileIndex).sourceValues(isTuningWindow)), ...
        mean(results(profileIndex).sourceValues(~isTuningWindow)),results(profileIndex).layback);
end
fprintf('  %-36s %8.3f %10.3f\n','upper bound (largest eigenvalue)',mean(bartlettBounds(isTuningWindow)),mean(bartlettBounds(~isTuningWindow)));
if isfile(tunedBottomFile)
    for profileIndex = 1:2
        fprintf('  %-36s %8.3f %10.3f\n',[profileNames{profileIndex},', tuned bottom'],tunedBottomScores(profileIndex,:));
    end
end
fprintf('  EOF coefficients of the refinement: %s (largest change %.1f m/s)\n',mat2str(eofCoefficients',3), ...
    max(abs(refinedSpeeds-castSpeeds(:,bestIndex))));

referenceRanges = results(2).sourceRanges;
fprintf('\n  Time (UTC)     GPS range   %s: peak range, depth, Bartlett, at source   %s: peak range, depth, Bartlett, at source   bound\n', ...
    profileNames{1},profileNames{2});
for windowIndex = 1:numWindows
    tuningMarker = ' ';
    if isTuningWindow(windowIndex)
        tuningMarker = '*';
    end
    fprintf('  %s %s %9.0f %14.0f %6.0f %8.3f %8.3f %21.0f %6.0f %8.3f %8.3f %21.3f\n',string(windowTimes(windowIndex),'HH:mm:ss'), ...
        tuningMarker,referenceRanges(windowIndex),results(1).peakRanges(windowIndex),results(1).peakDepths(windowIndex), ...
        results(1).peakValues(windowIndex),results(1).sourceValues(windowIndex),results(2).peakRanges(windowIndex), ...
        results(2).peakDepths(windowIndex),results(2).peakValues(windowIndex),results(2).sourceValues(windowIndex),bartlettBounds(windowIndex));
end
fprintf('  (* tuning window; GPS range for the layback of %s)\n',profileNames{2});
for profileIndex = 1:2
    nearSource = abs(results(profileIndex).peakRanges - referenceRanges) <= 200 & ...
        results(profileIndex).peakDepths >= towDepths(1) & results(profileIndex).peakDepths <= towDepths(end);
    fprintf('  %s: global peak within 200 m of the GPS range and in the tow-depth band in %d of %d windows\n', ...
        profileNames{profileIndex},sum(nearSource),numWindows);
end

if ~isfolder(resultsFolder)
    mkdir(resultsFolder);
end
sspDepths = environment.sspDepths;
selectedCastName = castNames{bestIndex};
selectedSpeeds = castSpeeds(:,bestIndex);
profileResults = rmfield(results,'firstSurfaces');
save(fullfile(resultsFolder,'soundSpeedSelection.mat'),'sspDepths','castNames','castSpeeds','casts','castScores', ...
    'castLaybacks','castWindowValues','selectedCastName','selectedSpeeds','refinedSpeeds','eofCoefficients','scaledEofs', ...
    'profileNames','profileSpeeds','profileResults','tunedBottomScores','windowTimes','windowFiles','isTuningWindow', ...
    'sourceRanges','laybacks','bartlettBounds','bottomParameters');


%% 9. Visualization

profileColors = [0 0.35 0.8; 0.85 0.1 0.1; 0.95 0.55 0.1];

% plan view of the track and the casts, and the profiles
figure1 = figure('Name','Sound Speed Candidates','Color','w','Position',[100,100,1500,650]);
subplot(1,2,1);
metersPerDegreeLatitude = 111132.92 - 559.82*cosd(2*vlaLatitude) + 1.175*cosd(4*vlaLatitude);
metersPerDegreeLongitude = 111412.84*cosd(vlaLatitude) - 93.5*cosd(3*vlaLatitude);
castEast = ([casts.longitude]' - vlaLongitude)*metersPerDegreeLongitude/1000;
castNorth = ([casts.latitude]' - vlaLatitude)*metersPerDegreeLatitude/1000;
isCtd = startsWith(castNames,'CTD');
selectedLayback = results(2).layback;
plot(track.sourceEast(:,laybacks == selectedLayback)/1000,track.sourceNorth(:,laybacks == selectedLayback)/1000,'k.','MarkerSize',14); hold on
plot(track.fixEast/1000,track.fixNorth/1000,'k-');
plot(castEast(isCtd),castNorth(isCtd),'bs','MarkerFaceColor','b');
plot(castEast(~isCtd),castNorth(~isCtd),'mo');
plot(0,0,'r^','MarkerFaceColor','r','MarkerSize',10);
text(castEast,castNorth,strcat({'  '},castNames),'FontSize',8);
axis equal; grid on
xlabel('East of VLA1 [km]'); ylabel('North of VLA1 [km]');
legend(sprintf('source during the files (layback %d m)',selectedLayback),'ship track (XBT launches)','CTD','XBT','VLA1','Location','best');
title('Casts along the 200 m contour');
subplot(1,2,2);
plot(castSpeeds,environment.sspDepths,'Color',[0.75 0.75 0.75]); hold on
profileHandles = gobjects(3,1);
for profileIndex = 1:3
    profileHandles(profileIndex) = plot(profileSpeeds(:,profileIndex),environment.sspDepths,'Color',profileColors(profileIndex,:),'LineWidth',2);
end
profileHandles(3).LineStyle = '--';
set(gca,'YDir','reverse'); ylim([0 waterDepth]); grid on
xlabel('Sound speed [m/s]'); ylabel('Depth [m]');
legend(profileHandles,profileNames,'Location','southwest');
title('Candidate profiles (gray), baseline, and selection');
print(figure1,fullfile(resultsFolder,'SSP_candidates.png'),'-dpng','-r150');

% score of each cast
figure2 = figure('Name','Sound Speed Scores','Color','w','Position',[150,150,1100,500]);
bar(categorical(castNames(castOrder),castNames(castOrder)),castScores(castOrder,:)); hold on
yline(mean(bartlettBounds(isTuningWindow)),'k--','upper bound (tuning)','LabelHorizontalAlignment','left');
ylabel('Mean Bartlett at the source position'); grid on
legend('tuning files','held-out files','Location','northeast');
title(sprintf('Candidate profiles with the seabed of MFP.m (baseline %s, ranked on the tuning files)',baselineCastName));
print(figure2,fullfile(resultsFolder,'SSP_scores.png'),'-dpng','-r150');

% MFP peak and Bartlett value at the source position over time
figure3 = figure('Name','MFP with Selected Profile','Color','w','Position',[200,200,1000,850]);
subplot(3,1,1);
plot(windowTimes,referenceRanges/1000,'k_','MarkerSize',14,'LineWidth',2); hold on
plot(windowTimes,results(1).peakRanges/1000,'o','Color',profileColors(1,:));
plot(windowTimes,results(2).peakRanges/1000,'o','Color',profileColors(2,:),'MarkerFaceColor',profileColors(2,:));
ylabel('Range [km]'); grid on
legend('GPS source range',[profileNames{1},' peak'],[profileNames{2},' peak'],'Location','best');
title('Incoherent MFP peak vs. GPS-derived source position');
subplot(3,1,2);
plot(windowTimes,results(1).peakDepths,'o','Color',profileColors(1,:)); hold on
plot(windowTimes,results(2).peakDepths,'o','Color',profileColors(2,:),'MarkerFaceColor',profileColors(2,:));
yregion(towDepths(1),towDepths(end),'FaceColor',[0.85 0.85 0.85]);
set(gca,'YDir','reverse'); ylim([0 waterDepth]); grid on
ylabel('Peak depth [m]');
subplot(3,1,3);
plot(windowTimes,bartlettBounds,'k_','MarkerSize',14,'LineWidth',2); hold on
plot(windowTimes,results(1).sourceValues,'o','Color',profileColors(1,:));
plot(windowTimes,results(2).sourceValues,'o','Color',profileColors(2,:),'MarkerFaceColor',profileColors(2,:));
plot(windowTimes(isTuningWindow),results(2).sourceValues(isTuningWindow),'ks','MarkerSize',11);
ylim([0 1]); grid on
ylabel('Bartlett at source'); xlabel('Time (UTC), JD 147');
legend('upper bound',profileNames{1},profileNames{2},'tuning windows','Location','best');
print(figure3,fullfile(resultsFolder,'SSP_track.png'),'-dpng','-r150');

% surfaces of the first window of each file with the GPS source position
figure4 = figure('Name','MFP Surfaces with Selected Profile','Color','w','Position',[250,250,1400,800]);
firstWindows = find([true;diff(windowFiles) ~= 0]);
colorLimit = max(max(results(1).firstSurfaces,[],'all'),max(results(2).firstSurfaces,[],'all'));
for fileIndex = 1:numel(firstWindows)
    windowIndex = firstWindows(fileIndex);
    for profileIndex = 1:2
        subplot(2,numel(firstWindows),(profileIndex-1)*numel(firstWindows)+fileIndex);
        imagesc(searchRanges/1000,validationDepths,results(profileIndex).firstSurfaces(:,:,fileIndex)); caxis([0 colorLimit]); hold on
        plot(referenceRanges(windowIndex)/1000,mean(towDepths),'wx','MarkerSize',12,'LineWidth',2);
        plot(results(profileIndex).peakRanges(windowIndex)/1000,results(profileIndex).peakDepths(windowIndex),'wo','MarkerSize',9,'LineWidth',1.5);
        title(sprintf('%s %s',string(windowTimes(windowIndex),'HH:mm'),profileNames{profileIndex}));
        xlabel('Range [km]'); ylabel('Depth [m]');
    end
end
colorbar('Position',[0.93 0.11 0.012 0.8]);
sgtitle('Incoherent Bartlett MFP, first window of each file (x: GPS source position at 120 m, o: peak)');
print(figure4,fullfile(resultsFolder,'SSP_surfaces.png'),'-dpng','-r150');


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


function surfaces = evaluateSurfaces(sspSpeeds,bottomParameters,searchDepths,crossSpectralMatrices,environment)
% incoherent Bartlett surfaces (depths x ranges x windows) for a profile and a bottom

[sediment,halfspace] = getBottom(bottomParameters);
numTones = numel(environment.toneFrequencies);
numWindows = size(crossSpectralMatrices,4);
modeDepths = unique(round([environment.hydrophoneDepths;searchDepths],3));
surfaces = zeros(numel(searchDepths),numel(environment.searchRanges),numWindows);
for toneIndex = 1:numTones
    modes = computeModesMFP(environment.toneFrequencies(toneIndex),modeDepths,environment.waterDepth,environment.sspDepths, ...
        sspSpeeds,sediment,halfspace,environment.krakenPath);
    replicas = computeReplicasMFP(modes,environment.hydrophoneDepths,environment.hydrophoneOffsets,searchDepths,environment.searchRanges);
    for windowIndex = 1:numWindows
        bartlett = real(sum(conj(replicas).*(crossSpectralMatrices(:,:,toneIndex,windowIndex)*replicas),1));
        surfaces(:,:,windowIndex) = surfaces(:,:,windowIndex) + reshape(bartlett,numel(searchDepths),[])/numTones;
    end
end

end


function [windowValues,layback] = sourceBartlett(surfaces,searchRanges,sourceRanges,laybacks,positionTolerance,isTuningWindow)
% highest Bartlett value of each window within positionTolerance of the source
% range (and at any depth of the surfaces); the layback maximizes the mean over
% the tuning windows

rangeProfiles = reshape(max(surfaces,[],1),size(surfaces,2),size(surfaces,3));     % ranges x windows
values = zeros(size(surfaces,3),numel(laybacks));
for windowIndex = 1:size(surfaces,3)
    for laybackIndex = 1:numel(laybacks)
        nearSource = abs(searchRanges - sourceRanges(windowIndex,laybackIndex)) <= positionTolerance;
        values(windowIndex,laybackIndex) = max(rangeProfiles(nearSource,windowIndex));
    end
end
[~,bestIndex] = max(mean(values(isTuningWindow,:),1));
layback = laybacks(bestIndex);
windowValues = values(:,bestIndex);

end


function parameters = coordinateDescent(objective,parameters,lowerBounds,upperBounds,numPasses,numValuesPerSweep)
% maximizes the objective one parameter at a time; each pass sweeps every
% parameter over numValuesPerSweep values, and the sweep interval is halved
% after each pass

currentObjective = objective(parameters);
fprintf('initial objective: %.4f\n',currentObjective);
for passIndex = 1:numPasses
    halfWidths = (upperBounds-lowerBounds)/2/2^(passIndex-1);
    for parameterIndex = 1:numel(parameters)
        values = linspace(max(lowerBounds(parameterIndex),parameters(parameterIndex)-halfWidths(parameterIndex)), ...
            min(upperBounds(parameterIndex),parameters(parameterIndex)+halfWidths(parameterIndex)),numValuesPerSweep)';
        values = unique([values;parameters(parameterIndex)]);
        objectives = zeros(size(values));
        for valueIndex = 1:numel(values)
            if values(valueIndex) == parameters(parameterIndex)
                objectives(valueIndex) = currentObjective;
                continue
            end
            candidate = parameters;
            candidate(parameterIndex) = values(valueIndex);
            objectives(valueIndex) = objective(candidate);
        end
        [bestObjective,bestIndex] = max(objectives);
        if bestObjective > currentObjective
            parameters(parameterIndex) = values(bestIndex);
            currentObjective = bestObjective;
        end
        fprintf('pass %d, coefficient %d = %+6.3f  objective %.4f\n',passIndex,parameterIndex,parameters(parameterIndex),currentObjective);
    end
end

end
