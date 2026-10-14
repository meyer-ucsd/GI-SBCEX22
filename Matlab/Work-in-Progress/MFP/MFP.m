%% Matched-Field Processing of SBCEXP 2022 Shelf-Break Tonals
% Bartlett MFP of the five M71 tonals recorded on MPL VLA1 (200 m contour)
% during source tow Track 8 (JD 147, 1929Z-0000Z). The cross-spectral matrix
% is estimated over short windows, so that the source moves little within an
% estimate, and the processor steps through the whole file.

clear variables; close all; clc;

%% 1. Parameters

% data: SIO file with 16 channels, channel 1 = hydrophone 1 (deepest)
dataFolder = pwd;
fileName = 'RAVA01.22147212000.sio';
fs = 25000;                                   % sampling frequency [Hz]

% tonals and spectral analysis
toneFrequencies = [503;653;803;1003;1253];    % M71 tonals [Hz]
toneSearchHalfWidth = 3;                      % search for the Doppler-shifted tonal [Hz]
fftLength = 2^14;                             % 0.66 s snapshots, 1.53 Hz bins (rectangular window)
hopLength = fftLength/2;
averagingDuration = 10;                       % cross-spectral matrix averaging time [s]
displayWindowIndex = 1;                       % averaging window shown in Figure 1

% VLA geometry (trip report, App. B.3 and Fig. B.3.3)
waterDepth = 200;                             % nominal water depth at VLA1 [m]
hydrophone1HeightAboveBottom = 5.5 + 1.75;    % anchor to lower float, lower float to hydrophone 1 [m]
hydrophoneSpacing = 3.75;                     % [m]
numHydrophones = 16;
arrayTilt = 0;                                % [deg], positive tilt leans the array away from the source

% sound speed profile; CTD #20 was cast on JD 148 at 1828Z, about 21 hours
% after this file. CTD #18 (JD 147, 1812Z) or XBT #11 (JD 147, 2133Z) are
% closer in time and should replace it once available.
sspFile = 'SBCEXP22_ssp_ctd020.mat';

% seabed based on shelf-break sediment cores AC-18 to AC-23 (Ballard et al.,
% 2024, Fig. 13); the sediment thickness is an example value
sediment.thickness = 1.5;                     % [m]
sediment.speeds = [1550;1620];                % top and bottom [m/s]
sediment.densities = [1.60;1.80];             % top and bottom [g/cm^3]
sediment.attenuations = [0.30;0.55];          % top and bottom [dB/(m kHz)]
halfspace.speed = 1650;                       % sandy shelf-break sediment [m/s]
halfspace.density = 1.85;                     % [g/cm^3]
halfspace.attenuation = 0.65;                 % [dB/(m kHz)]

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

% downcast of the CTD; the shallowest and deepest measured values are held
% constant instead of extrapolated
ssp = load(sspFile);
[~,deepestIndex] = max(ssp.ctd_Depth);
[sspDepthsMeasured,uniqueIndexes] = unique(ssp.ctd_Depth(1:deepestIndex));
sspSpeedsMeasured = ssp.ctd_ssp(uniqueIndexes);
sspDepths = linspace(0,waterDepth,500)';
sspSpeeds = interp1(sspDepthsMeasured(:),sspSpeedsMeasured(:),sspDepths,'pchip',nan);
sspSpeeds(sspDepths < sspDepthsMeasured(1)) = sspSpeedsMeasured(1);
sspSpeeds(sspDepths > sspDepthsMeasured(end)) = sspSpeedsMeasured(end);


%% 4. Tonal Snapshots

data = sioread(fullfile(dataFolder,fileName),1,0,1:numHydrophones);
data = data - mean(data,1);

numTones = numel(toneFrequencies);
numFrames = floor((size(data,1)-fftLength)/hopLength) + 1;
frameTimes = ((0:numFrames-1)'*hopLength + fftLength/2)/fs;
binFrequencies = (0:fftLength-1)'*fs/fftLength;

% DFT bins within the search band of each tonal for every frame and hydrophone
candidateBins = cell(numTones,1);
toneSpectra = cell(numTones,1);
for toneIndex = 1:numTones
    candidateBins{toneIndex} = find(abs(binFrequencies-toneFrequencies(toneIndex)) <= toneSearchHalfWidth);
    toneSpectra{toneIndex} = zeros(numel(candidateBins{toneIndex}),numHydrophones,numFrames);
end
for frameIndex = 1:numFrames
    firstSample = (frameIndex-1)*hopLength + 1;
    frameSpectrum = fft(data(firstSample:firstSample+fftLength-1,:));
    for toneIndex = 1:numTones
        toneSpectra{toneIndex}(:,:,frameIndex) = frameSpectrum(candidateBins{toneIndex},:);
    end
end
clear data

framesPerWindow = max(1,round(averagingDuration*fs/hopLength));
numWindows = floor(numFrames/framesPerWindow);
fprintf('%d frames, %d averaging windows of %d snapshots (%.1f s)\n', ...
    numFrames,numWindows,framesPerWindow,framesPerWindow*hopLength/fs);


%% 5. Replica Fields

numDepths = numel(searchDepths);
numRanges = numel(searchRanges);
replicas = cell(numTones,1);
for toneIndex = 1:numTones
    fprintf('Computing replicas: %d Hz (%d/%d)\n',toneFrequencies(toneIndex),toneIndex,numTones);
    modes = computeModes(toneFrequencies(toneIndex),modeDepths,waterDepth,sspDepths,sspSpeeds,sediment,halfspace,krakenPath);
    replicas{toneIndex} = computeReplicas(modes,hydrophoneDepths,hydrophoneOffsets,searchDepths,searchRanges);
end


%% 6. Bartlett MFP for Each Averaging Window

% Bartlett values are normalized correlations between 0 and 1: unit-norm
% snapshots, cross-spectral matrix with unit trace, and unit-norm replicas
bartlettSurfaces = zeros(numDepths,numRanges,numTones);         % display window
incoherentSurfaces = zeros(numDepths,numRanges,numWindows);
selectedFrequencies = zeros(numWindows,numTones);
windowTimes = zeros(numWindows,1);
peakValues = zeros(numWindows,1);
peakRanges = zeros(numWindows,1);
peakDepths = zeros(numWindows,1);

for windowIndex = 1:numWindows
    frameIndexes = (windowIndex-1)*framesPerWindow + (1:framesPerWindow);
    windowTimes(windowIndex) = mean(frameTimes(frameIndexes));

    for toneIndex = 1:numTones

        % strongest bin within the search band (Doppler shift of the tonal)
        windowSpectra = toneSpectra{toneIndex}(:,:,frameIndexes);
        [~,bestBin] = max(sum(abs(windowSpectra).^2,[2,3]));
        selectedFrequencies(windowIndex,toneIndex) = binFrequencies(candidateBins{toneIndex}(bestBin));

        snapshots = reshape(windowSpectra(bestBin,:,:),numHydrophones,[]);
        snapshots = snapshots./vecnorm(snapshots);
        crossSpectralMatrix = snapshots*snapshots'/size(snapshots,2);

        bartlett = real(sum(conj(replicas{toneIndex}).*(crossSpectralMatrix*replicas{toneIndex}),1));
        bartlett = reshape(bartlett,numDepths,numRanges);
        incoherentSurfaces(:,:,windowIndex) = incoherentSurfaces(:,:,windowIndex) + bartlett/numTones;
        if windowIndex == displayWindowIndex
            bartlettSurfaces(:,:,toneIndex) = bartlett;
        end
    end

    currentSurface = incoherentSurfaces(:,:,windowIndex);
    [peakValues(windowIndex),peakIndex] = max(currentSurface(:));
    [depthIndex,rangeIndex] = ind2sub([numDepths,numRanges],peakIndex);
    peakDepths(windowIndex) = searchDepths(depthIndex);
    peakRanges(windowIndex) = searchRanges(rangeIndex);
end

fprintf('\n  Time [s]   Range [m]   Depth [m]   Bartlett\n')
fprintf('  %8.1f   %9.0f   %9.1f   %8.3f\n',[windowTimes,peakRanges,peakDepths,peakValues]')


%% 7. Visualization

figure('Name','Multi-Frequency MFP & Incoherent Averaging','Color','w','Position',[100,100,1400,800]);
for toneIndex = 1:numTones
    subplot(2,3,toneIndex);
    imagesc(searchRanges/1000,searchDepths,bartlettSurfaces(:,:,toneIndex));
    title(sprintf('%d Hz',toneFrequencies(toneIndex)),'FontSize',14);
    xlabel('Range [km]','FontSize',11);
    ylabel('Depth [m]','FontSize',11);
    colorbar;
    caxis([0 1]);
    set(gca,'FontSize',12);
end
subplot(2,3,6);
imagesc(searchRanges/1000,searchDepths,incoherentSurfaces(:,:,displayWindowIndex));
hold on
plot(peakRanges(displayWindowIndex)/1000,peakDepths(displayWindowIndex),'wo','MarkerSize',10,'LineWidth',1.5);
title(sprintf('Incoherent Average (t = %.0f s)',windowTimes(displayWindowIndex)),'FontSize',14,'FontWeight','bold');
xlabel('Range [km]','FontSize',11);
ylabel('Depth [m]','FontSize',11);
colorbar;
caxis([0 1]);
set(gca,'FontSize',12);

figure('Name','MFP Peak over Time','Color','w','Position',[150,150,900,800]);
subplot(3,1,1);
plot(windowTimes,peakRanges/1000,'ko-','MarkerFaceColor','k');
ylabel('Range [km]'); grid on;
title(sprintf('Incoherent MFP Peak (%.0f s averaging)',framesPerWindow*hopLength/fs));
subplot(3,1,2);
plot(windowTimes,peakDepths,'ko-','MarkerFaceColor','k');
set(gca,'YDir','reverse');
ylabel('Depth [m]'); grid on;
subplot(3,1,3);
plot(windowTimes,peakValues,'ko-','MarkerFaceColor','k');
ylim([0 1]);
xlabel('Time since file start [s]'); ylabel('Bartlett'); grid on;


%% Local Functions

function modes = computeModes(frequency,modeDepths,waterDepth,sspDepths,sspSpeeds,sediment,halfspace,krakenPath)

% read_modes only reads from the current folder
fileRoot = 'mfpKraken';
writeKrakenEnv([fileRoot,'.env'],frequency,waterDepth,sspDepths,sspSpeeds,sediment,halfspace,modeDepths(1),modeDepths);

if isfile([fileRoot,'.mod'])
    delete([fileRoot,'.mod']);
end
[status,output] = system(['"',krakenPath,'" ',fileRoot]);
if status ~= 0 || ~isfile([fileRoot,'.mod'])
    error('KRAKEN failed at %g Hz (exit code %d):\n%s',frequency,status,output);
end

clear read_modes_bin    % rewind the mode-file reader
modes = read_modes([fileRoot,'.mod'],frequency);
fclose('all');
delete([fileRoot,'.*']);

end


function replicas = computeReplicas(modes,hydrophoneDepths,hydrophoneOffsets,searchDepths,searchRanges)

modeDepths = double(modes.z(:));
k = double(modes.k(:));
phi = double(modes.phi);
phiHydrophones = phi(findDepthRows(modeDepths,hydrophoneDepths),:);
phiSearch = phi(findDepthRows(modeDepths,searchDepths),:);

numHydrophones = numel(hydrophoneDepths);
numDepths = numel(searchDepths);
numRanges = numel(searchRanges);
replicas = zeros(numHydrophones,numDepths,numRanges);

% the Hankel functions depend only on range, so they are computed once per
% distinct hydrophone range offset (once in total for an untilted array)
[uniqueOffsets,~,offsetIndexes] = unique(hydrophoneOffsets);
for offsetIndex = 1:numel(uniqueOffsets)
    hankel = besselh(0,2,k*(searchRanges(:)'+uniqueOffsets(offsetIndex)));
    for hydrophoneIndex = find(offsetIndexes == offsetIndex)'
        replicas(hydrophoneIndex,:,:) = reshape((phiSearch.*phiHydrophones(hydrophoneIndex,:))*hankel,[1,numDepths,numRanges]);
    end
end

replicas = reshape(replicas,numHydrophones,[]);
replicas = replicas./vecnorm(replicas);

end


function rows = findDepthRows(modeDepths,depths)

[distances,rows] = min(abs(modeDepths-depths(:)'),[],1);
if any(distances > 2e-3)
    error('KRAKEN did not return modes at all requested depths');
end
rows = rows(:);

end
