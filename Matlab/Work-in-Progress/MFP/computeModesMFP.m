function modes = computeModesMFP(frequency,modeDepths,waterDepth,sspDepths,sspSpeeds,sediment,halfspace,krakenPath)
% Runs KRAKEN for one frequency and returns the modes at modeDepths
% (Acoustics Toolbox read_modes structure).

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
