function [eofs,info] = getSoundSpeedEOFsSBCEXP22(processedFolder,depths,salinities,ctdNumbers,xbtNumbers,numEOFs)
% Empirical orthogonal functions (EOFs) of the sound speed of the water from
% CTD and XBT casts of SBCEXP 2022, built as in MFP/tuneSoundSpeedMFP.m: the
% casts are read on the depth grid (readSoundSpeedCastMFP; XBTs with the given
% salinity profile), their mean is removed, and the EOFs are the left singular
% vectors of the result.
%
% eofs: numDepths x numEOFs. Column k is EOF k times the standard deviation of
%       its coefficient over the casts, in m/s. A sound speed profile is a
%       reference profile plus eofs*coefficients, with the coefficients in units
%       of standard deviations. The sign of each column is chosen such that its
%       largest element is positive.
% info: names and sound speed profiles of the casts, their mean, and the share
%       of the variance of the casts that each EOF carries (all EOFs).

depths = depths(:);
castNames = [compose('CTD %d',ctdNumbers(:)); compose('XBT %d',xbtNumbers(:))];
castTypes = [repmat({'CTD'},numel(ctdNumbers),1); repmat({'XBT'},numel(xbtNumbers),1)];
castNumbers = [ctdNumbers(:); xbtNumbers(:)];
numCasts = numel(castNumbers);

castSpeeds = zeros(numel(depths),numCasts);
for castIndex = 1:numCasts
    castSpeeds(:,castIndex) = readSoundSpeedCastMFP(processedFolder,castTypes{castIndex},castNumbers(castIndex),depths,salinities);
end

meanSpeeds = mean(castSpeeds,2);
[singularVectors,singularValues] = svd(castSpeeds-meanSpeeds,'econ');
coefficientStds = diag(singularValues)/sqrt(numCasts-1);

eofs = singularVectors(:,1:numEOFs).*coefficientStds(1:numEOFs)';
[~,largestIndexes] = max(abs(eofs),[],1);
signs = sign(eofs(sub2ind(size(eofs),largestIndexes,1:numEOFs)));
eofs = eofs.*signs;

info.castNames = castNames;
info.castSpeeds = castSpeeds;
info.meanSpeeds = meanSpeeds;
info.varianceShares = coefficientStds.^2/sum(coefficientStds.^2);

end
