function [phiReceivers,phiSource,ks] = getModesKrakenMexSBCEXP22(freqs,waterDepth,sspDepths,sspSpeeds,sediment,halfspace,sourceDepth,receiverDepths,roughness)
% Computes the modes with KRAKEN as a MEX function (mkrak, Matlab/KrakenMex)
% and returns them as getModesSBCEXP22.m does: for each frequency the mode
% shapes at the receiver depths and at the source depth and the wavenumbers.
% It is called by getModesSBCEXP22.m if scenario.model is 'kraken_mex'.
%
% The solver is the one of kraken.exe. The environment is passed in memory, so
% no environment file is written and no mode file is read; all frequencies are
% computed in one call, one after another. The environment is the one of
% writeKrakenEnvSBCEXP22.m: water column with the given sound speed profile,
% one sediment layer with linear gradients, an acoustic halfspace, vacuum
% above, attenuations in dB/(m kHz), phase speeds up to the speed of the
% halfspace (trapped modes only), and the rms roughness of the sea surface and
% of the seafloor as a loss of the coherent field.
%
% Differences to the run with kraken.exe ('kraken_env'), all small:
% - The values are passed with full precision; the environment file holds
%   them with a few decimals (e.g., depths in mm, the phase speed limit in
%   cm/s).
% - The wavenumbers come back in double precision; the mode file holds them
%   in single precision.
% - The depth mesh of each medium has 20 points per wavelength in both, but it
%   is derived from the highest frequency here and from the first frequency in
%   the environment file, so the number of mesh points can differ by a few.
%
% mkrak.<mexext> has to exist for the platform (README.md in Matlab/KrakenMex
% describes the build). A setup problem is an error with the identifier
% SBCEX:krakenUnavailable; a call that KRAKEN does not complete is an error
% with the identifier SBCEX:krakenFailed, which getNextSample.m treats as a
% failed proposal.

setupKrakenMexPath();

freqs = freqs(:)';
numFreqs = numel(freqs);
numSSPPoints = numel(sspDepths);
receiverDepths = receiverDepths(:);
sedimentBottomDepth = waterDepth + sediment.thickness;

% media, one row each: number of mesh points (0: chosen by KRAKEN, 20 points
% per wavelength), rms roughness of the interface above the medium [m], depth
% of its lower end [m]
media = [0, roughness(1), waterDepth; ...
    0, roughness(2), sedimentBottomDepth];

% profile, one row for each point: depth, compressional speed, shear speed,
% density, compressional attenuation, shear attenuation. The points of the
% water column come first, then the top and the bottom of the sediment layer;
% the last row is the halfspace.
profile = [sspDepths(:), sspSpeeds(:), zeros(numSSPPoints,1), ones(numSSPPoints,1), zeros(numSSPPoints,2); ...
    waterDepth, sediment.speeds(1), 0, sediment.densities(1), sediment.attenuations(1), 0; ...
    sedimentBottomDepth, sediment.speeds(2), 0, sediment.densities(2), sediment.attenuations(2), 0; ...
    sedimentBottomDepth, halfspace.speed, 0, halfspace.density, halfspace.attenuation, 0];

% rows of the output arrays: more than the number of modes that can exist
% (two per wavelength of the slowest speed over the whole depth)
maxModes = ceil(2*max(freqs)*sedimentBottomDepth/min([sspSpeeds(:);sediment.speeds(:)])) + 10;

% options as in the environment file: C-linear profile, vacuum above,
% attenuation in dB/(m kHz); acoustic halfspace below without roughness; phase
% speeds from 0 to the speed of the halfspace; maximum range 20 km (given in m)
try
    [~,~,modeDepths,modes,wavenumbers] = mkrak(maxModes,freqs,size(media,1),'CVF',media,size(profile,1),profile,'A',0,[0,halfspace.speed],20000,1,sourceDepth,numel(receiverDepths),receiverDepths);
catch exception
    error('SBCEX:krakenFailed','KRAKEN (MEX) failed: %s',exception.message);
end

% the modes are returned at the merged and sorted depths of source and
% receivers; depths that coincide are returned once, and the rows that are not
% needed then stay zero at the end
modeDepths = modeDepths(:);
numDepths = find(diff(modeDepths) <= 0,1);
if(~isempty(numDepths))
    modeDepths = modeDepths(1:numDepths);
end
rowsReceivers = findDepthRows(modeDepths,receiverDepths);
rowSource = findDepthRows(modeDepths,sourceDepth);

phiReceivers = cell(numFreqs,1);
phiSource = cell(numFreqs,1);
ks = cell(numFreqs,1);
for indexF = 1:numFreqs

    % rows beyond the last mode of a frequency are zero
    numModes = find(wavenumbers(indexF,:) ~= 0,1,'last');
    if(isempty(numModes))
        error('SBCEX:krakenFailed','KRAKEN (MEX) returned no modes at %g Hz',freqs(indexF));
    end
    if(numModes >= maxModes)
        error('SBCEX:krakenFailed','KRAKEN (MEX) returned %d modes at %g Hz, as many as the output arrays hold',numModes,freqs(indexF));
    end

    phiReceivers{indexF} = modes(rowsReceivers,1:numModes,indexF);
    phiSource{indexF} = modes(rowSource,1:numModes,indexF);
    ks{indexF} = wavenumbers(indexF,1:numModes).';

end

end


function rows = findDepthRows(modeDepths,depths)

[distances,rows] = min(abs(modeDepths-depths(:)'),[],1);
if any(distances > 2e-3)
    error('SBCEX:krakenFailed','KRAKEN (MEX) did not return modes at all requested depths');
end
rows = rows(:);

end


function setupKrakenMexPath()

% the folder with the MEX file is put on the MATLAB path once for each MATLAB
% session (each worker of a parallel pool is a session)
persistent isSetUp
if(~isempty(isSetUp))
    return
end

mexFolder = fullfile(fileparts(mfilename('fullpath')),'..','..','KrakenMex');
mexFile = fullfile(mexFolder,['mkrak.',mexext]);
if(~isfile(mexFile))
    error('SBCEX:krakenUnavailable','No mkrak.%s in %s: build it for this platform (README.md in that folder) or use scenario.model = ''kraken_env''',mexext,mexFolder);
end
addpath(mexFolder);
isSetUp = true;

end
