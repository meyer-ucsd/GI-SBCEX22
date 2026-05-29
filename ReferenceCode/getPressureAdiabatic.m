% Florian Meyer, 2024

function [pressures] = getPressureAdiabatic(modesReceiver,zReceiver,kReceiver,modesSource,zSource,kSource,receiverDepths,receiverOffsets,range,sourceDepth)
numReceivers = size(receiverDepths,1);

% compute true modeled pressure field
numFreqs = size(modesReceiver,3);

pressures = zeros(numReceivers,numFreqs);
for indexF = 1:numFreqs

    % extract relevant modes and calculate values at source and receiver depths
    kReceiverTmp = kReceiver(:,indexF);   
    kSourceTmp = kSource(:,indexF);

    % find number of relevant modes, i.e., modes shared by receiver and source location
    numModes = min(find(kReceiverTmp>0,1,'last'),find(kSourceTmp>0,1,'last'));

    % compute average wavenumber for relevant modes
    kReceiverTmp = kReceiverTmp(1:numModes);
    kSourceTmp = kSourceTmp(1:numModes);
    k = (kReceiverTmp+kSourceTmp)/2;
    
    % compute values of modes at receiver and source depth
    modesReceiversCurrent  = interp1(zReceiver,modesReceiver(:,1:numModes,indexF),receiverDepths);
    modesSourceCurrent  = interp1(zSource,modesSource(:,1:numModes,indexF),sourceDepth);


    % calculate modal sum for receiver elements with range offset
    phi = modesReceiversCurrent .* repmat(modesSourceCurrent,[numReceivers,1]);
    
    rangeMatrix = repmat(range + receiverOffsets,[1,numModes]);
    kMatrix = repmat(permute(k,[2,1]),[numReceivers,1]);
    kMatrixReceiver = repmat(permute(kReceiverTmp,[2,1]),[numReceivers,1]);

    % (normalized as in original Fortran implementation by Porter)
    phase = 1./sqrt(kMatrixReceiver) .* exp(-1i.*kMatrix.*rangeMatrix) .* realsqrt(2*pi./rangeMatrix);
    phase = 1i * exp( 1i * pi / 4 ) * phase;
    pressures(:,indexF) = sum(phi .* phase,2);

    
end

end