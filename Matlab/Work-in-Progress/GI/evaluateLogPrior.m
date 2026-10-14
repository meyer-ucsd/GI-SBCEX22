% Florian Meyer, 2024

function [logPrior] = evaluateLogPrior(scenario,proposedSample)

priorMean = scenario.priorMean;
priorStds = scenario.priorStds;

hasStd = priorStds < inf;

numParameters = size(priorMean,1);
logPrior = zeros(numParameters,1);
logPrior(hasStd) = - 1/2 * (priorMean(hasStd)-proposedSample(hasStd)).^2 ./ priorStds(hasStd).^2 ;
logPrior = sum(logPrior(~scenario.isKnown));

end