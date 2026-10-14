function [sourceRanges,track] = getSourceTrackMFP(times,laybacks,fixTimes,fixLatitudes,fixLongitudes,vlaLatitude,vlaLongitude)
% Ranges [m] from the VLA of a source towed behind the ship (times x laybacks).
% The ship track is interpolated linearly between GPS fixes (extrapolated
% beyond them), the ship speed is its mean speed from the first to the last
% fix, and the source passes each point of the track layback/shipSpeed after
% the ship. times and fixTimes are datetimes; latitudes and longitudes are in
% degrees (east positive).
% track: ship speed [m/s] and the fixes and source positions in local
% east/north coordinates around the VLA [m]

metersPerDegreeLatitude = 111132.92 - 559.82*cosd(2*vlaLatitude) + 1.175*cosd(4*vlaLatitude);
metersPerDegreeLongitude = 111412.84*cosd(vlaLatitude) - 93.5*cosd(3*vlaLatitude);
track.fixEast = (fixLongitudes(:) - vlaLongitude)*metersPerDegreeLongitude;
track.fixNorth = (fixLatitudes(:) - vlaLatitude)*metersPerDegreeLatitude;

fixSeconds = seconds(fixTimes(:) - fixTimes(1));
track.shipSpeed = sum(hypot(diff(track.fixEast),diff(track.fixNorth)))/fixSeconds(end);

sourceSeconds = seconds(times(:) - fixTimes(1)) - laybacks(:)'/track.shipSpeed;
track.sourceEast = interp1(fixSeconds,track.fixEast,sourceSeconds,'linear','extrap');
track.sourceNorth = interp1(fixSeconds,track.fixNorth,sourceSeconds,'linear','extrap');
sourceRanges = hypot(track.sourceEast,track.sourceNorth);

end
