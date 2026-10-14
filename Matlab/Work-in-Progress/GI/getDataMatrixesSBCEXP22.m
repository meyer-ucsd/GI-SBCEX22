function [dataMatrixes,selectedFrequencies] = getDataMatrixesSBCEXP22(fileName,windowStart,windowDuration,data)
% Cross-spectral matrices of the tonals for one averaging window of an SIO file,
% processed as in the MFP: snapshots of data.fftLength samples (rectangular
% window, 50% overlap), strongest bin within data.toneSearchHalfWidth of each
% tonal (Doppler shift), unit-norm snapshots, and averaging over the window.
% Channel 1 is hydrophone 1 (deepest), matching getReceiverGeometrySBCEXP22.

fs = data.samplingFrequency;
fftLength = data.fftLength;
hopLength = fftLength/2;
toneFrequencies = data.toneFrequencies(:);
numTones = numel(toneFrequencies);

% read only the samples of the averaging window
firstPoint = round(windowStart*fs) + 1;
numFrames = max(1,floor((round(windowDuration*fs)-fftLength)/hopLength) + 1);
numPoints = (numFrames-1)*hopLength + fftLength;
x = sioread(fileName,firstPoint,numPoints,1:data.numHydrophones);
x = x - mean(x,1);

% DFT bins within the search band of each tonal for every frame and hydrophone
binFrequencies = (0:fftLength-1)'*fs/fftLength;
candidateBins = cell(numTones,1);
toneSpectra = cell(numTones,1);
for toneIndex = 1:numTones
    candidateBins{toneIndex} = find(abs(binFrequencies-toneFrequencies(toneIndex)) <= data.toneSearchHalfWidth);
    toneSpectra{toneIndex} = zeros(numel(candidateBins{toneIndex}),data.numHydrophones,numFrames);
end
for frameIndex = 1:numFrames
    firstSample = (frameIndex-1)*hopLength + 1;
    frameSpectrum = fft(x(firstSample:firstSample+fftLength-1,:));
    for toneIndex = 1:numTones
        toneSpectra{toneIndex}(:,:,frameIndex) = frameSpectrum(candidateBins{toneIndex},:);
    end
end

dataMatrixes = zeros(data.numHydrophones,data.numHydrophones,numTones);
selectedFrequencies = zeros(numTones,1);
for toneIndex = 1:numTones
    [~,bestBin] = max(sum(abs(toneSpectra{toneIndex}).^2,[2,3]));
    selectedFrequencies(toneIndex) = binFrequencies(candidateBins{toneIndex}(bestBin));

    snapshots = reshape(toneSpectra{toneIndex}(bestBin,:,:),data.numHydrophones,numFrames);
    snapshots = snapshots./vecnorm(snapshots);
    dataMatrixes(:,:,toneIndex) = snapshots*snapshots'/numFrames;
end

end
