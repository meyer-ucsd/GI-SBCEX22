% Florian Meyer, 2022

function [ covarianceOut ] = checkAndFixCovarianceMatrix( covarianceIn, minStepSize )
covarianceOut = covarianceIn;

% make sure covarianceOut is real
if(~isreal(covarianceOut))
    covarianceOut = real(covarianceOut);
end

% make sure covarianceOut has no NaNs
if(any(isnan(covarianceOut(:))))
    covarianceOut(isnan(covarianceOut)) = 0;
end

% compute output covariance matrix
covarianceOut = 1/2 * (covarianceOut + covarianceOut');

% get eigenvectors and eigenvalues from proposal covariance
[rotation,variances] = eig(covarianceOut);
variances = diag(variances);

% make sure covariance matrix is positive-definite and well-conditioned
stepSize = max([minStepSize,max(variances)/10^(14)]);
variances(variances<stepSize) = stepSize;
covarianceOut = rotation*diag(variances)*rotation';
covarianceOut = 1/2 * (covarianceOut + covarianceOut');

end
