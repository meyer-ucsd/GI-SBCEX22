function [crossSpectralMatrices,selectedFrequencies,windowTimes] = getToneCrossSpectraMFP(filePath,numHydrophones,fs,fftLength,toneFrequencies,toneSearchHalfWidth,framesPerWindow)
% Cross-spectral matrices of the tonals for consecutive averaging windows of an
% SIO file: snapshots of fftLength samples (rectangular window, 50% overlap),
% strongest bin within toneSearchHalfWidth of each tonal (Doppler shift),
% unit-norm snapshots, and averaging over framesPerWindow snapshots.
% crossSpectralMatrices: hydrophones x hydrophones x tonals x windows
% selectedFrequencies:   windows x tonals [Hz]
% windowTimes:           window centers [s] since file start

hopLength = fftLength/2;
numTones = numel(toneFrequencies);

data = sioread(filePath,1,0,1:numHydrophones);
data = data - mean(data,1);

% DFT bins within the search band of each tonal for every frame and hydrophone
numFrames = floor((size(data,1)-fftLength)/hopLength) + 1;
frameTimes = ((0:numFrames-1)'*hopLength + fftLength/2)/fs;
binFrequencies = (0:fftLength-1)'*fs/fftLength;
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

numWindows = floor(numFrames/framesPerWindow);
crossSpectralMatrices = zeros(numHydrophones,numHydrophones,numTones,numWindows);
selectedFrequencies = zeros(numWindows,numTones);
windowTimes = zeros(numWindows,1);
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
        crossSpectralMatrices(:,:,toneIndex,windowIndex) = snapshots*snapshots'/size(snapshots,2);
    end
end

end
