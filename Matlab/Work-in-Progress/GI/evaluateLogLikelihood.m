% Florian Meyer, 2024

function [logLikelihoods,correlationCoefficients] = evaluateLogLikelihood(modelledPressure,dataMatrix,noiseVariance,constantSNR)
% the noise model is selected by the last two inputs:
%  constantSNR is a number:                   fixed SNR at all frequencies
%  constantSNR is nan, noiseVariance is not:  known noise variance at each frequency
%  both are nan:                              unknown noise variance at each frequency, integrated out
%                                             with a prior that is uniform in log(noiseVariance)

numFreqs = size(modelledPressure,2);
numReceivers = size(modelledPressure,1);
logLikelihoods = zeros(numFreqs,1);
correlationCoefficients = zeros(numFreqs,1);
isNoiseVarianceUnknown = all(isnan(noiseVariance));

for indexF = 1:numFreqs

    numerator = abs( modelledPressure(:,indexF)'*dataMatrix(:,:,indexF)*modelledPressure(:,indexF) );
    traceDataMatrix = sum(diag(dataMatrix(:,:,indexF)));

    denominator = abs( (modelledPressure(:,indexF)' * modelledPressure(:,indexF)) * traceDataMatrix );
    correlationCoefficients(indexF) = numerator/denominator;

    bartlettMismatch = 1 - correlationCoefficients(indexF);

    if(~isnan(constantSNR))
        logLikelihoods(indexF) = - ( bartlettMismatch * constantSNR * numReceivers );
    elseif(~isNoiseVarianceUnknown)
        logLikelihoods(indexF) = - ( bartlettMismatch * traceDataMatrix / noiseVariance(indexF) );
    else
        % the term numReceivers*log(traceDataMatrix) does not depend on the model and is omitted; eps avoids log(0) for a perfect match
        logLikelihoods(indexF) = - numReceivers * log( max(bartlettMismatch,eps) );
    end

end

end

