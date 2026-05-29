% Florian Meyer, 2024

function [proposalCovariances,proposalRotations,proposalVariances] = getCovariancesSampling(priorRotation,priorVariances,dataMatrixes,scenario,numAcceptanceDimensionInit,temperatures,mcmc)
numParameters = size(scenario.priorMean,1);
numTemperatures = size(temperatures,1);

proposalCovariances = zeros(numParameters,numParameters,numTemperatures);
proposalRotations = zeros(numParameters,numParameters,numTemperatures);
proposalVariances = zeros(numParameters,numTemperatures);
for indexT = 1:numTemperatures

    approxCovariance = covarianceSampling(priorRotation,priorVariances,dataMatrixes,scenario,numAcceptanceDimensionInit,[temperatures(indexT),indexT],mcmc);

    proposalCovariances(:,:,indexT) = mcmc.scalingFactor * ( approxCovariance*temperatures(indexT) + mcmc.regularizationFactor * eye(numParameters) );
    [proposalRotations(:,:,indexT), eigenValues ] = eig(proposalCovariances(:,:,indexT));

    proposalRotations(:,:,indexT) = flip(proposalRotations(:,:,indexT),2);
    proposalVariances(:,indexT) = flip(diag(eigenValues));
end

end


function [sampleCovariance] = covarianceSampling(priorRotation,priorVariances,dataMatrixes,scenario,numAcceptanceDimensionInit,temperature,mcmc)
totalSamples = 10^6;
coupling = scenario.coupling;
priorMean = scenario.priorMean;

numParameters = size(priorMean,1);
isCoupled = zeros(numParameters,1);
isCoupled(coupling(:,1)) = 1;
noInference = (scenario.isKnown | isCoupled);
numParametersInference = numParameters - sum(noInference);

regularizationFactor = mcmc.regularizationFactor;

% initialize vectors of samples, corresponding likelhood values, and proposal covariances
samples = zeros(numParameters,totalSamples);
logLikelihoods = zeros(totalSamples,1);
logPriors = zeros(totalSamples,1);
acceptancePatternTotal = zeros(numParametersInference,1);
samples(:,1) = priorMean;

modelledPressure = getPressuresFromStateSBCEXP17(samples(:,1,1),scenario,temperature(2));
logLikelihoods(1) = sum(evaluateLogLikelihood(modelledPressure,dataMatrixes,nan,scenario.likelihoodConstantSNR)) * 1/temperature(1);

logPriors(1) = evaluateLogPrior(scenario,samples(:,1,1)) * 1/temperature(1);

priorVariancesTmp = priorVariances;
priorRotation = priorRotation(:,[find(~noInference);find(noInference)],:);
priorVariances = priorVariances([find(~noInference);find(noInference)],:);

isAccepted = false(totalSamples,1);
isAccepted(1) = true;
% main loop for covariance computation
tic
for currentIndex = 2:totalSamples

    minAcceptance = min(acceptancePatternTotal);
    currentIndexes = find(acceptancePatternTotal==minAcceptance)';
    currentOrder = currentIndexes(randperm(numel(currentIndexes)));

    if(minAcceptance == numAcceptanceDimensionInit)
        totalSamples = currentIndex-1;
        break
    end

    % compute one new sample
    [samples(:,currentIndex),logLikelihoods(currentIndex),logPriors(currentIndex),acceptancePattern] = getNextSample(dataMatrixes,samples(:,currentIndex-1),logLikelihoods(currentIndex-1),logPriors(currentIndex-1),priorRotation,priorVariances,currentOrder,temperature,scenario,currentIndex);
    acceptancePatternTotal = acceptancePatternTotal + acceptancePattern;

    % store everything
    isAccepted(currentIndex) = any(acceptancePattern);

    % print status message
    printOutputStrings(samples(:,currentIndex),diag(priorVariancesTmp),currentIndex,isAccepted',acceptancePattern,temperature(1),sum(isAccepted),acceptancePatternTotal,scenario)

end

samples = samples(:,1:totalSamples);
sampleMean = 1/(totalSamples) * sum(samples,2);
sampleCorrelation = 1/(totalSamples) * (samples*samples');
sampleCovariance = sampleCorrelation - sampleMean*sampleMean';
sampleCovariance = checkAndFixCovarianceMatrix(sampleCovariance,regularizationFactor);

end
