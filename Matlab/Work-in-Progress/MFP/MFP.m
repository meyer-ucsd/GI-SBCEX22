%% Matched-Field Processing of SBCEXP 2022 Shelf-Break Tonals
% Bartlett MFP of the five M71 tonals recorded on MPL VLA1 (200 m contour)
% during source tow Track 8 (JD 147, 1929Z-0000Z). The cross-spectral matrix
% is estimated over short windows, so that the source moves little within an
% estimate, and the processor steps through all files. The MFP peaks are
% compared with the source position derived from the ship's GPS.
% Based on the original MFP code by Yongsung Park (Matlab/MFP).

clear variables; close all; clc;

%% 1. Parameters

% data: 60 s SIO files with 16 channels, channel 1 = hydrophone 1 (deepest).
% The JD 147 files are from source tow Track 8 (tonals); the JD 148 files in
% the same folder are from Track 9 (LFM chirps) and contain no tonals.
dataFolder = fullfile(fileparts(mfilename('fullpath')),'..','..','Data','acoustic');
processedFolder = fullfile(fileparts(mfilename('fullpath')),'..','..','Data','processed');
fileNames = {'RAVA01.22147193000.sio';'RAVA01.22147203000.sio';'RAVA01.22147210000.sio'; ...
    'RAVA01.22147211000.sio';'RAVA01.22147212000.sio';'RAVA01.22147213000.sio'};
fs = 25000;                                   % sampling frequency [Hz]

% tonals and spectral analysis; 5 s windows (15 snapshots, source motion ~6 m)
% localize as reliably as 10 s windows at twice the time resolution, whereas
% 3 s windows (8 snapshots) give poorly estimated cross-spectral matrices and
% 20 s windows smear the moving source
toneFrequencies = [503;653;803;1003;1253];    % M71 tonals [Hz]
toneSearchHalfWidth = 3;                      % search for the Doppler-shifted tonal [Hz]
fftLength = 2^14;                             % 0.66 s snapshots, 1.53 Hz bins (rectangular window)
hopLength = fftLength/2;
averagingDuration = 5;                        % cross-spectral matrix averaging time [s]
displayFileIndex = 5;                         % file shown in Figure 1 (JD 147, 2120Z)
displayWindowIndex = 1;                       % averaging window of that file shown in Figure 1

% figures are saved here
resultsFolder = fullfile(fileparts(mfilename('fullpath')),'Results');

% VLA geometry (trip report, App. B.3 and Fig. B.3.3)
waterDepth = 200;                             % nominal water depth at VLA1 [m]
hydrophone1HeightAboveBottom = 5.5 + 1.75;    % anchor to lower float, lower float to hydrophone 1 [m]
hydrophoneSpacing = 3.75;                     % [m]
numHydrophones = 16;
arrayTilt = 0;                                % [deg], positive tilt leans the array away from the source

% sound speed profile: XBT #11 (JD 147, 2133Z, launched during the tow 3.4 km
% east of VLA1) with the salinity of CTD #16 (JD 147, 1312Z, at VLA1). Of all CTD
% and XBT casts along the 200 m contour it matches the data best at the source
% position (tuneSoundSpeedMFP.m); the earlier profile, CTD #20, was cast a day
% later at the west end of the track, where there is no cold pool.
sspCastType = 'XBT';
sspCastNumber = 11;
salinityCtdNumber = 16;

% seabed based on shelf-break sediment cores AC-18 to AC-23 (Ballard et al.,
% 2024, Fig. 13); the sediment thickness is an example value
sediment.thickness = 1.5;                     % [m]
sediment.speeds = [1550;1620];                % top and bottom [m/s]
sediment.densities = [1.60;1.80];             % top and bottom [g/cm^3]
sediment.attenuations = [0.30;0.55];          % top and bottom [dB/(m kHz)]
halfspace.speed = 1650;                       % sandy shelf-break sediment [m/s]
halfspace.density = 1.85;                     % [g/cm^3]
halfspace.attenuation = 0.65;                 % [dB/(m kHz)]

% source position: VLA1 position (trip report, Table 2), ship track from the
% GPS positions at the XBT launches during the tow (App. D), layback estimated
% by tuneSoundSpeedMFP.m, and nominal tow depth (App. F)
vlaLatitude = 40.048467;                      % [deg]
vlaLongitude = -70.884167;                    % [deg]
trackXbtNumbers = (9:11)';                    % JD 147 1932Z, 2033Z, 2133Z
layback = 180;                                % source behind the ship along the track [m]
towDepth = 120;                               % [m]
towDepthBand = [100,140];                     % depths searched for the source [m]
positionTolerance = 50;                       % ranges searched around the GPS range [m]

% search grid
searchRanges = (500:10:6000)';                % [m]
searchDepths = (1:1:199)';                    % [m]

% Acoustics Toolbox (read_modes and kraken.exe), added only if not on the path
atPath = fullfile(getenv('HOME'),'Desktop','Matlab','at');


%% 2. Acoustics Toolbox

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


%% 3. Array Geometry and Sound Speed Profile

hydrophoneHeights = hydrophoneSpacing*(0:numHydrophones-1)';    % above hydrophone 1
hydrophoneDepths = waterDepth - hydrophone1HeightAboveBottom - hydrophoneHeights*cosd(arrayTilt);
hydrophoneOffsets = hydrophoneHeights*sind(arrayTilt);           % added to the source range
modeDepths = unique(round([hydrophoneDepths;searchDepths],3));

% 1 m depth bins; above the shallowest and below the deepest sample the
% profile is held constant
sspDepths = (0:1:waterDepth)';
[~,salinityCast] = readSoundSpeedCastMFP(processedFolder,'CTD',salinityCtdNumber,sspDepths);
sspSpeeds = readSoundSpeedCastMFP(processedFolder,sspCastType,sspCastNumber,sspDepths,salinityCast.salinity);


%% 4. Replica Fields

numTones = numel(toneFrequencies);
numDepths = numel(searchDepths);
numRanges = numel(searchRanges);
replicas = cell(numTones,1);
for toneIndex = 1:numTones
    fprintf('Computing replicas: %d Hz (%d/%d)\n',toneFrequencies(toneIndex),toneIndex,numTones);
    modes = computeModesMFP(toneFrequencies(toneIndex),modeDepths,waterDepth,sspDepths,sspSpeeds,sediment,halfspace,krakenPath);
    replicas{toneIndex} = computeReplicasMFP(modes,hydrophoneDepths,hydrophoneOffsets,searchDepths,searchRanges);
end


%% 5. Bartlett MFP for Each Averaging Window of Each File

% Bartlett values are normalized correlations between 0 and 1: unit-norm
% snapshots, cross-spectral matrix with unit trace, and unit-norm replicas. No
% replica can exceed the largest eigenvalue of the cross-spectral matrix, which
% is below 1 when the field changes within the window (the cap).
numFiles = numel(fileNames);
framesPerWindow = max(1,round(averagingDuration*fs/hopLength));

windowTimes = NaT(0,1);
windowFiles = zeros(0,1);
peakValues = zeros(0,1);
peakRanges = zeros(0,1);
peakDepths = zeros(0,1);
bartlettCaps = zeros(0,1);
selectedFrequencies = zeros(0,numTones);
incoherentSurfaces = zeros(numDepths,numRanges,0);
bartlettSurfaces = zeros(numDepths,numRanges,numTones);         % display window

for fileIndex = 1:numFiles

    % start time from the file name (RAVA01.YYDDDHHMMSS.sio)
    timeTokens = regexp(fileNames{fileIndex},'\.(\d{2})(\d{3})(\d{2})(\d{2})(\d{2})\.sio$','tokens','once');
    timeValues = str2double(timeTokens);
    fileStart = datetime(2000+timeValues(1),1,timeValues(2),timeValues(3),timeValues(4),timeValues(5));    % UTC

    [crossSpectralMatrices,fileFrequencies,fileWindowTimes] = getToneCrossSpectraMFP(fullfile(dataFolder,fileNames{fileIndex}), ...
        numHydrophones,fs,fftLength,toneFrequencies,toneSearchHalfWidth,framesPerWindow);
    numWindows = size(crossSpectralMatrices,4);
    fprintf('%s: %d averaging windows of %d snapshots (%.1f s)\n', ...
        fileNames{fileIndex},numWindows,framesPerWindow,framesPerWindow*hopLength/fs);

    for windowIndex = 1:numWindows
        incoherentSurface = zeros(numDepths,numRanges);
        bartlettCap = 0;

        for toneIndex = 1:numTones
            crossSpectralMatrix = crossSpectralMatrices(:,:,toneIndex,windowIndex);
            bartlett = real(sum(conj(replicas{toneIndex}).*(crossSpectralMatrix*replicas{toneIndex}),1));
            bartlett = reshape(bartlett,numDepths,numRanges);
            incoherentSurface = incoherentSurface + bartlett/numTones;
            bartlettCap = bartlettCap + max(real(eig(crossSpectralMatrix)))/numTones;
            if fileIndex == displayFileIndex && windowIndex == displayWindowIndex
                bartlettSurfaces(:,:,toneIndex) = bartlett;
            end
        end

        [peakValue,peakIndex] = max(incoherentSurface(:));
        [depthIndex,rangeIndex] = ind2sub([numDepths,numRanges],peakIndex);

        windowTimes(end+1,1) = fileStart + seconds(fileWindowTimes(windowIndex)); %#ok<SAGROW>
        windowFiles(end+1,1) = fileIndex; %#ok<SAGROW>
        peakValues(end+1,1) = peakValue; %#ok<SAGROW>
        peakRanges(end+1,1) = searchRanges(rangeIndex); %#ok<SAGROW>
        peakDepths(end+1,1) = searchDepths(depthIndex); %#ok<SAGROW>
        bartlettCaps(end+1,1) = bartlettCap; %#ok<SAGROW>
        selectedFrequencies(end+1,:) = fileFrequencies(windowIndex,:); %#ok<SAGROW>
        incoherentSurfaces(:,:,end+1) = incoherentSurface; %#ok<SAGROW>
    end
end

displayIndex = find(windowFiles == displayFileIndex,displayWindowIndex);
displayIndex = displayIndex(end);


%% 6. Comparison with the GPS-Derived Source Position

trackTimes = NaT(numel(trackXbtNumbers),1);
trackLatitudes = zeros(numel(trackXbtNumbers),1);
trackLongitudes = zeros(numel(trackXbtNumbers),1);
for xbtIndex = 1:numel(trackXbtNumbers)
    [~,xbtCast] = readSoundSpeedCastMFP(processedFolder,'XBT',trackXbtNumbers(xbtIndex),sspDepths,salinityCast.salinity);
    trackTimes(xbtIndex) = xbtCast.time;
    trackLatitudes(xbtIndex) = xbtCast.latitude;
    trackLongitudes(xbtIndex) = xbtCast.longitude;
end
sourceRanges = getSourceTrackMFP(windowTimes,layback,trackTimes,trackLatitudes,trackLongitudes,vlaLatitude,vlaLongitude);

% highest Bartlett value near the source position, and whether the peak of the
% whole panelSurface lies there (within 200 m of the GPS range and in the depth band)
inDepthBand = searchDepths >= towDepthBand(1) & searchDepths <= towDepthBand(2);
sourceValues = zeros(numel(windowTimes),1);
for windowIndex = 1:numel(windowTimes)
    nearSource = abs(searchRanges - sourceRanges(windowIndex)) <= positionTolerance;
    sourceValues(windowIndex) = max(incoherentSurfaces(inDepthBand,nearSource,windowIndex),[],'all');
end
isOnTarget = abs(peakRanges - sourceRanges) <= 200 & peakDepths >= towDepthBand(1) & peakDepths <= towDepthBand(2);

fprintf('\n  Time (UTC)   GPS range [m]   Peak range [m]   Peak depth [m]   Peak Bartlett   At source   Cap\n')
for windowIndex = 1:numel(windowTimes)
    fprintf('  %s   %13.0f   %14.0f   %14.1f   %13.3f   %9.3f   %5.3f\n',string(windowTimes(windowIndex),'HH:mm:ss'), ...
        sourceRanges(windowIndex),peakRanges(windowIndex),peakDepths(windowIndex),peakValues(windowIndex), ...
        sourceValues(windowIndex),bartlettCaps(windowIndex));
end
fprintf('\n  File (UTC)   Peak on target   Mean Bartlett at source   Mean cap\n');
for fileIndex = 1:numFiles
    inFile = windowFiles == fileIndex;
    fprintf('  %s        %3d of %2d   %23.3f   %8.3f\n',string(windowTimes(find(inFile,1)),'HH:mm'), ...
        sum(isOnTarget(inFile)),sum(inFile),mean(sourceValues(inFile)),mean(bartlettCaps(inFile)));
end
fprintf('  all          %3d of %2d   %23.3f   %8.3f\n',sum(isOnTarget),numel(isOnTarget),mean(sourceValues),mean(bartlettCaps));


%% 7. Visualization

if ~isfolder(resultsFolder)
    mkdir(resultsFolder);
end
displayTime = string(windowTimes(displayIndex),'HH:mm:ss');
windowDuration = framesPerWindow*hopLength/fs;

figure1 = figure('Name','Multi-Frequency MFP & Incoherent Averaging','Color','w','Position',[100,100,1400,800]);
for toneIndex = 1:numTones+1
    subplot(2,3,toneIndex);
    if toneIndex <= numTones
        panelSurface = bartlettSurfaces(:,:,toneIndex);
        panelTitle = sprintf('%d Hz',toneFrequencies(toneIndex));
    else
        panelSurface = incoherentSurfaces(:,:,displayIndex);
        panelTitle = 'Incoherent Average';
    end
    [~,peakIndex] = max(panelSurface(:));
    [depthIndex,rangeIndex] = ind2sub(size(panelSurface),peakIndex);
    imagesc(searchRanges/1000,searchDepths,panelSurface);
    hold on
    plot(sourceRanges(displayIndex)/1000,towDepth,'wx','MarkerSize',12,'LineWidth',2);
    plot(searchRanges(rangeIndex)/1000,searchDepths(depthIndex),'wo','MarkerSize',10,'LineWidth',1.5);
    title(sprintf('%s (peak %.2f)',panelTitle,max(panelSurface(:))),'FontSize',14);
    xlabel('Range [km]','FontSize',11);
    ylabel('Depth [m]','FontSize',11);
    colorbar;
    caxis([0 max(max(panelSurface,[],'all'),eps)]);
    set(gca,'FontSize',12);
end
sgtitle(sprintf('Bartlett MFP, VLA1, JD 147 %s UTC (%.0f s average; x: GPS source position, o: peak)',displayTime,windowDuration));
print(figure1,fullfile(resultsFolder,'MFP_frequencies.png'),'-dpng','-r150');

figure2 = figure('Name','MFP Peak over Time','Color','w','Position',[150,150,1000,850]);
subplot(3,1,1);
plot(windowTimes,sourceRanges/1000,'k_','MarkerSize',10,'LineWidth',2);
hold on
plot(windowTimes(isOnTarget),peakRanges(isOnTarget)/1000,'ro','MarkerFaceColor','r');
plot(windowTimes(~isOnTarget),peakRanges(~isOnTarget)/1000,'ro');
ylabel('Range [km]'); grid on;
legend('GPS source range','peak at the source position','peak elsewhere','Location','north');
title(sprintf('Incoherent MFP peak, VLA1, Track 8 (%.0f s averaging, %d snapshots)',windowDuration,framesPerWindow));
subplot(3,1,2);
plot(windowTimes(isOnTarget),peakDepths(isOnTarget),'ro','MarkerFaceColor','r');
hold on
plot(windowTimes(~isOnTarget),peakDepths(~isOnTarget),'ro');
yregion(towDepthBand(1),towDepthBand(2),'FaceColor',[0.85 0.85 0.85]);
set(gca,'YDir','reverse'); ylim([0 waterDepth]);
ylabel('Peak depth [m]'); grid on;
subplot(3,1,3);
plot(windowTimes,bartlettCaps,'k_','MarkerSize',10,'LineWidth',2);
hold on
plot(windowTimes,peakValues,'r^');
plot(windowTimes,sourceValues,'ro','MarkerFaceColor','r');
ylim([0 1]);
xlabel('Time (UTC), JD 147'); ylabel('Bartlett'); grid on;
legend('cap (largest eigenvalue)','at peak','at GPS source position','Location','best');
print(figure2,fullfile(resultsFolder,'MFP_track.png'),'-dpng','-r150');

figure3 = figure('Name','Incoherent MFP per File','Color','w','Position',[200,200,1500,800]);
for fileIndex = 1:numFiles
    surfaceIndex = find(windowFiles == fileIndex,1);
    panelSurface = incoherentSurfaces(:,:,surfaceIndex);
    subplot(2,ceil(numFiles/2),fileIndex);
    imagesc(searchRanges/1000,searchDepths,panelSurface);
    hold on
    plot(sourceRanges(surfaceIndex)/1000,towDepth,'wx','MarkerSize',12,'LineWidth',2);
    plot(peakRanges(surfaceIndex)/1000,peakDepths(surfaceIndex),'wo','MarkerSize',10,'LineWidth',1.5);
    title(sprintf('%s: peak %.2f, at source %.2f, cap %.2f',string(windowTimes(surfaceIndex),'HH:mm:ss'), ...
        peakValues(surfaceIndex),sourceValues(surfaceIndex),bartlettCaps(surfaceIndex)),'FontSize',11);
    xlabel('Range [km]'); ylabel('Depth [m]');
    colorbar;
    caxis([0 max(max(panelSurface,[],'all'),eps)]);
end
sgtitle('Incoherent Bartlett MFP, first averaging window of each file (x: GPS source position, o: peak)');
print(figure3,fullfile(resultsFolder,'MFP_files.png'),'-dpng','-r150');
