% Florian Meyer, 2024

function [receiverDepthsTilted,receiverOffsets] = getReceiverDepthOffset(receiverDepths,tilt)
% positive tilt makes the array lean away from the source, i.e., the range of
% the first (shallowest) element with respect to the source is increased; the
% last (deepest) element has always an offset of zero

% compute height of VLA
receiverZs = -receiverDepths;
receiverHeights = receiverZs-receiverZs(end);

% apply tilt
receiverHeightsTilted = receiverHeights*cosd(tilt);
receiverOffsets = receiverHeights*sind(tilt);

% get depths of tilted array elements
receiverZsTilted = receiverHeightsTilted+receiverZs(end);
receiverDepthsTilted = - receiverZsTilted;

end