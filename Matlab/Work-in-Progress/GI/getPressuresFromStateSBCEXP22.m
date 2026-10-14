function [pressure,pressureReal] = getPressuresFromStateSBCEXP22(state,scenario,index)
% state (14 x 1), in the order used throughout:
%  1 source range [m]             2 source depth [m]             3 tilt [deg]          4 water depth [m]
%  5 layer speed top [m/s]        6 layer speed bottom [m/s]
%  7 layer density top [g/cm^3]   8 layer density bottom [g/cm^3]
%  9 layer atten. top [dB/(m kHz)] 10 layer atten. bottom [dB/(m kHz)]
% 11 layer thickness [m]
% 12 halfspace speed [m/s]       13 halfspace density [g/cm^3]  14 halfspace attenuation [dB/(m kHz)]

[receiverDepths,receiverOffsets] = getReceiverGeometrySBCEXP22(scenario.hydrophoneHeights,state(4),state(3));

sediment.speeds = state(5:6);
sediment.densities = state(7:8);
sediment.attenuations = state(9:10);
sediment.thickness = state(11);

halfspace.speed = state(12);
halfspace.density = state(13);
halfspace.attenuation = state(14);

[phiReceivers,phiSource,ks] = getModesSBCEXP22(state(4),sediment,halfspace,receiverDepths,state(2),scenario,index);
pressure = getPressureSBCEXP22(phiReceivers,phiSource,ks,receiverOffsets,state(1));

pressureReal = [real(pressure(:)); imag(pressure(:))];

end
