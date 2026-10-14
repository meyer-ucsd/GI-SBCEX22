function [isOut] = checkPriorUniform(proposedSample,prior)

parameterNames = fieldnames(prior);
numParameters = size(parameterNames,1);

isOut = false;
for parameterIndex = 1:numParameters
    priorCurrent = prior.(parameterNames{parameterIndex});
    isOutCurrent = (proposedSample(parameterIndex) < priorCurrent(1) || proposedSample(parameterIndex) > priorCurrent(2));
    isOut = (isOut || isOutCurrent);
    % isOut
end

end

