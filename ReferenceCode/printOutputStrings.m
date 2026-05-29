% Florian Meyer, 2024

function printOutputStrings(sample,covariance,index,isAccepted,acceptancePatterns,temperatures,acceptedInitial,acceptancePatternTotal,scenario)
isKnown = scenario.isKnown;
modelMode = scenario.modelMode;
numTemperatures = size(temperatures,1);

for currentT = 1:numTemperatures

    isAcceptCurrent = isAccepted(currentT,index);
    acceptedTotal = sum(isAccepted(currentT,1:index));

    variances = diag(covariance(:,:,currentT));
    variances(isKnown) = 0;

    string1a = ['sRange = ' num2str(sample(1)), ', sDepth = ' num2str(sample(2)), ', tilt = ' num2str(sample(3)) ', wDepth = ', num2str(sample(4))];
    string2a = ['sRangeV = ' num2str(variances(1)), ', sDepthV = ' num2str(variances(2)), ', tiltV = ' num2str(variances(3)), ', wDepthV = ' num2str(variances(4))];


    if(strcmp(modelMode,'L2M1') || strcmp(modelMode,'L2HM1N'))
        string2b = [', tSpeed1V = ' num2str(variances(5)), ', dens1V = ' num2str(variances(6)), ', att1V = ' num2str(variances(7)), ', bSpeed1V = ' num2str(variances(8)), ', thick1V = ' num2str(variances(9))  '\n'];
        string2c = ['tSpeed2V = ' num2str(variances(10)), ', dens2V = ' num2str(variances(11)), ', att2V = ' num2str(variances(12)), ', bSpeed2V = ' num2str(variances(13)), ', thick2V = ' num2str(variances(14))];
        string1d = '\n';

        string1b = [', tSpeed1 = ' num2str(sample(5)), ', dens1 = ' num2str(sample(6)), ', att1 = ' num2str(sample(7)), ', bSpeed1 = ' num2str(sample(8)), ', thick1 = ' num2str(sample(9))  '\n'];
        string1c = ['tSpeed2 = ' num2str(sample(10)), ', dens2 = ' num2str(sample(11)), ', att2 = ' num2str(sample(12)), ', bSpeed2 = ' num2str(sample(13)), ', thick2 = ' num2str(sample(14))];
        string2d = '\n';
    end

    if(strcmp(modelMode,'L2M1A'))
        string1a = ['sRange = ' num2str(sample(1)), ', sDepth = ' num2str(sample(2)), ', tilt = ' num2str(sample(3)) ', wDepthRe = ', num2str(sample(4)) ', wDepthSo = ', num2str(sample(5))];
        string2a = ['sRangeV = ' num2str(variances(1)), ', sDepthV = ' num2str(variances(2)), ', tiltV = ' num2str(variances(3)), ', wDepthReV = ' num2str(variances(4)), ', wDepthSoV = ' num2str(variances(5))];

        string2b = [', tSpeed1V = ' num2str(variances(6)), ', dens1V = ' num2str(variances(7)), ', att1V = ' num2str(variances(8)), ', bSpeed1V = ' num2str(variances(9)), ', thick1V = ' num2str(variances(10))  '\n'];
        string2c = ['tSpeed2V = ' num2str(variances(11)), ', dens2V = ' num2str(variances(12)), ', att2V = ' num2str(variances(13)), ', bSpeed2V = ' num2str(variances(14)), ', thick2V = ' num2str(variances(15))];
        string1d = '\n';

        string1b = [', tSpeed1 = ' num2str(sample(6)), ', dens1 = ' num2str(sample(7)), ', att1 = ' num2str(sample(8)), ', bSpeed1 = ' num2str(sample(9)), ', thick1 = ' num2str(sample(10))  '\n'];
        string1c = ['tSpeed2 = ' num2str(sample(11)), ', dens2 = ' num2str(sample(12)), ', att2 = ' num2str(sample(13)), ', bSpeed2 = ' num2str(sample(14)), ', thick2 = ' num2str(sample(15))];
        string2d = '\n';
    end

    if(strcmp(modelMode,'L2M1AT'))
        string1a = ['sRange = ' num2str(sample(1)), ', sDepth = ' num2str(sample(2)), ', tilt = ' num2str(sample(3)) ', wDepthRe = ', num2str(sample(4)) ', wDepthSo = ', num2str(sample(5))];
        string2a = ['sRangeV = ' num2str(variances(1)), ', sDepthV = ' num2str(variances(2)), ', tiltV = ' num2str(variances(3)), ', wDepthReV = ' num2str(variances(4)), ', wDepthSoV = ' num2str(variances(5))];

        string2b = [', tSpeed1V = ' num2str(variances(6)), ', dens1V = ' num2str(variances(7)), ', att1V = ' num2str(variances(8)), ', bSpeed1V = ' num2str(variances(9)), ', thick1ReV = ' num2str(variances(10)), ', thick1SoV = ' num2str(variances(11))  '\n'];
        string2c = ['tSpeed2V = ' num2str(variances(12)), ', dens2V = ' num2str(variances(13)), ', att2V = ' num2str(variances(14)), ', bSpeed2V = ' num2str(variances(15)), ', thick2V = ' num2str(variances(16))];
        string1d = '\n';

        string1b = [', tSpeed1 = ' num2str(sample(6)), ', dens1 = ' num2str(sample(7)), ', att1 = ' num2str(sample(8)), ', bSpeed1 = ' num2str(sample(9)), ', thickRe1 = ' num2str(sample(10)), ', thickSo1 = ' num2str(sample(11))   '\n'];
        string1c = ['tSpeed2 = ' num2str(sample(12)), ', dens2 = ' num2str(sample(13)), ', att2 = ' num2str(sample(14)), ', bSpeed2 = ' num2str(sample(15)), ', thick2 = ' num2str(sample(16))];
        string2d = '\n';
    end


    if(strcmp(modelMode,'L2HM1'))
        string1b = [', tSpeed1 = ' num2str(sample(8)), ', dens1 = ' num2str(sample(9)), ', att1 = ' num2str(sample(10)), ', bSpeed1 = ' num2str(sample(11)), ', thick1 = ' num2str(sample(12))  '\n'];
        string1c = ['tSpeed2 = ' num2str(sample(13)), ', dens2 = ' num2str(sample(14)), ', att2 = ' num2str(sample(15)), ', bSpeed2 = ' num2str(sample(16)), ', thick2 = ' num2str(sample(17))];
        string1d = [', speedH = ' num2str(sample(5)), ', densH = ' num2str(sample(6)), ', attH = ' num2str(sample(7))  '\n'];

        string2b = [', tSpeed1V = ' num2str(variances(8)), ', dens1V = ' num2str(variances(9)), ', att1V = ' num2str(variances(10)), ', bSpeed1V = ' num2str(variances(11)), ', thick1V = ' num2str(variances(12))  '\n'];
        string2c = ['tSpeed2V = ' num2str(variances(13)), ', dens2V = ' num2str(variances(14)), ', att2V = ' num2str(variances(15)), ', bSpeed2V = ' num2str(variances(16)), ', thick2V = ' num2str(variances(17))];
        string2d = [', speedHV = ' num2str(variances(5)), ', densHV = ' num2str(variances(6)), ', attHV = ' num2str(variances(7)) '\n'];
    end
    
    if(~isnan(acceptancePatternTotal))
        
        stringInit = [', acceptance pattern total: ', num2str(acceptancePatternTotal')];

        if(isAcceptCurrent)
            string = ['temperature: ', num2str(temperatures(currentT)),', ',num2str(index), ', accepted total: ', num2str(acceptedTotal), stringInit, ', acceptance pattern: ', num2str(acceptancePatterns(:,currentT)'), '\n', string1a, string1b, string1c, string1d, string2a, string2b, string2c, string2d];
        else
            string = ['temperature: ', num2str(temperatures(currentT)),', ',num2str(index), ' accepted total: ', num2str(acceptedTotal), stringInit, '\n', string1a, string1b, string1c, string1d, string2a, string2b, string2c, string2d];
        end

    else

        if(isAcceptCurrent)
            string = ['temperature: ', num2str(temperatures(currentT)),', ',num2str(index), ': accept, accepted intitially: ', num2str(acceptedInitial(currentT)), ', accepted total: ', num2str(acceptedTotal), ', acceptance pattern: ', num2str(acceptancePatterns(:,currentT)'), '\n', string1a, string1b, string1c, string1d, string2a, string2b, string2c, string2d];
        else
            string = ['temperature: ', num2str(temperatures(currentT)),', ',num2str(index), ': reject, accepted intitially: ', num2str(acceptedInitial(currentT)), ' accepted total: ', num2str(acceptedTotal), '\n', string1a, string1b, string1c, string1d, string2a, string2b, string2c, string2d];
        end

    end

    fprintf(string)

end

end