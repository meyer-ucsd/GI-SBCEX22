function printOutputStrings(samples,covariances,index,isAccepted,acceptancePatterns,temperatures,acceptedInitial,acceptancePatternTotal,scenario)
% Prints the current sample and proposal variances for each temperature. The
% parameter names are the field names of scenario.prior, which are in the
% order of the state.
parameterNames = string(fieldnames(scenario.prior));
isKnown = scenario.isKnown;
numTemperatures = size(temperatures,1);

for currentT = 1:numTemperatures

    isAcceptCurrent = isAccepted(currentT,index);
    acceptedTotal = sum(isAccepted(currentT,1:index));

    variances = diag(covariances(:,:,currentT));
    variances(isKnown) = 0;

    if(~any(isnan(acceptancePatternTotal)))
        header = sprintf('temperature: %g, %d, accepted total: %d, acceptance pattern total: %s', ...
            temperatures(currentT),index,acceptedTotal,num2str(acceptancePatternTotal'));
    elseif(isAcceptCurrent)
        header = sprintf('temperature: %g, %d: accept, accepted intitially: %d, accepted total: %d, acceptance pattern: %s', ...
            temperatures(currentT),index,acceptedInitial(currentT),acceptedTotal,num2str(acceptancePatterns(:,currentT)'));
    else
        header = sprintf('temperature: %g, %d: reject, accepted intitially: %d, accepted total: %d', ...
            temperatures(currentT),index,acceptedInitial(currentT),acceptedTotal);
    end

    sampleString = strjoin(compose('%s = %.5g',parameterNames,samples(:,currentT)),', ');
    varianceString = strjoin(compose('%sV = %.3g',parameterNames,variances),', ');

    fprintf('%s\n%s\n%s\n',header,sampleString,varianceString);

end

end
