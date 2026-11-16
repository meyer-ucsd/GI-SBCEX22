function [correlations,numNegative] = getModePairingSBCEXP22(state,scenario,index)
% Check of the adiabatic modes used for a sound speed profile of the water that
% depends on range (getPressuresFromStateSBCEXP22.m): the modes of the profile at
% the source and of the profile at the array are paired by their index. This
% function compares the paired mode shapes over the water column.
%
% correlations: numFreqs x 1, mean correlation coefficient of the paired mode
%               shapes; each mode is weighted with its contribution to the field
%               (mode amplitude at the source times mode amplitude at the
%               receivers). 1: the modes of the two ends have the same shapes.
%               Values clearly below 1 (about 0.9 and less) mean that the modes of
%               the two ends do not correspond one to one and that the adiabatic
%               pressure is not reliable for this state.
% numNegative:  numFreqs x 1, number of pairs with opposite sign

numFreqs = numel(scenario.freqs);
correlations = ones(numFreqs,1);
numNegative = zeros(numFreqs,1);
if(~isfield(scenario,'sspIndexesArray') || all(state(scenario.sspIndexesDifference) == 0))
    return
end

[receiverDepths,~] = getReceiverGeometrySBCEXP22(scenario.hydrophoneHeights,state(4),state(3));
sediment.speeds = state(5:6);
sediment.densities = state(7:8);
sediment.attenuations = state(9:10);
sediment.thickness = state(11);
halfspace.speed = state(12);
halfspace.density = state(13);
halfspace.attenuation = state(14);

scenarioArray = scenario;
scenarioArray.ssp.speeds = scenario.ssp.speeds + scenario.ssp.eofs*state(scenario.sspIndexesArray);
scenarioSource = scenario;
scenarioSource.ssp.speeds = scenarioArray.ssp.speeds + scenario.ssp.eofs*state(scenario.sspIndexesDifference);

% mode shapes of both ends on a grid over the water column, and the weights from the modes of the array end
gridDepths = (0.5:1:state(4)-0.4)';
[phiArray,phiSourceDepth] = getModesSBCEXP22(state(4),sediment,halfspace,gridDepths,state(2),scenarioArray,index);
phiReceivers = getModesSBCEXP22(state(4),sediment,halfspace,receiverDepths,state(2),scenarioArray,index);
phiSource = getModesSBCEXP22(state(4),sediment,halfspace,gridDepths,state(2),scenarioSource,index);

for indexF = 1:numFreqs
    numModes = min(size(phiArray{indexF},2),size(phiSource{indexF},2));
    shapesArray = real(phiArray{indexF}(:,1:numModes));
    shapesSource = real(phiSource{indexF}(:,1:numModes));
    pairCorrelations = sum((shapesArray./vecnorm(shapesArray)).*(shapesSource./vecnorm(shapesSource)),1)';
    weights = abs(phiSourceDepth{indexF}(1:numModes)).*vecnorm(phiReceivers{indexF}(:,1:numModes));
    weights = weights(:)/sum(weights);
    correlations(indexF) = sum(weights.*pairCorrelations);
    numNegative(indexF) = sum(pairCorrelations < 0);
end

end
