% Florian Meyer, 2024

function [pressures] = getPressure(modesUniform,zUniform,ks,receiverDepths,receiverOffsets,range,sourceDepth)
numReceivers = size(receiverDepths,1);

% compute true modeled pressure field
numFreqs = size(modesUniform,3);

pressures = zeros(numReceivers,numFreqs);
for indexF = 1:numFreqs

    % extract relevant modes and calculate values at source and receiver depths
    k = ks(:,indexF);
    indexM = k>0;
    k = k(indexM);
    
    modesUniformCurrent = modesUniform(:,indexM,indexF);
    modesReceiversCurrent  = interp1(zUniform,modesUniformCurrent,receiverDepths);
    modesSourceCurrent  = interp1(zUniform,modesUniformCurrent,sourceDepth);


    % calculate modal sum for receiver elements with range offset
    phi = modesReceiversCurrent .* repmat(modesSourceCurrent,[numReceivers,1]);
    
    numModes = size(k,1);
    rangeMatrix = repmat(range + receiverOffsets,[1,numModes]);
    kMatrix = repmat(permute(k,[2,1]),[numReceivers,1]);

    % (normalized as in original Fortran implementation by Porter)
    phase = 1./sqrt(kMatrix) .* exp(-1i.*kMatrix.*rangeMatrix) .* realsqrt(2*pi./rangeMatrix);
    phase = 1i * exp( 1i * pi / 4 ) * phase;
    pressures(:,indexF) = sum(phi .* phase,2);

    
end

end