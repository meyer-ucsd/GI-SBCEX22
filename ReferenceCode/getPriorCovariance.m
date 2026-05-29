% Florian Meyer, 2024

function [priorMean,priorCovariance,priorRotation,priorVariances] = getPriorCovariance(scenario,mcmc)
regularizationFactor = mcmc.regularizationFactor;
isKnown = scenario.isKnown;
knownState = scenario.knownState;
prior = scenario.prior;
priorMean = scenario.priorMean;
priorStds = scenario.priorStds;
numParameters = size(isKnown,1);

% Extract prior information
priorCell = [struct2cell(prior)]';
priorMatrix = [priorCell{:}]';

% Compute prior means and intervals
noMean = isnan(priorMean);
priorMean(noMean) = mean(priorMatrix(noMean,:),2);
priorMean(isKnown) = knownState(isKnown);
priorIntervals = priorMatrix(:,2) - priorMatrix(:,1);

% Compute prior variances
priorVariancesUniform = priorIntervals.^2/12;
priorVariancesGaussian = priorStds.^2;

% Use variance of Gaussian distribution if smaller than variance of uniform distribution
priorVariances = priorVariancesUniform;
indexesGaussianSmaller = priorVariances>priorVariancesGaussian;
priorVariances(indexesGaussianSmaller) = priorVariancesGaussian(indexesGaussianSmaller);
priorVariances(isKnown) = 0;

priorRotation = eye(numParameters);
priorCovariance = diag(priorVariances) + regularizationFactor * eye(numParameters);

end

