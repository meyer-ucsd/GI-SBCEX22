clear variables; close all; clc;

% Effective number of independent snapshots in an averaging window (see
% CHANGES.md, Section 9). Uses the samples of mainData14L1H.m and all 12
% averaging windows of the data file:
%  1. residual analysis: the best-fitting replica at the MAP environment is
%     subtracted from each snapshot; Keff = (mean residual power) / (power of
%     the mean residual) is 1 if the residual is the same in every snapshot
%     (model error) and about the number of snapshots if it is independent noise
%  2. scatter of the range and source depth peaks over the windows (MAP
%     environment fixed), compared with the posterior standard deviations
%     given the other parameters
% Needs the SIO file, the CTD and XBT casts in Matlab/Data, and KRAKEN.

wip = fullfile(fileparts(mfilename('fullpath')),'..');
addpath(fullfile(wip,'GI')); addpath(fullfile(wip,'MFP'));
dataFolder = fullfile(wip,'..','Data','acoustic'); processedFolder = fullfile(wip,'..','Data','processed');

load(fullfile(wip,'GI','resultsDataTmp.mat'),'samples','logLikelihoods','logPriors','scenario');
valid = 5001:30000;
s1 = permute(samples(:,1,valid),[1,3,2]);
[~,im] = max(logLikelihoods(1,valid)+logPriors(1,valid)); state = s1(:,im);
u = find(~scenario.isKnown);

% conditional posterior std of range and source depth given the other unknowns
C = cov(s1(u,:)'); a = [1 2]; b = 3:numel(u);
Ccond = C(a,a) - C(a,b)/C(b,b)*C(b,a);
fprintf('posterior std: range %.1f m, depth %.2f m; given the other parameters: range %.1f m, depth %.2f m\n',sqrt(C(1,1)),sqrt(C(2,2)),sqrt(Ccond(1,1)),sqrt(Ccond(2,2)));

% data parameters as in mainData14L1H.m
data.samplingFrequency = 25000; data.fftLength = 2^14; data.toneFrequencies = scenario.freqs; data.toneSearchHalfWidth = 3; data.numHydrophones = 16;
numSnapshots = 15; hop = data.fftLength/2/data.samplingFrequency; windowDuration = (numSnapshots+1)*hop; numWindows = 12;

% GPS range of each window
vlaLatitude = 40.048467; vlaLongitude = -70.884167; layback = 180; sspDepths = (0:1:200)';
[~,sal] = readSoundSpeedCastMFP(processedFolder,'CTD',16,sspDepths);
for k = 1:3
    [~,cast] = readSoundSpeedCastMFP(processedFolder,'XBT',8+k,sspDepths,sal.salinity);
    tt(k,1) = cast.time; la(k,1) = cast.latitude; lo(k,1) = cast.longitude;
end
tv = str2double(regexp(scenario.fileName,'\.(\d{2})(\d{3})(\d{2})(\d{2})(\d{2})\.sio$','tokens','once'));
fileStart = datetime(2000+tv(1),1,tv(2),tv(3),tv(4),tv(5));
windowStarts = (0:numWindows-1)'*numSnapshots*hop;
gps = getSourceTrackMFP(fileStart + seconds(windowStarts + windowDuration/2),layback,tt,la,lo,vlaLatitude,vlaLongitude);

% replicas at the MAP environment on a grid of range (relative to GPS) and source depth
relRanges = (-120:1:80)'; depths = (115:0.25:132)';
[recDepths,recOffsets] = getReceiverGeometrySBCEXP22(scenario.hydrophoneHeights,state(4),state(3));
sediment.speeds = state(5:6); sediment.densities = state(7:8); sediment.attenuations = state(9:10); sediment.thickness = state(11);
halfspace.speed = state(12); halfspace.density = state(13); halfspace.attenuation = state(14);
numF = numel(scenario.freqs);
phiS = cell(numel(depths),1);
for d = 1:numel(depths)
    [phiR,phiS{d},ks] = getModesSBCEXP22(state(4),sediment,halfspace,recDepths,depths(d),scenario,1);
end

fprintf('\nwindow  GPS[m]  peak range[m]  range-GPS[m]  depth[m]  meanB  logL | Keff per tone (model-phase aligned) | Keff (eigenvector aligned)\n');
peak = zeros(numWindows,4); keff = zeros(numWindows,numF,2); rho = zeros(numWindows,numF,4); capAll = zeros(numWindows,numF); bAll = zeros(numWindows,numF);
for w = 1:numWindows
    D = getSnapshots(fullfile(dataFolder,scenario.fileName),windowStarts(w),windowDuration,data);
    R = zeros(16,16,numF); for f = 1:numF, R(:,:,f) = D{f}*D{f}'/size(D{f},2); end
    best = -inf;
    for d = 1:numel(depths)
        for r = 1:numel(relRanges)
            p = getPressureSBCEXP22(phiR,phiS{d},ks,recOffsets,gps(w)+relRanges(r));
            B = zeros(numF,1);
            for f = 1:numF, B(f) = real(p(:,f)'*R(:,:,f)*p(:,f))/real(p(:,f)'*p(:,f)); end
            ll = -16*sum(log(1-B));
            if(ll > best), best = ll; bestB = B; bestP = p; peak(w,:) = [gps(w)+relRanges(r),relRanges(r),depths(d),ll]; end
        end
    end
    bAll(w,:) = bestB';
    for f = 1:numF
        wv = bestP(:,f)/norm(bestP(:,f));
        amp = wv'*D{f};                         % 1 x K
        res = D{f} - wv*amp;                    % residual of each snapshot
        [V,E] = eig(R(:,:,f)); [emax,ie] = max(real(diag(E))); v1 = V(:,ie); capAll(w,f) = emax/real(trace(R(:,:,f)));
        phases = {angle(amp),angle(v1'*D{f})};
        for m = 1:2
            ra = res.*exp(-1i*phases{m});
            keff(w,f,m) = mean(sum(abs(ra).^2,1))/sum(abs(mean(ra,2)).^2);
            if(m == 2)
                for lag = 1:4
                    rho(w,f,lag) = mean(real(sum(conj(ra(:,1:end-lag)).*ra(:,1+lag:end),1)))/mean(sum(abs(ra).^2,1));
                end
            end
        end
    end
    fprintf('%4d  %7.1f  %9.1f  %9.1f  %9.2f  %6.3f %6.1f | %s | %s\n',w,gps(w),peak(w,1),peak(w,2),peak(w,3),mean(bestB),peak(w,4),num2str(keff(w,:,1),'%5.1f'),num2str(keff(w,:,2),'%5.1f'));
end

fprintf('\nscatter of the peaks over the %d windows: range-GPS mean %.1f m, std %.1f m; depth mean %.2f m, std %.2f m\n',numWindows,mean(peak(:,2)),std(peak(:,2)),mean(peak(:,3)),std(peak(:,3)));
dr = diff(peak(:,2)); dd = diff(peak(:,3));
fprintf('from differences of consecutive windows (removes slow drifts): range std %.1f m, depth std %.2f m\n',std(dr)/sqrt(2),std(dd)/sqrt(2));
fprintf('\nper tone (median over windows): Bartlett at peak, cap, Keff model-aligned, Keff eigenvector-aligned, residual correlation at lags 1-4\n');
for f = 1:numF
    fprintf('%5g Hz: B %.3f cap %.3f Keff %.1f / %.1f  rho %s\n',scenario.freqs(f),median(bAll(:,f)),median(capAll(:,f)),median(keff(:,f,1)),median(keff(:,f,2)),num2str(squeeze(median(rho(:,f,:),1))','%6.2f'));
end
fprintf('all tones and windows: median Keff %.1f (model-aligned), %.1f (eigenvector-aligned); quartiles %s\n',median(keff(:,:,1),'all'),median(keff(:,:,2),'all'),num2str(quantile(reshape(keff(:,:,2),[],1),[0.25 0.75]),'%5.1f'));
fprintf('window-to-window logL at the peaks: mean %.1f, std %.1f\n',mean(peak(:,4)),std(peak(:,4)));


function snapshotsAll = getSnapshots(fileName,windowStart,windowDuration,data)
% unit-norm snapshots of each tone, processed as in getDataMatrixesSBCEXP22.m
fs = data.samplingFrequency; fftLength = data.fftLength; hopLength = fftLength/2;
toneFrequencies = data.toneFrequencies(:); numTones = numel(toneFrequencies);
firstPoint = round(windowStart*fs) + 1;
numFrames = max(1,floor((round(windowDuration*fs)-fftLength)/hopLength) + 1);
numPoints = (numFrames-1)*hopLength + fftLength;
x = sioread(fileName,firstPoint,numPoints,1:data.numHydrophones);
x = x - mean(x,1);
binFrequencies = (0:fftLength-1)'*fs/fftLength;
snapshotsAll = cell(numTones,1);
spectra = zeros(fftLength,data.numHydrophones,numFrames);
for frameIndex = 1:numFrames
    firstSample = (frameIndex-1)*hopLength + 1;
    spectra(:,:,frameIndex) = fft(x(firstSample:firstSample+fftLength-1,:));
end
for toneIndex = 1:numTones
    bins = find(abs(binFrequencies-toneFrequencies(toneIndex)) <= data.toneSearchHalfWidth);
    [~,bestBin] = max(sum(abs(spectra(bins,:,:)).^2,[2,3]));
    snapshots = reshape(spectra(bins(bestBin),:,:),data.numHydrophones,numFrames);
    snapshotsAll{toneIndex} = snapshots./vecnorm(snapshots);
end
end
