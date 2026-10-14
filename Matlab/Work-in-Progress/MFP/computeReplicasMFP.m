function replicas = computeReplicasMFP(modes,hydrophoneDepths,hydrophoneOffsets,searchDepths,searchRanges)
% Unit-norm replica vectors (hydrophones x (depths*ranges), depth index
% varying fastest) from KRAKEN modes.

modeDepths = double(modes.z(:));
k = double(modes.k(:));
phi = double(modes.phi);
phiHydrophones = phi(findDepthRows(modeDepths,hydrophoneDepths),:);
phiSearch = phi(findDepthRows(modeDepths,searchDepths),:);

numHydrophones = numel(hydrophoneDepths);
numDepths = numel(searchDepths);
numRanges = numel(searchRanges);
replicas = zeros(numHydrophones,numDepths,numRanges);

% the Hankel functions depend only on range, so they are computed once per
% distinct hydrophone range offset (once in total for an untilted array)
[uniqueOffsets,~,offsetIndexes] = unique(hydrophoneOffsets);
for offsetIndex = 1:numel(uniqueOffsets)
    hankel = besselh(0,2,k*(searchRanges(:)'+uniqueOffsets(offsetIndex)));
    for hydrophoneIndex = find(offsetIndexes == offsetIndex)'
        replicas(hydrophoneIndex,:,:) = reshape((phiSearch.*phiHydrophones(hydrophoneIndex,:))*hankel,[1,numDepths,numRanges]);
    end
end

replicas = reshape(replicas,numHydrophones,[]);
replicas = replicas./vecnorm(replicas);

end


function rows = findDepthRows(modeDepths,depths)

[distances,rows] = min(abs(modeDepths-depths(:)'),[],1);
if any(distances > 2e-3)
    error('KRAKEN did not return modes at all requested depths');
end
rows = rows(:);

end
