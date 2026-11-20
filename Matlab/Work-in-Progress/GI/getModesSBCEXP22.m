function [phiReceivers,phiSource,ks] = getModesSBCEXP22(waterDepth,sediment,halfspace,receiverDepths,sourceDepth,scenario,index)
% Computes the modes for all frequencies and returns, for each frequency, the
% mode shapes at the receiver depths and at the source depth and the
% wavenumbers. The modes are computed at the requested depths.
%
% scenario.model selects how the modes are computed; all functions that call
% this one follow it:
%   'kraken_mex'  KRAKEN as a MEX function (Matlab/KrakenMex): the solver of
%                 kraken.exe without any files (getModesKrakenMexSBCEXP22.m).
%                 The setting of the main scripts since 2026-11-19.
%   'kraken_env'  KRAKEN as a separate program: an environment file is written,
%                 kraken.exe is run, and its mode file is read. Also used if the
%                 field does not exist and for 'Kraken': the results files
%                 written before 2026-11-19 were computed this way, and their
%                 evaluation reproduces the stored values exactly.
%   'orca'        ORCA (getModesOrcaSBCEXP22.m); its files are not part of the
%                 repository
% The names are not case sensitive.
%
% scenario.roughness (optional): rms roughness [m] of the sea surface (first
% entry) and of the seafloor (second entry), passed to KRAKEN as a loss of the
% coherent field. Only with the two KRAKEN versions.

roughness = zeros(2,1);
if(isfield(scenario,'roughness'))
    roughness(1:numel(scenario.roughness)) = scenario.roughness(:);
end

model = 'kraken_env';                               % scenario of a results file from before the flag existed
if(isfield(scenario,'model'))
    model = lower(char(scenario.model));
    if(strcmp(model,'kraken'))
        model = 'kraken_env';
    end
end
if(~any(strcmp(model,{'kraken_env','kraken_mex','orca'})))
    error('SBCEX:krakenUnavailable','Unknown propagation model ''%s'': scenario.model is ''kraken_env'', ''kraken_mex'', or ''orca''',char(scenario.model));
end

if(strcmp(model,'orca'))
    if(any(roughness ~= 0))
        error('SBCEX:orcaUnavailable','The roughness of the sea surface and of the seafloor (scenario.roughness) is implemented for KRAKEN only (scenario.model ''kraken_env'' or ''kraken_mex'')');
    end
    [phiReceivers,phiSource,ks] = getModesOrcaSBCEXP22(waterDepth,sediment,halfspace,receiverDepths,sourceDepth,scenario);
    return
end

freqs = scenario.freqs;
numFreqs = numel(freqs);

% sound speed profile from the surface to the current water depth; the
% shallowest and deepest measured values are held instead of extrapolated
ssp = scenario.ssp;
sspDepths = linspace(0,waterDepth,scenario.numSSPPoints)';
sspSpeeds = interp1(ssp.depths,ssp.speeds,sspDepths,'pchip',nan);
sspSpeeds(sspDepths < ssp.depths(1)) = ssp.speeds(1);
sspSpeeds(sspDepths > ssp.depths(end)) = ssp.speeds(end);

% KRAKEN as a MEX function: no files
if(strcmp(model,'kraken_mex'))
    [phiReceivers,phiSource,ks] = getModesKrakenMexSBCEXP22(freqs,waterDepth,sspDepths,sspSpeeds,sediment,halfspace,sourceDepth,receiverDepths,roughness);
    return
end

% depths at which KRAKEN writes the modes (rounded as in the environment file)
modeDepths = unique(round([receiverDepths;sourceDepth],3));

% write environment file and run KRAKEN; the index keeps files of parallel workers apart
filenameOut = ['SBCEXP22Compute',num2str(index)];
writeKrakenEnvSBCEXP22([filenameOut,'.env'],freqs,waterDepth,sspDepths,sspSpeeds,sediment,halfspace,sourceDepth,modeDepths,roughness);
runKraken(filenameOut);

% read modes for each frequency
phiReceivers = cell(numFreqs,1);
phiSource = cell(numFreqs,1);
ks = cell(numFreqs,1);
for indexF = 1:numFreqs

    clear readModes;
    modesKraken = readModes([filenameOut,'.mod'],freqs(indexF));

    zKraken = double(modesKraken.z(:));
    phi = double(modesKraken.phi);
    phiReceivers{indexF} = phi(findDepthRows(zKraken,receiverDepths),:);
    phiSource{indexF} = phi(findDepthRows(zKraken,sourceDepth),:);
    ks{indexF} = double(modesKraken.k(:));

end
delete([filenameOut,'.*']);

end


function rows = findDepthRows(zKraken,depths)

[distances,rows] = min(abs(zKraken-depths(:)'),[],1);
if any(distances > 2e-3)
    error('SBCEX:krakenFailed','KRAKEN did not return modes at all requested depths');
end
rows = rows(:);

end


function runKraken( filename )

% remove an old mode file so that a failed run cannot be read as valid output
modFile = [filename,'.mod'];
if isfile(modFile)
    delete(modFile);
end

runkraken = getKrakenPath();
[status,output] = system(['"' runkraken '" ' filename]);

% exit codes 126/127 mean the binary itself could not be executed (e.g., wrong CPU architecture)
if (status == 126 || status == 127)
    error('SBCEX:krakenUnavailable','Cannot execute %s:\n%s',runkraken,output);
end
if (status ~= 0 || ~isfile(modFile))
    error('SBCEX:krakenFailed','KRAKEN failed for %s.env (exit code %d):\n%s',filename,status,output);
end

end


function runkraken = getKrakenPath()

% binary for this platform (bin/maca64 = Apple silicon, bin/maci64 = Intel),
% first next to this file, then in ReferenceCode/bin, otherwise from the MATLAB path
thisFolder = fileparts(mfilename('fullpath'));
candidates = {fullfile(thisFolder,'bin',computer('arch'),'kraken.exe'), ...
    fullfile(thisFolder,'..','..','..','ReferenceCode','bin',computer('arch'),'kraken.exe')};
runkraken = '';
for candidateIndex = 1:numel(candidates)
    if isfile(candidates{candidateIndex})
        runkraken = candidates{candidateIndex};
        break
    end
end
if isempty(runkraken)
    runkraken = which( 'kraken.exe' );
end

if ( isempty( runkraken ) )
    error('SBCEX:krakenUnavailable','No kraken.exe for platform %s in bin/, ReferenceCode/bin/, or on the MATLAB path',computer('arch'))
end

end
