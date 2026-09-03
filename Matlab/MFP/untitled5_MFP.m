%% 1. Initialization and Data Loading
clear; clc; close all;

% A/D converter parameters
fs = 25000;
voltsMax = 2.5;
rangeMax = 2^16 - 1;

% Read SIO file
% fname = 'RAVA01.22147193000.sio';
% fname = 'RAVA01.22147203000.sio';
% fname = 'RAVA01.22147210000.sio';
% fname = 'RAVA01.22147211000.sio';
fname = 'RAVA01.22147212000.sio';
% fname = 'RAVA01.22147213000.sio';
yt = sioread([cd, '/', fname], 1, 0, 1:16);
yt = (yt - mean(yt, 1)) * ((2 * voltsMax) / rangeMax); % Convert to volts

%% 2. Sound Speed Profile (SSP) Interpolation
load('SBCEXP22_ssp_ctd020.mat');
[~, indD] = max(ctd_Depth);
z = ctd_Depth(1:indD);
c = ctd_ssp(1:indD);
[z_unique, ia] = unique(z);
c_unique = c(ia);

Nnew = 500;
z_new = linspace(min(z_unique), max(z_unique), Nnew).';
c_new = interp1(z_unique, c_unique, z_new, 'pchip');

%% 3. Array and Spatial Grid Setup
bottom_depth = 200;
z_H1_above_bottom = 5.5;
dz_hydrophone = 3.75;
hydrophone_num = 1:16;

RD = bottom_depth - z_H1_above_bottom ...
     - (hydrophone_num - 1) * dz_hydrophone;

RD = RD(:);

srcZ = linspace(.5, 200, 100);       % Source depth grid [m]
RD = sort(unique([RD.', srcZ]));

zs = 120;

% Receiver depths (RAD)
RAD = bottom_depth - z_H1_above_bottom - (hydrophone_num - 1) * dz_hydrophone;
RAD = RAD(:);

% Spatial grid (depth and range)
srcZ = linspace(0.5, 200, 100);        % Source depth grid [m]
srcR = linspace(.5, 6, 100) * 1000;    % Source range grid [m]

% Depth grid for KRAKEN mode calculation
RD_kraken = sort(unique([RAD.', srcZ]));

% Analysis parameters
freqList = [503, 653, 803, 1003, 1253]; % Five Tonals
NFFT = 2^14;
NFTOverlap = NFFT / 2;
win = ones(NFFT, 1);
snapshot_idx = 1; % Time snapshot index for analysis

% 3-D array to store results (Depth × Range × Frequency)
Pbartlett_all = zeros(length(srcZ), length(srcR), length(freqList));

%% 4. Multi-Frequency MFP Loop
at_path = '/Users/yongsungpark/Downloads/at'; % Path to the AT toolbox
addpath(genpath(at_path));

for iFreq = 1:length(freqList)
    f0 = freqList(iFreq);
    fprintf('Processing Frequency: %d Hz (%d/%d)...\n', f0, iFreq, length(freqList));
    
    % --- A. Extract time-frequency data ---
    S_time = [];
    for ch = 1:length(hydrophone_num)
        x = yt(:, ch) - mean(yt(:, ch));
        [S, F, T] = spectrogram(x, win, NFTOverlap, NFFT, fs);
        [~, fidx] = min(abs(F - f0));
        S_time(ch, :) = S(fidx, :);
    end
    
    % Extract snapshot and arrange receiver order
    % receivedSignal = S_time(:, snapshot_idx);
    receivedSignal = S_time(:,:);
    
    % --- B. Compute KRAKEN modes ---
    env_edit;
    clear read_modes_bin;
    flp_edit;
    kraken('SBCEXP_200m');
    [Modes] = read_modes('SBCEXP_200m.mod', f0);
    fclose('all');
    delete('SBCEXP_200m.mod');
    delete('SBCEXP_200m.shd.mat');
    
    % --- C. Generate replica field ---
    phi = Modes.phi;
    kc = double(Modes.k);
    Modes.z = round(Modes.z * 100) / 100;
    
    phiReceiver = zeros(numel(RAD), numel(kc));
    for indRd = 1:numel(RAD)
        [~, idxR] = min(abs(Modes.z - RAD(indRd)));
        phiReceiver(indRd, :) = phi(idxR, :);
    end
    phiReceiver = double(phiReceiver);
    
    replicaField = [];
    for isrcZ = 1:numel(srcZ)
        srcZtemp = srcZ(isrcZ);
        [~, idxS] = min(abs(Modes.z - srcZtemp));
        phiSource = double(phi(idxS, :));
        
        presTemp = zeros(numel(RAD), numel(srcR));
        for iSensor = 1:numel(RAD)
            r_sensor = srcR + (iSensor - 1) * 1.875 * tand(0);
            presTemp(iSensor, :) = (phiReceiver(iSensor, :) .* phiSource) * besselh(0, 2, kc * r_sensor);
        end
        presTemp = 1j / (4 * pi * 1) * presTemp;
        
        % Normalize the replica field
        presTemp = presTemp ./ sqrt(sum(abs(presTemp).^2, 1));
        replicaField = [replicaField, presTemp];
    end
    
    % --- D. Bartlett beamforming ---
    R = receivedSignal * receivedSignal'; % Covariance matrix
    
    % Fast vectorized computation (replaces the iGrid loop)
    P_grid = real(sum(conj(replicaField) .* (R * replicaField), 1));
    P_2D = reshape(P_grid, length(srcR), length(srcZ)).';
    
    % Normalize each frequency result to the range [0, 1]
    Pbartlett_all(:, :, iFreq) = P_2D / max(P_2D(:));
end

rmpath(genpath(at_path));

%% 5. Incoherent Averaging
P_incoherent = mean(Pbartlett_all, 3);
P_incoherent = P_incoherent / max(P_incoherent(:)); % Final normalization

%% 6. Visualization (2 × 3 Subplots)
figure('Name', 'Multi-Frequency MFP & Incoherent Averaging', 'Color', 'w', 'Position', [100, 100, 1400, 800]);

% Plots for the five frequency bands
for k = 1:5
    subplot(2, 3, k);
    imagesc(srcR / 1000, srcZ, Pbartlett_all(:, :, k));
    axis xy;
    title(sprintf('%d Hz', freqList(k)), 'FontSize', 14);
    xlabel('Range [km]', 'FontSize', 11);
    ylabel('Depth [m]', 'FontSize', 11);
    colorbar;
    caxis([0 1]);
    set(gca, 'FontSize', 12, 'YDir', 'reverse');
end

% Sixth subplot: Incoherent averaging result
subplot(2, 3, 6);
imagesc(srcR / 1000, srcZ, P_incoherent);
axis xy;
title('Incoherent Averaging', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Range [km]', 'FontSize', 11);
ylabel('Depth [m]', 'FontSize', 11);
colorbar;
caxis([0 1]);
set(gca, 'FontSize', 12, 'YDir', 'reverse');