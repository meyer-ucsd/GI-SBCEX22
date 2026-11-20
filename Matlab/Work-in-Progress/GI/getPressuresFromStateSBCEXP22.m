function [pressure,pressureReal] = getPressuresFromStateSBCEXP22(state,scenario,index)
% pressure: numReceivers x numFreqs, or numReceivers x (numFreqs*numWindows) if scenario.sourceRangeOffsets is set
% state (14 x 1), in the order used throughout:
%  1 source range [m]             2 source depth [m]             3 tilt [deg]          4 water depth [m]
%  5 layer speed top [m/s]        6 layer speed bottom [m/s]
%  7 layer density top [g/cm^3]   8 layer density bottom [g/cm^3]
%  9 layer atten. top [dB/(m kHz)] 10 layer atten. bottom [dB/(m kHz)]
% 11 layer thickness [m]
% 12 halfspace speed [m/s]       13 halfspace density [g/cm^3]  14 halfspace attenuation [dB/(m kHz)]
% further entries (optional): EOF coefficients of the sound speed of the water, see below;
% source range and source depth of further files and the roughness of the seafloor
% (mainData14L1HTwoFiles.m), see below

% joint inversion of several files (mainData14L1HTwoFiles.m): all files share the
% environment and the tilt. scenario.files(f) holds what differs between the files:
%   sourceRangeIndex, sourceDepthIndex  state entries of the source range of the
%                                       reference window of the file and of its source depth
%   sourceRangeOffsets                  ranges of the windows of the file minus the range of its reference window
%   loggerTemperatures (optional)       temperatures of the loggers of the array at the time of the file
%   roughnessSurface (optional)         rms roughness of the sea surface at the time of the file [m]
% The columns of pressure are ordered as the data matrices: all windows of the
% first file (all tones of its first window, ...), then all windows of the second file, ...
if(isfield(scenario,'files'))
    numFiles = numel(scenario.files);
    pressureFiles = cell(1,numFiles);
    for fileIndex = 1:numFiles
        file = scenario.files(fileIndex);
        stateFile = state;
        stateFile(1) = state(file.sourceRangeIndex);
        stateFile(2) = state(file.sourceDepthIndex);
        scenarioFile = rmfield(scenario,'files');
        scenarioFile.sourceRangeOffsets = file.sourceRangeOffsets;
        if(isfield(file,'loggerTemperatures'))
            scenarioFile.loggers.temperatures = file.loggerTemperatures;
        end
        if(isfield(file,'roughnessSurface'))
            scenarioFile.roughness(1) = file.roughnessSurface;
        end
        pressureFiles{fileIndex} = getPressuresFromStateSBCEXP22(stateFile,scenarioFile,index);
    end
    pressure = [pressureFiles{:}];
    pressureReal = [real(pressure(:)); imag(pressure(:))];
    return
end

% rms roughness of the seafloor as an entry of the state (scenario.roughness holds
% the roughness of the sea surface and of the seafloor, getModesSBCEXP22.m)
if(isfield(scenario,'roughnessSeafloorIndex'))
    scenario.roughness(2) = state(scenario.roughnessSeafloorIndex);
end

% sound speed profile of the water from the temperature loggers of the array
% (scenario.loggers, getLoggerProfileSBCEXP22.m): the loggers move with the water
% depth as the hydrophones do; scenario.ssp.speeds is the reference profile
% above the loggers
if(isfield(scenario,'loggers'))
    scenario.ssp.speeds = getLoggerProfileSBCEXP22(scenario.ssp,scenario.loggers,state(4));
end

[receiverDepths,receiverOffsets] = getReceiverGeometrySBCEXP22(scenario.hydrophoneHeights,state(4),state(3));

sediment.speeds = state(5:6);
sediment.densities = state(7:8);
sediment.attenuations = state(9:10);
sediment.thickness = state(11);

halfspace.speed = state(12);
halfspace.density = state(13);
halfspace.attenuation = state(14);

% sound speed profile of the water with EOF coefficients in the state
% (mainData14L1HRangeDependent.m): the profile at the array is scenario.ssp.speeds
% + scenario.ssp.eofs*state(scenario.sspIndexesArray); the profile at the source is
% the profile at the array + scenario.ssp.eofs*state(scenario.sspIndexesDifference)
isRangeDependent = false;
if(isfield(scenario,'sspIndexesArray'))
    scenario.ssp.speeds = scenario.ssp.speeds + scenario.ssp.eofs*state(scenario.sspIndexesArray);
    coefficientsDifference = state(scenario.sspIndexesDifference);
    isRangeDependent = any(coefficientsDifference ~= 0);
end

[phiReceivers,phiSource,ks] = getModesSBCEXP22(state(4),sediment,halfspace,receiverDepths,state(2),scenario,index);

% profile that depends on range: adiabatic modes as in ReferenceCode/getPressureAdiabatic.m,
% with a second KRAKEN run for the profile at the source. Mode shapes at the receivers
% from the profile at the array, mode shapes at the source from the profile at the
% source, and the mean of the wavenumbers of both ends. The modes of the two ends are
% paired by their index; this holds only for a moderate difference of the two profiles
% (getModePairingSBCEXP22.m gives the correlation of the paired mode shapes).
if(isRangeDependent)
    scenarioSource = scenario;
    scenarioSource.ssp.speeds = scenario.ssp.speeds + scenario.ssp.eofs*coefficientsDifference;
    [~,phiSourceEnd,ksSourceEnd] = getModesSBCEXP22(state(4),sediment,halfspace,receiverDepths,state(2),scenarioSource,index);
    for indexF = 1:numel(ks)
        numModes = min(numel(ks{indexF}),numel(ksSourceEnd{indexF}));       % modes that exist at both ends
        ks{indexF} = (ks{indexF}(1:numModes) + ksSourceEnd{indexF}(1:numModes))/2;
        phiReceivers{indexF} = phiReceivers{indexF}(:,1:numModes);
        phiSource{indexF} = phiSourceEnd{indexF}(:,1:numModes);
    end
end

% joint inversion of several averaging windows (mainData14L1HJoint.m): the source
% range of window w is state(1) + scenario.sourceRangeOffsets(w). The modes do not
% depend on the range, so they are computed once. The columns of pressure are
% ordered as the data matrices: all tones of window 1, all tones of window 2, ...
sourceRangeOffsets = 0;
if(isfield(scenario,'sourceRangeOffsets'))
    sourceRangeOffsets = scenario.sourceRangeOffsets(:)';
end
numFreqs = numel(ks);
pressure = zeros(numel(receiverDepths),numFreqs*numel(sourceRangeOffsets));
for windowIndex = 1:numel(sourceRangeOffsets)
    pressure(:,(windowIndex-1)*numFreqs+(1:numFreqs)) = getPressureSBCEXP22(phiReceivers,phiSource,ks,receiverOffsets,state(1)+sourceRangeOffsets(windowIndex));
end

pressureReal = [real(pressure(:)); imag(pressure(:))];

end
