function [phiReceivers,phiSource,ks] = getModesSBCEXP22(waterDepth,sediment,halfspace,receiverDepths,sourceDepth,scenario,index)
% Runs KRAKEN for all frequencies and returns, for each frequency, the mode
% shapes at the receiver depths and at the source depth and the wavenumbers.
% The modes are computed exactly at the requested depths (no interpolation).

freqs = scenario.freqs;
numFreqs = numel(freqs);

% sound speed profile from the surface to the current water depth; the
% shallowest and deepest measured values are held instead of extrapolated
ssp = scenario.ssp;
sspDepths = linspace(0,waterDepth,scenario.numSSPPoints)';
sspSpeeds = interp1(ssp.depths,ssp.speeds,sspDepths,'pchip',nan);
sspSpeeds(sspDepths < ssp.depths(1)) = ssp.speeds(1);
sspSpeeds(sspDepths > ssp.depths(end)) = ssp.speeds(end);

% depths at which KRAKEN writes the modes (rounded as in the environment file)
modeDepths = unique(round([receiverDepths;sourceDepth],3));

% write environment file and run KRAKEN; the index keeps files of parallel workers apart
filenameOut = ['SBCEXP22Compute',num2str(index)];
writeKrakenEnvSBCEXP22([filenameOut,'.env'],freqs,waterDepth,sspDepths,sspSpeeds,sediment,halfspace,sourceDepth,modeDepths);
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
