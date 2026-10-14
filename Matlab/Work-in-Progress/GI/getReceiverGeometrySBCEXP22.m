function [receiverDepths,receiverOffsets] = getReceiverGeometrySBCEXP22(hydrophoneHeights,waterDepth,tilt)
% The VLA is moored on the seafloor, so the hydrophones are at fixed heights
% above the bottom (hydrophone 1, the deepest, first) and move with the water
% depth. The array pivots about hydrophone 1; positive tilt makes the array lean
% away from the source, i.e., the range of the upper elements is increased.

heightsAboveFirst = hydrophoneHeights - hydrophoneHeights(1);

receiverDepths = waterDepth - hydrophoneHeights(1) - heightsAboveFirst*cosd(tilt);
receiverOffsets = heightsAboveFirst*sind(tilt);

end
