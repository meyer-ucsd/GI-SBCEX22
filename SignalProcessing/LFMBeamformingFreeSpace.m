% Florian Meyer, July 2026

clear variables; close all; clc; rng(1)

%% General Parameters

scenario.soundSpeed = 1500;                   % in m/s
scenario.samplingFrequency = 25000;           % in Hz
scenario.snrDb = 0;                           % per-receiver in-band SNR in dB

scenario.sourceHorizontalRange = 2000;         % in meters
scenario.sourceDepth = 20;                    % in meters
scenario.sourcePressureAtOneMeter = 1;        % arbitrary pressure unit

scenario.bandLFM = [1500;4500];               % start and stop frequencies in Hz
scenario.durationLFM = 1;                     % in seconds
scenario.taperFractionLFM = 0.02;             % raised-cosine duration at each end

% The default VLA is unaliased over the LFM band and is in the far field at
% the selected source range. The original 3.75 m-spaced VLA can be selected
% to illustrate spatial aliasing, but it requires approximately 19 km range
% to satisfy the conservative far-field criterion.
scenario.useOriginalSparseVLA = true;
if scenario.useOriginalSparseVLA
    scenario.receiverDepths = (67.75:-3.75:11.5)';
else
    receiverCenterDepth = mean([11.5;67.75]);
    numReceivers = 16;
    receiverSpacing = 0.15;
    receiverIndexes = (0:numReceivers-1)' - (numReceivers-1)/2;
    scenario.receiverDepths = receiverCenterDepth + receiverSpacing*receiverIndexes;
end

scenario.steeringAngles = (-75:0.25:75)';     % degrees from horizontal, positive downward
scenario.preArrivalDuration = 0.02;           % recording margin in seconds
scenario.postArrivalDuration = 0.02;          % recording margin in seconds
scenario.fractionalDelayOrder = 8;            % Lagrange fractional-delay filter order

numReceivers = size(scenario.receiverDepths,1);
receiverReferenceDepth = mean(scenario.receiverDepths);
receiverRelativeDepths = scenario.receiverDepths - receiverReferenceDepth;
arrayAperture = max(scenario.receiverDepths) - min(scenario.receiverDepths);

assert(scenario.bandLFM(2) < scenario.samplingFrequency/2, ...
    'The sampling frequency must exceed twice the highest LFM frequency.')
assert(scenario.fractionalDelayOrder >= 1 && ...
    mod(scenario.fractionalDelayOrder,1) == 0, ...
    'fractionalDelayOrder must be a positive integer.')

lambdaMinimum = scenario.soundSpeed/scenario.bandLFM(2);
maximumAliasFreeSpacing = lambdaMinimum/2;
receiverSpacings = diff(sort(scenario.receiverDepths));
maximumReceiverSpacing = max(receiverSpacings);
fraunhoferDistance = 2*arrayAperture^2/lambdaMinimum;

if maximumReceiverSpacing > maximumAliasFreeSpacing
    warning(['The maximum receiver spacing is %.3f m, but the full-sector alias-free limit ' ...
        'at %.1f Hz is %.3f m. Grating lobes are expected.'], ...
        maximumReceiverSpacing,scenario.bandLFM(2),maximumAliasFreeSpacing)
end

%% Generate Free-Space Source Waveform

sourceTime = (0:1/scenario.samplingFrequency: ...
    scenario.durationLFM-1/scenario.samplingFrequency)';
sourceSignal = generateLFM(sourceTime,scenario.bandLFM, ...
    scenario.durationLFM,scenario.taperFractionLFM);

%% Compute Free-Space Far-Field Propagation

sourceRange = hypot(scenario.sourceHorizontalRange, ...
    scenario.sourceDepth-receiverReferenceDepth);
sourceTravelTime = sourceRange/scenario.soundSpeed;
sourceLookAngle = atan2d(scenario.sourceDepth-receiverReferenceDepth, ...
    scenario.sourceHorizontalRange);

exactPathLengths = hypot(scenario.sourceHorizontalRange, ...
    scenario.sourceDepth-scenario.receiverDepths);
farFieldPathLengths = sourceRange - receiverRelativeDepths*sind(sourceLookAngle);
arrivalDelayOffsets = -receiverRelativeDepths*sind(sourceLookAngle)/ ...
    scenario.soundSpeed;

maximumPathLengthError = max(abs(exactPathLengths-farFieldPathLengths));
maximumPhaseErrorDegrees = 360*scenario.bandLFM(2)* ...
    maximumPathLengthError/scenario.soundSpeed;
sourceAmplitude = scenario.sourcePressureAtOneMeter/sourceRange;

if sourceRange < fraunhoferDistance
    warning(['The source range is %.1f m, below the conservative far-field distance ' ...
        'of %.1f m. Increase sourceHorizontalRange or reduce the VLA aperture.'], ...
        sourceRange,fraunhoferDistance)
end
if maximumPhaseErrorDegrees > 22.5
    warning(['The plane-wave approximation produces %.1f degrees of phase error ' ...
        'at %.1f Hz across the VLA.'], ...
        maximumPhaseErrorDegrees,scenario.bandLFM(2))
end

fprintf('\nFree-space far-field LFM simulation\n')
fprintf('  Source range at array center: %.3f m\n',sourceRange)
fprintf('  Source look angle:            %.3f degrees\n',sourceLookAngle)
fprintf('  VLA aperture:                 %.3f m\n',arrayAperture)
fprintf('  Maximum receiver spacing:    %.3f m\n',maximumReceiverSpacing)
fprintf('  Alias-free spacing at f_max: %.3f m\n',maximumAliasFreeSpacing)
fprintf('  Conservative far-field range: %.3f m\n',fraunhoferDistance)
fprintf('  Maximum plane-wave error:    %.3f mm (%.3f degrees at f_max)\n\n', ...
    1000*maximumPathLengthError,maximumPhaseErrorDegrees)

%% Generate the Waveform at Each Receiver Array Element

receiverArrivalTimes = farFieldPathLengths/scenario.soundSpeed;
recordingStartTime = max(0,min(receiverArrivalTimes)-scenario.preArrivalDuration);
recordingEndTime = max(receiverArrivalTimes) + scenario.durationLFM + ...
    scenario.postArrivalDuration;
numTimeSamples = ceil((recordingEndTime-recordingStartTime)* ...
    scenario.samplingFrequency) + 1;
time = recordingStartTime + (0:numTimeSamples-1)'/scenario.samplingFrequency;

receiverSignalsNoiseless = zeros(numReceivers,numTimeSamples);
for receiverIndex = 1:numReceivers
    retardedTime = time-receiverArrivalTimes(receiverIndex);
    receiverSignalsNoiseless(receiverIndex,:) = sourceAmplitude*generateLFM( ...
        retardedTime,scenario.bandLFM,scenario.durationLFM, ...
        scenario.taperFractionLFM)';
end

receiverNoise = randn(numReceivers,numTimeSamples);
receiverNoise = bandLimitSignals(receiverNoise,scenario.samplingFrequency, ...
    scenario.bandLFM);
signalPower = mean(receiverSignalsNoiseless(:).^2);
desiredNoisePower = signalPower/(10^(scenario.snrDb/10));
receiverNoise = receiverNoise*sqrt(desiredNoisePower/mean(receiverNoise(:).^2));
receiverSignals = receiverSignalsNoiseless + receiverNoise;

[~,referenceReceiverIndex] = min(abs(receiverRelativeDepths));

%% Perform Far-Field True-Time-Delay Beamforming

% d_n(theta) is the arrival delay relative to the array reference. The
% nonnegative delays below postpone early channels until all signals align.
beamformerDelays = max(arrivalDelayOffsets) - arrivalDelayOffsets;
beamformerDelaySamples = beamformerDelays*scenario.samplingFrequency;

alignedSignalsNoiseless = applyFractionalDelays(receiverSignalsNoiseless, ...
    beamformerDelaySamples,scenario.fractionalDelayOrder);
alignedNoise = applyFractionalDelays(receiverNoise,beamformerDelaySamples, ...
    scenario.fractionalDelayOrder);
alignedReceiverSignals = alignedSignalsNoiseless + alignedNoise;

arrayWeights = ones(numReceivers,1)/numReceivers;
beamformerOutputNoiseless = (arrayWeights'*alignedSignalsNoiseless)';
beamformerNoise = (arrayWeights'*alignedNoise)';
beamformerOutput = beamformerOutputNoiseless + beamformerNoise;

directBeamArrivalTime = sourceTravelTime + max(arrivalDelayOffsets);
beamformerTime = time-directBeamArrivalTime;

inputSnrDb = 10*log10(mean(receiverSignalsNoiseless(:).^2)/ ...
    mean(receiverNoise(:).^2));
outputSnrDb = 10*log10(mean(beamformerOutputNoiseless.^2)/ ...
    mean(beamformerNoise.^2));
measuredArrayGainDb = outputSnrDb-inputSnrDb;
expectedArrayGainDb = 10*log10(numReceivers);

fprintf('  Measured input SNR:           %.3f dB\n',inputSnrDb)
fprintf('  Measured beamformer SNR:      %.3f dB\n',outputSnrDb)
fprintf('  Measured spatial SNR gain:    %.3f dB\n',measuredArrayGainDb)
fprintf('  Ideal spatial SNR gain:       %.3f dB\n\n',expectedArrayGainDb)

%% Apply LFM Matched Filter

[matchedFilterOutput,matchedFilterLags] = applyMatchedFilter( ...
    beamformerOutput,sourceSignal);
referenceSignal = alignedReceiverSignals(referenceReceiverIndex,:)';
[referenceMatchedFilterOutput,~] = applyMatchedFilter(referenceSignal,sourceSignal);
matchedFilterTime = recordingStartTime + ...
    matchedFilterLags/scenario.samplingFrequency - directBeamArrivalTime;

%% Compute Broadband Beam Scan

numFft = 2^nextpow2(numTimeSamples);
receiverSpectra = fft(receiverSignals,numFft,2).';
positiveFrequencies = (0:numFft/2)'*scenario.samplingFrequency/numFft;
receiverSpectra = receiverSpectra(1:numFft/2+1,:);
frequencyIndexes = positiveFrequencies >= scenario.bandLFM(1) & ...
    positiveFrequencies <= scenario.bandLFM(2);
frequencyBand = positiveFrequencies(frequencyIndexes);
receiverSpectraBand = receiverSpectra(frequencyIndexes,:);

numSteeringAngles = size(scenario.steeringAngles,1);
beamformerPower = zeros(numSteeringAngles,1);
for angleIndex = 1:numSteeringAngles
    currentAngle = scenario.steeringAngles(angleIndex);
    currentDelayOffsets = -receiverRelativeDepths*sind(currentAngle)/ ...
        scenario.soundSpeed;
    steeringPhases = exp(1i*2*pi*frequencyBand*currentDelayOffsets');
    currentBeamSpectrum = sum(receiverSpectraBand.*steeringPhases.* ...
        arrayWeights',2);
    beamformerPower(angleIndex) = sum(abs(currentBeamSpectrum).^2);
end
beamformerPower = beamformerPower/max(beamformerPower);

[~,maximumPowerIndex] = max(beamformerPower);
estimatedLookAngle = scenario.steeringAngles(maximumPowerIndex);
fprintf('  Strongest broadband scan angle: %.3f degrees\n',estimatedLookAngle)

%% Compute Ideal Array Patterns Across the LFM Band

arrayPatternFrequencies = [scenario.bandLFM(1);mean(scenario.bandLFM); ...
    scenario.bandLFM(2)];
numPatternFrequencies = size(arrayPatternFrequencies,1);
arrayPatterns = zeros(numSteeringAngles,numPatternFrequencies);
for frequencyIndex = 1:numPatternFrequencies
    currentFrequency = arrayPatternFrequencies(frequencyIndex);
    for angleIndex = 1:numSteeringAngles
        angleDifference = sind(scenario.steeringAngles(angleIndex)) - ...
            sind(sourceLookAngle);
        currentResponse = sum(arrayWeights.*exp(1i*2*pi*currentFrequency* ...
            receiverRelativeDepths*angleDifference/scenario.soundSpeed));
        arrayPatterns(angleIndex,frequencyIndex) = abs(currentResponse)^2;
    end
    arrayPatterns(:,frequencyIndex) = arrayPatterns(:,frequencyIndex)/ ...
        max(arrayPatterns(:,frequencyIndex));
end

%% Show Free-Space Source Waveform

sourceNumFft = 2^nextpow2(size(sourceSignal,1));
sourceFrequencies = (0:sourceNumFft/2)'*scenario.samplingFrequency/sourceNumFft;
sourceSpectrum = fft(sourceSignal,sourceNumFft);
sourceSpectrum = abs(sourceSpectrum(1:sourceNumFft/2+1));
sourceSpectrum = sourceSpectrum/max(sourceSpectrum);

[sourceSpectrogram,spectrogramFrequencies,spectrogramTimes] = ...
    computeSpectrogram(sourceSignal,scenario.samplingFrequency,1024,768,2048);
sourceSpectrogramDb = 20*log10(abs(sourceSpectrogram)/ ...
    max(abs(sourceSpectrogram(:))) + eps);

figure(1)
set(gcf,'Color','w','Name','Free-Space LFM Waveform')
subplot(3,1,1)
plot(sourceTime,sourceSignal,'k')
xlabel('Time (s)'); ylabel('Amplitude');
title('Free-Space LFM Source Waveform');
grid on

subplot(3,1,2)
plot(sourceFrequencies,20*log10(sourceSpectrum+eps),'k','LineWidth',1.2)
xlim([0 6000]); ylim([-80 5]);
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('Source Spectrum');
grid on

subplot(3,1,3)
imagesc(spectrogramTimes,spectrogramFrequencies,sourceSpectrogramDb,[-60 0])
axis xy
xlabel('Time (s)'); ylabel('Frequency (Hz)');
title('Source Spectrogram');
c = colorbar; c.Label.String = 'Magnitude (dB)';
ylim([1000 5000])

%% Show Free-Space Geometry and Far-Field Delays

exactRelativeDelays = (exactPathLengths-sourceRange)/scenario.soundSpeed;

figure(2)
set(gcf,'Color','w','Name','Free-Space Geometry')
subplot(1,2,1)
hold on
plot(scenario.sourceHorizontalRange,scenario.sourceDepth,'rp','MarkerSize',12, ...
    'MarkerFaceColor','r')
plot(zeros(numReceivers,1),scenario.receiverDepths,'bo','MarkerFaceColor','b')
plot([0 scenario.sourceHorizontalRange], ...
    [receiverReferenceDepth scenario.sourceDepth],'k','LineWidth',1.5)
set(gca,'YDir','reverse')
xlabel('Horizontal Range (m)'); ylabel('Depth (m)');
title('Point Source and Vertical Line Array');
xlim([-0.03*scenario.sourceHorizontalRange 1.03*scenario.sourceHorizontalRange])
depthMargin = max(5,0.1*abs(scenario.sourceDepth-receiverReferenceDepth));
ylim([min([scenario.sourceDepth;scenario.receiverDepths])-depthMargin ...
    max([scenario.sourceDepth;scenario.receiverDepths])+depthMargin])
legend('Point Source','VLA','Reference Path','Location','best')
grid on

subplot(1,2,2)
plot(1e6*exactRelativeDelays,scenario.receiverDepths,'ko-','LineWidth',1)
hold on
plot(1e6*arrivalDelayOffsets,scenario.receiverDepths,'r.--','LineWidth',1.2, ...
    'MarkerSize',14)
set(gca,'YDir','reverse')
xlabel('Relative Arrival Delay (\mus)'); ylabel('Receiver Depth (m)');
title('Exact and Far-Field Arrival Delays');
legend('Exact Spherical','Far-Field Plane Wave','Location','best')
grid on

%% Show Waveforms at the Receiver Array Elements

receiverTime = time-sourceTravelTime;
receiverSignalsPlot = receiverSignals/max(abs(receiverSignals(:)));
referenceScale = max(abs(receiverSignals(referenceReceiverIndex,:)));

figure(3)
set(gcf,'Color','w','Name','VLA Receiver Waveforms')
subplot(2,1,1)
imagesc(receiverTime,scenario.receiverDepths,receiverSignalsPlot,[-1 1])
set(gca,'YDir','reverse')
xlabel('Time Relative to Reference Arrival (s)'); ylabel('Receiver Depth (m)');
title(sprintf('Noisy Waveform at Each VLA Element (Input SNR %.1f dB)',inputSnrDb));
c = colorbar; c.Label.String = 'Normalized Pressure';
xlim([-scenario.preArrivalDuration scenario.durationLFM+ ...
    scenario.postArrivalDuration])

subplot(2,1,2)
plot(receiverTime,receiverSignals(referenceReceiverIndex,:)/referenceScale, ...
    'Color',[0.3 0.3 0.3])
hold on
plot(receiverTime,receiverSignalsNoiseless(referenceReceiverIndex,:)/ ...
    referenceScale,'b','LineWidth',1)
xlabel('Time Relative to Reference Arrival (s)'); ylabel('Normalized Pressure');
title(sprintf('Reference Receiver at %.3f m Depth', ...
    scenario.receiverDepths(referenceReceiverIndex)));
legend('Noisy','Noiseless','Location','best')
grid on
xlim([-scenario.preArrivalDuration scenario.durationLFM+ ...
    scenario.postArrivalDuration])

%% Show Beamformer and Matched-Filter Outputs

alignedReceiverSignalsPlot = alignedReceiverSignals/ ...
    max(abs(alignedReceiverSignals(:)));
beamformerScale = max(abs(beamformerOutput));
matchedFilterScale = max(abs(matchedFilterOutput));
matchedFilterOutputDb = 20*log10(abs(matchedFilterOutput)/matchedFilterScale + eps);
referenceMatchedFilterOutputDb = 20*log10( ...
    abs(referenceMatchedFilterOutput)/matchedFilterScale + eps);

figure(4)
set(gcf,'Color','w','Name','Free-Space Beamformer Output')
subplot(3,1,1)
imagesc(beamformerTime,scenario.receiverDepths,alignedReceiverSignalsPlot,[-1 1])
set(gca,'YDir','reverse')
xlabel('Time Relative to Aligned Arrival (s)'); ylabel('Receiver Depth (m)');
title(sprintf('Channels Aligned with True Time Delays at %.2f Degrees', ...
    sourceLookAngle));
c = colorbar; c.Label.String = 'Normalized Pressure';
xlim([-scenario.preArrivalDuration scenario.durationLFM+ ...
    scenario.postArrivalDuration])

subplot(3,1,2)
plot(beamformerTime,referenceSignal/max(abs(referenceSignal)), ...
    'Color',[0.6 0.6 0.6])
hold on
plot(beamformerTime,beamformerOutput/beamformerScale,'b','LineWidth',1)
xlabel('Time Relative to Aligned Arrival (s)'); ylabel('Normalized Pressure');
title(sprintf('Delay-and-Sum Output: %.2f dB Measured Spatial SNR Gain', ...
    measuredArrayGainDb));
legend('Aligned Reference Channel','Beamformer Output','Location','best')
grid on
xlim([-scenario.preArrivalDuration scenario.durationLFM+ ...
    scenario.postArrivalDuration])

subplot(3,1,3)
plot(matchedFilterTime,referenceMatchedFilterOutputDb, ...
    'Color',[0.6 0.6 0.6])
hold on
plot(matchedFilterTime,matchedFilterOutputDb,'b','LineWidth',1)
xline(0,'r--','Expected Peak','LabelVerticalAlignment','bottom')
xlabel('Time Relative to Aligned Arrival (s)');
ylabel('Matched-Filter Magnitude (dB)');
title('Pulse-Compressed Reference and Beamformer Outputs');
legend('Reference Channel','Beamformer Output','Location','best')
ylim([-60 5]); grid on
xlim([-0.01 0.03])

%% Show Broadband Scan and Frequency-Dependent Array Pattern

figure(5)
set(gcf,'Color','w','Name','Free-Space Broadband Beam Scan')
subplot(1,2,1)
plot(scenario.steeringAngles,10*log10(beamformerPower+eps), ...
    'k','LineWidth',1.5)
hold on
xline(sourceLookAngle,'r--','True Bearing', ...
    'LabelVerticalAlignment','bottom','LineWidth',1.2)
xlabel('Look Angle (degrees)'); ylabel('Normalized Power (dB)');
title('Broadband Free-Space Beam Scan');
ylim([-40 2]); xlim([min(scenario.steeringAngles) max(scenario.steeringAngles)])
grid on

subplot(1,2,2)
plot(scenario.steeringAngles,10*log10(arrayPatterns+eps),'LineWidth',1.2)
xlabel('Look Angle (degrees)'); ylabel('Normalized Power (dB)');
title('Ideal Array Pattern');
legend(compose('%.1f kHz',arrayPatternFrequencies/1000),'Location','best')
ylim([-50 2]); xlim([min(scenario.steeringAngles) max(scenario.steeringAngles)])
grid on

%% Local Functions

function signal = generateLFM(time,frequencyBand,duration,taperFraction)

sweepRate = (frequencyBand(2)-frequencyBand(1))/duration;
signal = zeros(size(time));
validIndexes = time >= 0 & time < duration;
localTime = time(validIndexes);

phase = 2*pi*(frequencyBand(1)*localTime + 0.5*sweepRate*localTime.^2);
window = ones(size(localTime));
edgeDuration = taperFraction*duration;

if edgeDuration > 0
    risingIndexes = localTime < edgeDuration;
    window(risingIndexes) = 0.5*(1-cos(pi*localTime(risingIndexes)/edgeDuration));

    fallingIndexes = localTime > duration-edgeDuration;
    window(fallingIndexes) = 0.5*(1-cos(pi* ...
        (duration-localTime(fallingIndexes))/edgeDuration));
end

signal(validIndexes) = window.*cos(phase);

end

function filteredSignals = bandLimitSignals(signals,samplingFrequency,frequencyBand)

numTimeSamples = size(signals,2);
numFft = 2^nextpow2(numTimeSamples);
signedFrequencies = (0:numFft-1)*samplingFrequency/numFft;
signedFrequencies(signedFrequencies > samplingFrequency/2) = ...
    signedFrequencies(signedFrequencies > samplingFrequency/2)-samplingFrequency;
frequencyMask = abs(signedFrequencies) >= frequencyBand(1) & ...
    abs(signedFrequencies) <= frequencyBand(2);

signalSpectra = fft(signals,numFft,2);
filteredSignals = ifft(signalSpectra.*frequencyMask,numFft,2,'symmetric');
filteredSignals = filteredSignals(:,1:numTimeSamples);

end

function delayedSignals = applyFractionalDelays(signals,delaySamples,filterOrder)

numSignals = size(signals,1);
numTimeSamples = size(signals,2);
delayedSignals = zeros(size(signals));

for signalIndex = 1:numSignals
    currentDelay = delaySamples(signalIndex);
    integerDelay = floor(currentDelay);
    fractionalDelay = currentDelay-integerDelay;

    coefficients = zeros(filterOrder+1,1);
    for coefficientIndex = 0:filterOrder
        otherIndexes = (0:filterOrder)';
        otherIndexes(coefficientIndex+1) = [];
        coefficients(coefficientIndex+1) = prod( ...
            (fractionalDelay-otherIndexes)./(coefficientIndex-otherIndexes));
    end

    fractionallyDelayedSignal = filter(coefficients,1,signals(signalIndex,:));
    if integerDelay == 0
        delayedSignals(signalIndex,:) = fractionallyDelayedSignal;
    elseif integerDelay < numTimeSamples
        delayedSignals(signalIndex,integerDelay+1:end) = ...
            fractionallyDelayedSignal(1:end-integerDelay);
    end
end

end

function [matchedFilterOutput,lags] = applyMatchedFilter(signal,template)

signal = signal(:);
template = template(:);
numOutputSamples = size(signal,1) + size(template,1) - 1;
numFft = 2^nextpow2(numOutputSamples);

matchedFilter = flipud(conj(template));
matchedFilterOutput = ifft(fft(signal,numFft).*fft(matchedFilter,numFft),'symmetric');
matchedFilterOutput = matchedFilterOutput(1:numOutputSamples);
lags = (0:numOutputSamples-1)' - (size(template,1)-1);

end

function [spectrogramMatrix,frequencies,times] = computeSpectrogram( ...
    signal,samplingFrequency,windowLength,overlapLength,numFft)

signal = signal(:);
hopLength = windowLength-overlapLength;
numFrames = 1 + floor((size(signal,1)-windowLength)/hopLength);
window = 0.5 - 0.5*cos(2*pi*(0:windowLength-1)'/(windowLength-1));
spectrogramMatrix = zeros(numFft/2+1,numFrames);
times = zeros(numFrames,1);

for frameIndex = 1:numFrames
    firstIndex = (frameIndex-1)*hopLength + 1;
    currentIndexes = firstIndex:firstIndex+windowLength-1;
    currentSpectrum = fft(signal(currentIndexes).*window,numFft);
    spectrogramMatrix(:,frameIndex) = currentSpectrum(1:numFft/2+1);
    times(frameIndex) = ((firstIndex-1)+(windowLength-1)/2)/samplingFrequency;
end

frequencies = (0:numFft/2)'*samplingFrequency/numFft;

end
