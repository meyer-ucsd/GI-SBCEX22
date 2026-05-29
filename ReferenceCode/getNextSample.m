% Florian Meyer, 2024

function [currentSample,currentLogLikelihood,currentLogPrior,acceptancePattern,errorSample] = getNextSample(dataMatrixes,previousSample,previousLogLikelihood,previousLogPrior,proposalRotation,proposalVariances,currentOrder,temperature,scenario,currentIndex)
prior = scenario.prior;
knownState = scenario.knownState;
isKnown = scenario.isKnown;
likelihoodConstantSNR = scenario.likelihoodConstantSNR;
coupling = scenario.coupling;
numCoupled = size(coupling,1);

sampleTmp = previousSample;
logLikelihoodTmp = previousLogLikelihood;
logPriorTmp = previousLogPrior;
acceptancePattern = false(sum(~isKnown)-numCoupled,1);

errorSample = nan(size(sampleTmp));

for currentDimension = currentOrder

    % get proposed sample
    proposedSample = sampleTmp + proposalRotation(:,currentDimension) * sqrt(proposalVariances(currentDimension))*randn;
    proposedSample(isKnown) = knownState(isKnown);
    proposedSample(coupling(:,1)) = proposedSample(coupling(:,2));

    % drop proposed sample immediately if outside interval of prior (probability of acceptance is equal to zero)
    if (checkPriorUniform(proposedSample,prior))
        continue;
    end

    try
    
        % compute pressure field
        modelledPressure = getPressuresFromStateSBCEXP17(proposedSample,scenario,temperature(2));

        % compute log likelihood of proposed particle
        proposedLogLikelihood = sum(evaluateLogLikelihood(modelledPressure,dataMatrixes,nan,likelihoodConstantSNR)) * 1/temperature(1);

        % compute log prior of proposed particle
        proposedLogPrior = evaluateLogPrior(scenario,proposedSample) * 1/temperature(1);

        % accept or reject
        [sampleTmp,logLikelihoodTmp,logPriorTmp,acceptancePattern(currentDimension)] = acceptRejectPrior(sampleTmp,logLikelihoodTmp,logPriorTmp,proposedSample,proposedLogLikelihood,proposedLogPrior);

    catch
       errorSample = proposedSample;
       save(['errorSample ' datestr(now)],'errorSample','temperature','currentIndex')
    end

end

currentSample = sampleTmp;
currentLogLikelihood = logLikelihoodTmp;
currentLogPrior = logPriorTmp;

end

function [currentSample,currentLikelihood,currentPrior,isAccept] = acceptRejectPrior(previousSample,previousLikelihood,previousPrior,proposedSample,proposedLikelihood,proposedPrior)
currentSample = previousSample;
currentLikelihood = previousLikelihood;
currentPrior = previousPrior;
isAccept = false;

acceptanceProbability = exp(proposedLikelihood-previousLikelihood+proposedPrior-previousPrior);
if rand(1) < acceptanceProbability
    currentSample = proposedSample;
    currentLikelihood = proposedLikelihood;
    currentPrior = proposedPrior;
    isAccept = true;
end

end