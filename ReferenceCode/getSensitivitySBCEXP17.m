% Florian Meyer, 2024

function [sensitivityAll,valuesAll] = getSensitivitySBCEXP17(prior,scenario,numValues)

numFreqs = size(scenario.freqs,1);
numReceivers = size(scenario.receiverDepths,1);

if(mod(numValues,2)==0)
    numValues = numValues + 1;      %this has to be an odd number
end

parameterNames = fieldnames(prior);
priorCell = struct2cell(prior);
priorMean = mean([priorCell{:}],1)';
numParameters = size(priorMean,1);

sensitivityAll = zeros(numValues,numParameters);
valuesAll = zeros(numValues,numParameters);
for parameterIndex = 1:numParameters
    priorInterval = prior.(parameterNames{parameterIndex});
    resolution = (priorInterval(2) - priorInterval(1))/(numValues-1);
    valuesGrid = (priorInterval(1):resolution:priorInterval(2))';
    allPressures = zeros(numReceivers,numFreqs,numValues);
    for valueIndex = 1:numValues
        currentState = priorMean;
        currentState(parameterIndex) = valuesGrid(valueIndex);
        allPressures(:,:,valueIndex) = getPressuresFromStateSBCEXP17(currentState,scenario,1);
    end

    priorIndex = ceil(numValues/2);
    correlationCoefficients = ones(numFreqs,numValues);
    dataMatrixes = zeros(numReceivers,numReceivers,numFreqs);
    for freqIndex = 1:numFreqs
        dataMatrixes(:,:,freqIndex) = allPressures(:,freqIndex,priorIndex)*allPressures(:,freqIndex,priorIndex)';
    end

    for valueIndex = 1:numValues
        if (valueIndex == priorIndex)
            continue
        end

        [~,correlationCoefficients(:,valueIndex)] = evaluateLogLikelihood(allPressures(:,:,valueIndex),dataMatrixes,nan,0);
    end
    valuesAll(:,parameterIndex) = valuesGrid;
    sensitivityAll(:,parameterIndex) = mean(correlationCoefficients,1)';
end

end