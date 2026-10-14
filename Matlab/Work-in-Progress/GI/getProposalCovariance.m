% Florian Meyer, 2024

function [sampleMean,sampleCorrelation,proposalCovariance,proposalRotation,proposalVariances] = getProposalCovariance(sampleMean,sampleCorrelation,proposalCovariance,proposalRotation,proposalVariances,samples,numSamplesCovariance,numSamples,mcmc)

if(numSamplesCovariance > numSamples)
    return
end

regularizationFactor = mcmc.regularizationFactor;
scalingFactor = mcmc.scalingFactor;
numParameters = size(sampleMean,1);

if(any(isnan(sampleMean)))
    samples = samples(:,1:numSamplesCovariance);
    sampleMean = 1/(numSamplesCovariance) * sum(samples,2);
    sampleCorrelation = 1/(numSamplesCovariance) * (samples*samples');
else
    currentSample = samples(:,end);
    sampleMean = (numSamples-1)/numSamples * sampleMean + 1/numSamples * currentSample;
    sampleCorrelation = (numSamples-1)/numSamples * sampleCorrelation + 1/numSamples * (currentSample*currentSample');
end



sampleCovariance = sampleCorrelation - sampleMean*sampleMean';
proposalCovariance = scalingFactor * ( sampleCovariance + regularizationFactor * eye(numParameters) ); 
proposalCovariance = checkAndFixCovarianceMatrix(proposalCovariance, regularizationFactor );

% get eigenvalues and eigenvectors; organize them in descending order
[proposalRotation, variances ] = eig(proposalCovariance);
proposalVariances = flip(diag(variances));
proposalRotation = flip(proposalRotation,2);


end