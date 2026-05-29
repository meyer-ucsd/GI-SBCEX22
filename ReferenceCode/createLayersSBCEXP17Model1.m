function layers = createLayersSBCEXP17Model1(maxLayers,hParameters,varargin)
numArgs = size(varargin,2);

% Parameters from D. P. Knobles et al.: Influence of seabed on very low
% frequency sound recorded during passage of merchant ships on the New
% England shelf, 2021


numLayers = numArgs;
layers = struct;
for layerIndex = 1:min([numLayers;maxLayers])
    layers(layerIndex).speedTop = varargin{layerIndex}(1);
    layers(layerIndex).density = varargin{layerIndex}(2);
    layers(layerIndex).attenuation = varargin{layerIndex}(3);
    layers(layerIndex).speedBottom = varargin{layerIndex}(4);
    layers(layerIndex).thickness = varargin{layerIndex}(5);
end
layers = layers';


if(numLayers < 1 && maxLayers >= 1)
    layers(1).speedTop = 1445;
    layers(1).density = 1.612;
    layers(1).attenuation = 0.04;
    layers(1).speedBottom = 1446;
    layers(1).thickness = 10.2;
end


if(numLayers < 2 && maxLayers >= 2)
    layer2.speedTop = 1446;
    layer2.density = 1.7;
    layer2.attenuation = 0.15;
    layer2.speedBottom = 1710;
    layer2.thickness = 2;
    layers = [layers;layer2];
end


if(numLayers < 3 && maxLayers >= 3)
    layer3.speedTop = 1750;
    layer3.density = 1.8;
    layer3.attenuation = 0.15;
    layer3.speedBottom = 1750;
    layer3.thickness = 7.5;
    layers = [layers;layer3];
end



if(numLayers < 4 && maxLayers >= 4)
    layer4.speedTop = 1781.5;
    layer4.density = 2.0;
    layer4.attenuation = 0.05;
    layer4.speedBottom = 1781.5;
    layer4.thickness = 200;
    layers = [layers;layer4];
end

layerH.speedBottom = nan;
layerH.thickness = nan;
if(~isnan(hParameters))
    layerH.speedTop = hParameters(1);
    layerH.density = hParameters(2);
    layerH.attenuation = hParameters(3);
else
    layerH.speedTop = 1812.0;
    layerH.density = 2.2;
    layerH.attenuation = 0.05;      % Copied from layer 4 since likely typo in original paper
end
layers = [layers;layerH];

end