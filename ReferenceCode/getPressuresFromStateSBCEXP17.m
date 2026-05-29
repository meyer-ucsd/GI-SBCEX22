% Florian Meyer, 2024

function [pressure,pressureReal] = getPressuresFromStateSBCEXP17(state,scenario,index)
modelMode = scenario.modelMode;

[receiverDepthsTilted,receiverOffsets] = getReceiverDepthOffset(scenario.receiverDepths,state(3));

if(strcmp(modelMode,'L2HM1'))
    layers = createLayersSBCEXP17Model1(2,state(5:7),state(8:12),state(13:17));
    [modes,z,k] = getModesSBCEXP17(state(4),layers,scenario,index);
end

if(strcmp(modelMode,'L2HM1N'))
    layers = createLayersSBCEXP17Model1(4,[1812;2.2;0.05],state(5:9),state(10:14));
    [modes,z,k] = getModesSBCEXP17(state(4),layers,scenario,index);
end

if(strcmp(modelMode,'L2M1A'))
    layers = createLayersSBCEXP17Model1(4,nan,state(6:10),state(11:15));
    [modes,z,k] = getModesSBCEXP17(state(4),layers,scenario,index);
    [modesSource,zSource,kSource] = getModesSBCEXP17(state(5),layers,scenario,index);
end

if(strcmp(modelMode,'L2M1AT'))
    layers = createLayersSBCEXP17Model1(4,nan,state(6:10),state(12:16));
    [modes,z,k] = getModesSBCEXP17(state(4),layers,scenario,index);
    layersSource = createLayersSBCEXP17Model1(4,nan,[state(6:9);state(11)],state(12:16));
    [modesSource,zSource,kSource] = getModesSBCEXP17(state(5),layersSource,scenario,index);
end

if(strcmp(modelMode,'L2M1'))
    layers = createLayersSBCEXP17Model1(4,nan,state(5:9),state(10:14));
    [modes,z,k] = getModesSBCEXP17(state(4),layers,scenario,index);
end

if(strcmp(modelMode,'L3M1'))
    layers = createLayersSBCEXP17Model1(4,nan,state(5:9),state(10:14),state(15:19));
    [modes,z,k] = getModesSBCEXP17(state(4),layers,scenario,index);
end

if(strcmp(modelMode,'L2M1A') || strcmp(modelMode,'L2M1AT'))
    pressure = getPressureAdiabatic(modes,z,k,modesSource,zSource,kSource,receiverDepthsTilted,receiverOffsets,state(1),state(2));
else
    pressure = getPressure(modes,z,k,receiverDepthsTilted,receiverOffsets,state(1),state(2));
end


pressureReal = [real(pressure(:)); imag(pressure(:))];

end