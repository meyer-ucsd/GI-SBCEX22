function [phiReceivers,phiSource,ks,diagnostics] = getModesOrcaSBCEXP22(waterDepth,sediment,halfspace,receiverDepths,sourceDepth,scenario)
% Computes the modes with ORCA instead of KRAKEN and returns them as
% getModesSBCEXP22.m does: for each frequency the mode shapes at the receiver
% depths and at the source depth and the wavenumbers. It is called by
% getModesSBCEXP22.m if scenario.model is 'orca'. ORCA is called once for all
% frequencies, returns the modes exactly at the requested depths (no
% interpolation), and needs no files.
%
% The ORCA files are not part of the repository (Matlab/Orca is in .gitignore).
% This function expects the guarded build in Matlab/Orca/<platform>, where
% <platform> is computer('arch') (glnxa64, maci64): ORCA_MEX.m, sub_orca.<mexext>,
% and the helper program orca_helper. The three files have to stay together. The
% MEX file passes every call to the helper program and stops a call that does
% not return.
%
% Settings in scenario.orca (all optional; defaults in getOrcaSettings below):
%   path          folder with the ORCA files
%   numSSPPoints  points of the sound speed profile of the water passed to ORCA
%                 (equally spaced between the surface and the seafloor). The run
%                 time of ORCA is proportional to this number. Default 65; the
%                 field then has a correlation of 0.999 with the field for 500
%                 points (CHANGES.md, Section 30).
%   ctol          ORCA removes points of the profile as long as the profile is
%                 reproduced to within ctol [m/s]; 0 (default) keeps all points.
%                 With ctol > 0 the points that remain change with the profile.
%   cphmax        largest phase speed of the modes [m/s]; nan: the speed of the
%                 halfspace, i.e., trapped modes only, as in the KRAKEN run. A
%                 larger value adds leaky modes.
%   rmin          smallest range of interest [km]; modes that are weaker than the
%                 strongest one by more than dbcut at this range are left out
%   rmax          largest range of interest [km] (accuracy of the wavenumbers)
%   dbcut, phfac  see ORCA_MEX.m
%   maxModes      rows of the output arrays; the build finds at most 200 modes
%                 for each frequency (reached at 1253 Hz for a halfspace speed of
%                 about 1870 m/s, or for cphmax of about 1900 m/s)
%   maxR1R2Evaluations, nativeTimeoutSeconds, nativeTerminateGraceSeconds
%                 limits of the guarded build for one call (work per frequency
%                 and time)
%
% A call that ORCA does not complete (time or work limit, more modes than
% maxModes, search stopped early) is an error with the identifier
% SBCEX:orcaFailed, which getNextSample.m treats as a failed proposal. A setup
% problem (files missing, unknown setting) has the identifier SBCEX:orcaUnavailable.
%
% Units and conventions: attenuations are passed with a positive sign, which
% ORCA reads as dB/(m kHz), the unit of the inversion (a negative value would be
% dB/wavelength). ORCA uses the opposite time convention to KRAKEN and to the
% modal sum in getPressureSBCEXP22.m, so the complex conjugates of its
% wavenumbers and mode shapes are returned. The modes are sorted as those of
% KRAKEN (decreasing real part of the wavenumber).

persistent hasSucceeded

settings = getOrcaSettings(scenario);
setupOrcaPath(settings.path);

freqs = scenario.freqs(:)';
numFreqs = numel(freqs);

% sound speed profile from the surface to the current water depth, built as in
% getModesSBCEXP22.m: the shallowest and deepest measured values are held
ssp = scenario.ssp;
sspDepths = linspace(0,waterDepth,settings.numSSPPoints)';
sspSpeeds = interp1(ssp.depths,ssp.speeds,sspDepths,'pchip',nan);
sspSpeeds(sspDepths < ssp.depths(1)) = ssp.speeds(1);
sspSpeeds(sspDepths > ssp.depths(end)) = ssp.speeds(end);

% environment: air, water column, sediment layer with linear gradients, halfspace.
% Rows of btm_env and above_sea: type, thickness, speed top and bottom, shear
% speed top and bottom, density top and bottom, attenuation top and bottom, shear
% attenuation top and bottom, and four entries that are not used here.
environment.uphalf_cp = 343.0;
environment.uphalf_cs = 0.0;
environment.uphalf_rho = 0.00121;
environment.uphalf_ap = 0.0;
environment.uphalf_as = 0.0;
environment.nsvp = numel(sspDepths);
environment.ctol = settings.ctol;
environment.wssp = [sspDepths,sspSpeeds];
environment.wrho = 1.0;
environment.walphs = 0.0;
environment.nlayb = 1;
environment.btm_env = [1 sediment.thickness sediment.speeds(1) sediment.speeds(2) 0 0 sediment.densities(1) sediment.densities(2) sediment.attenuations(1) sediment.attenuations(2) 0 0 0 0 0 0];
environment.lowhalf_cp = halfspace.speed;
environment.lowhalf_cs = 0.0;
environment.lowhalf_rho = halfspace.density;
environment.lowhalf_ap = halfspace.attenuation;
environment.lowhalf_as = 0.0;
environment.ntop = 0;
environment.above_sea = [1 50 1650 1650 0 0 1.5 1.5 0.1 0.1 0 0 0 0 0 0];      % not used (ntop = 0), but the field has to exist

% depths at which ORCA returns the modes (rounded as for KRAKEN)
modeDepths = unique(round([receiverDepths(:);sourceDepth],3));

options.nmode = settings.maxModes;
options.cphmax = settings.cphmax;
if(isnan(options.cphmax))
    options.cphmax = halfspace.speed;
end
options.rmin = settings.rmin;
options.rmax = settings.rmax;
options.phfac = settings.phfac;
options.dbcut = settings.dbcut;
options.Aih_l = -1.0;           % homogeneous halfspaces
options.Aih_u = -1.0;
options.nf = numFreqs;
options.fcw_n = numFreqs;
options.fcw = freqs;
options.nzm = numel(modeDepths);
options.zm_n = numel(modeDepths);
options.zm = modeDepths(:)';
options.maxR1R2Evaluations = settings.maxR1R2Evaluations;
options.nativeTimeoutSeconds = settings.nativeTimeoutSeconds;
options.nativeTerminateGraceSeconds = settings.nativeTerminateGraceSeconds;

[numModesOrca,wavenumbers,~,modeFunctions,depthsOrca,~,statusCodes,isPartial,numEvaluations,~,elapsedSeconds] = ORCA_MEX(environment,options,1);

numModesOrca = double(numModesOrca(:)');
statusCodes = double(statusCodes(:)');
diagnostics.numModes = numModesOrca;
diagnostics.statusCodes = statusCodes;
diagnostics.numEvaluations = double(numEvaluations(:)');
diagnostics.elapsedSeconds = double(elapsedSeconds(:)');

% status code of each frequency: 1 search stopped early, 2 and 16 more modes
% than the arrays hold, 4 work space full, 64 work limit, 128 time limit,
% 256 helper program failed; 8 alone is a regular end of the search
if(any(bitand(statusCodes,256) ~= 0) && isempty(hasSucceeded))
    error('SBCEX:orcaUnavailable','The helper program of ORCA in %s could not be used (status code of each frequency: %s)',settings.path,mat2str(statusCodes));
end
if(any(isPartial(:)) || any(bitand(statusCodes,1+2+4+16+64+128+256) ~= 0) || any(numModesOrca < 1))
    error('SBCEX:orcaFailed','ORCA did not return all modes (number of modes of each frequency: %s, status codes: %s)',mat2str(numModesOrca),mat2str(statusCodes));
end
hasSucceeded = true;

depthsOrca = double(depthsOrca(:));
phiReceivers = cell(numFreqs,1);
phiSource = cell(numFreqs,1);
ks = cell(numFreqs,1);
for indexF = 1:numFreqs

    numModes = numModesOrca(indexF);
    k = conj(wavenumbers(1:numModes,indexF));
    phi = conj(modeFunctions(:,1:numModes,indexF));
    [~,order] = sort(real(k),'descend');

    phiReceivers{indexF} = phi(findDepthRows(depthsOrca,receiverDepths),order);
    phiSource{indexF} = phi(findDepthRows(depthsOrca,sourceDepth),order);
    ks{indexF} = k(order);

end

end


function settings = getOrcaSettings(scenario)

settings.path = fullfile(fileparts(mfilename('fullpath')),'..','..','Orca',computer('arch'));
settings.numSSPPoints = 65;
settings.ctol = 0;
settings.cphmax = nan;
settings.rmin = 0.5;
settings.rmax = 5;
settings.phfac = 4;
settings.dbcut = 50;
settings.maxModes = 200;
settings.maxR1R2Evaluations = 250000;
settings.nativeTimeoutSeconds = 60;
settings.nativeTerminateGraceSeconds = 2;

if(isfield(scenario,'orca'))
    names = fieldnames(scenario.orca);
    for nameIndex = 1:numel(names)
        if(~isfield(settings,names{nameIndex}))
            error('SBCEX:orcaUnavailable','Unknown setting scenario.orca.%s',names{nameIndex});
        end
        settings.(names{nameIndex}) = scenario.orca.(names{nameIndex});
    end
end

end


function setupOrcaPath(orcaPath)
% puts the folder with the ORCA files on the MATLAB path, once in each MATLAB
% session (each worker of a parallel pool has its own)

persistent currentPath
if(isequal(currentPath,orcaPath))
    return
end

requiredFiles = {'ORCA_MEX.m',['sub_orca.',mexext],'orca_helper'};
for fileIndex = 1:numel(requiredFiles)
    if(~isfile(fullfile(orcaPath,requiredFiles{fileIndex})))
        error('SBCEX:orcaUnavailable','No ORCA for platform %s: %s is missing in %s (the ORCA files are not part of the repository)',computer('arch'),requiredFiles{fileIndex},orcaPath);
    end
end
[~,attributes] = fileattrib(fullfile(orcaPath,'orca_helper'));
if(~attributes.UserExecute)
    error('SBCEX:orcaUnavailable','The helper program %s is not executable',fullfile(orcaPath,'orca_helper'));
end

addpath(orcaPath);
if(isempty(which('ORCA_MEX')) || isempty(which('sub_orca')))
    error('SBCEX:orcaUnavailable','The ORCA files in %s are not found by MATLAB',orcaPath);
end
currentPath = orcaPath;

end


function rows = findDepthRows(depthsOrca,depths)

[distances,rows] = min(abs(depthsOrca-depths(:)'),[],1);
if any(distances > 2e-3)
    error('SBCEX:orcaFailed','ORCA did not return modes at all requested depths');
end
rows = rows(:);

end
