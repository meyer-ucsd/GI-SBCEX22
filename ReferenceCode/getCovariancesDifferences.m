% Florian Meyer, 2024

% get posterior covariance by linearizing the model using partial
% differences; the Gaussian prior for source range and depth are
% ignored

function [proposalCovariances,proposalRotations,proposalVariances] = getCovariancesDifferences(scenario,temperatures,mcmc)
numParameters = size(scenario.priorMean,1);
numTemperatures = size(temperatures,1);

[approxCovariance,~] = covarianceDifferences(scenario);
approxCovariance(:,scenario.isKnown) = 0;
approxCovariance(scenario.isKnown,:) = 0;

proposalCovariances = zeros(numParameters,numParameters,numTemperatures);
proposalRotations = zeros(numParameters,numParameters,numTemperatures);
proposalVariances = zeros(numParameters,numTemperatures); 
for indexT = 1:numTemperatures
    proposalCovariances(:,:,indexT) = mcmc.scalingFactor * ( approxCovariance*temperatures(indexT) + mcmc.regularizationFactor * eye(numParameters) );
    [proposalRotations(:,:,indexT), eigenValues ] = eig(proposalCovariances(:,:,indexT,1));

    proposalRotations(:,:,indexT) = flip(proposalRotations(:,:,indexT),2);
    proposalVariances(:,indexT) = flip(diag(eigenValues));
end

end


function [posteriorCovariance,jacobian] = covarianceDifferences(scenario)

constantSNR = scenario.likelihoodConstantSNR;
prior = scenario.prior;

% Extract prior information
priorCell = [struct2cell(prior)]';
priorMatrix = [priorCell{:}]';
priorMean = mean(priorMatrix,2);
minPrior = priorMatrix(:,1);
maxPrior = priorMatrix(:,2);
numParameters = size(priorMean,1);

% Initialize prior parameters 
pseudoPriorVariances = ones(numParameters,1)/12;
intervalPrior = maxPrior - minPrior;
meanPrior = mean([minPrior,maxPrior],2);
numParameters = size(meanPrior,1);

% Initialize delta for the computation of partial differences
deltasStart = intervalPrior/2; % starting deltas for partial differences
deltasEnd = zeros(numParameters,1);

% Determine noise variance
[~,fakeData] = getPressuresFromStateSBCEXP17(meanPrior,scenario,1);
numDataValues = size(fakeData,1);
noiseVariance = mean(abs(fakeData.^2))/constantSNR;

% Initialize noise parameters 
noiseCovarianceInverse = diag(1./noiseVariance);

% Compute multiple partial differences for each parameter value and each measurements
numTrys = 25;
allDeltas = zeros(numDataValues,numParameters,numTrys);
for indexP = 1:numParameters  % for each unknown parameter (each dimension of the unknown state)
    deltaCurrent = deltasStart(indexP);
    for indexT = 1:numTrys  % number of deltas to try

        parameterPlus = meanPrior;
        parameterPlus(indexP) = parameterPlus(indexP) + deltaCurrent;  % perturb current parameter by adding small positive value
        [~,deltaPlus] = getPressuresFromStateSBCEXP17(parameterPlus,scenario,1);

        parameterMinus = meanPrior;
        parameterMinus(indexP) = parameterMinus(indexP) - deltaCurrent;  % perturb current parameter by adding small negative value
        [~,deltaMinus] = getPressuresFromStateSBCEXP17(parameterMinus,scenario,1);

        allDeltasCurrent = (deltaPlus(:) - deltaMinus(:)) / (2*deltaCurrent);

        indexesValid = abs( (deltaPlus(:) - deltaMinus(:)) ./ (deltaPlus(:) + deltaMinus(:)) ) > 1e-12;   % consider only deltas with significant relative change
        allDeltas(indexesValid,indexP,indexT) = allDeltasCurrent(indexesValid);

        deltaCurrent = deltaCurrent / 1.5; % slowly decrease deltas after each try
    end

    deltasEnd(indexP) = deltaCurrent;
end


% Form Jacobian by choosing delta values corresponding to the most stable partial differences

jacobian = zeros(numDataValues,numParameters);
jacobianScaled = zeros(numDataValues,numParameters);
for indexP = 1:numParameters  % for each unknown parameter (each dimension of the unknown state)
    
    for indexD = 1:numDataValues        
        
        bestTestValue = 10^10;
        indexBest = 1;
        for indexT = 2:numTrys-1 % we always compare three consecutive partial differences to find the best (most stable) one; the first and last partial difference cannot be the best one
            if (abs(allDeltas(indexD,indexP,indexT-1)) < 1e-12 || abs(allDeltas(indexD,indexP,indexT)) < 1e-12 || abs(allDeltas(indexD,indexP,indexT+1)) < 1e-12)
                currentTestValue = 1e10; % if either the previous, the current, or the next partial difference has a too small value, the current partial difference cannot be the most stable one
            else
                currentTestValue = abs((allDeltas(indexD,indexP,indexT-1)/allDeltas(indexD,indexP,indexT) + allDeltas(indexD,indexP,indexT)/allDeltas(indexD,indexP,indexT+1))/2-1);    % this test values is zero if three consecutive partial differences are equal; we are looking for the three consecutive partial differences that produce the smallest test value
            end
            if ((currentTestValue < bestTestValue) && (currentTestValue > 0))  % if the current test value is smaller than the previous one, we store the index of the current partial difference (it might be the best one)
                bestTestValue = currentTestValue;
                indexBest = indexT;
            end
        end
        
        jacobian(indexD,indexP) = allDeltas(indexD,indexP,indexBest);
        jacobianScaled(indexD,indexP) = intervalPrior(indexP)*allDeltas(indexD,indexP,indexBest);
    end

end

posteriorCovariance = diag(intervalPrior)' / ( ( jacobianScaled'*noiseCovarianceInverse*jacobianScaled +  diag(1./pseudoPriorVariances) ) ) * diag(intervalPrior);

end



