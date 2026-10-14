function [pressures] = getPressureSBCEXP22(phiReceivers,phiSource,ks,receiverOffsets,range)
% modal sum for each frequency; phiReceivers{f} is numReceivers x numModes,
% phiSource{f} is 1 x numModes, and ks{f} is numModes x 1
numReceivers = size(receiverOffsets,1);
numFreqs = numel(ks);

pressures = zeros(numReceivers,numFreqs);
for indexF = 1:numFreqs

    k = ks{indexF}.';
    rangeMatrix = range + receiverOffsets;

    % (normalized as in original Fortran implementation by Porter)
    phase = 1./sqrt(k) .* exp(-1i.*k.*rangeMatrix) .* realsqrt(2*pi./rangeMatrix);
    phase = 1i * exp( 1i * pi / 4 ) * phase;
    pressures(:,indexF) = sum(phiReceivers{indexF} .* phiSource{indexF} .* phase,2);

end

end
