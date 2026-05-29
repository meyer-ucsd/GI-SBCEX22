% Florian Meyer, 2024

function [logLikelihoods,correlationCoefficients] = evaluateLogLikelihood(modelledPressure,dataMatrix,noiseVariance,constantSNR)

numFreqs = size(modelledPressure,2);
numReceivers = size(modelledPressure,1);
logLikelihoods = zeros(numFreqs,1);
correlationCoefficients = zeros(numFreqs,1);

for indexF = 1:numFreqs

    numerator = abs( modelledPressure(:,indexF)'*dataMatrix(:,:,indexF)*modelledPressure(:,indexF) );
    traceDataMatrix = sum(diag(dataMatrix(:,:,indexF)));

    denominator = abs( (modelledPressure(:,indexF)' * modelledPressure(:,indexF)) * traceDataMatrix );
    correlationCoefficients(indexF) = numerator/denominator;

    bartlettMismatch = 1 - correlationCoefficients(indexF);

    if(~isnan(constantSNR))
        logLikelihoods(indexF) = - ( bartlettMismatch * constantSNR * numReceivers );
    else
        logLikelihoods(indexF) = - ( bartlettMismatch * traceDataMatrix / noiseVariance(indexF) );
    end

end

end

