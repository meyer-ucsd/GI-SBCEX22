function [sourceRanges,shipRanges] = getSourceRangesGPSSBCEXP22(shipPositionsFile,times,layback,vlaLatitude,vlaLongitude)
% Horizontal range of the towed source from VLA1 at the given times (datetime,
% UTC) from the GPS of the ship, and the range of the ship itself.
%
% shipPositionsFile: SBCEXP22_shipGPS.mat of the experiment folder
% (processed/shipPositions; sTime [datenum, UTC], sLAT and sLON [deg], one
% position per minute with six decimals; western longitudes are stored as
% positive numbers).
%
% The source is taken to be at the point where the ship was when it was the
% straight-line distance layback [m] away from its present position, i.e., the
% source follows the track of the ship (CHANGES.md, Section 36.3). The
% positions are interpolated linearly in time to 1 s.

ship = load(shipPositionsFile,'sTime','sLAT','sLON');
[shipDatenums,uniqueIndexes] = unique(ship.sTime(:));
latitudes = ship.sLAT(uniqueIndexes);
longitudes = -abs(ship.sLON(uniqueIndexes));
isValid = isfinite(shipDatenums) & isfinite(latitudes(:)) & isfinite(longitudes(:));
shipTimes = datetime(shipDatenums(isValid),'ConvertFrom','datenum');
latitudes = latitudes(isValid); longitudes = longitudes(isValid);

% local plane around VLA1 (WGS84 ellipsoid)
semiMajorAxis = 6378137;
eccentricitySquared = 0.00669437999014;
metersPerDegreeLatitude = pi/180*semiMajorAxis*(1-eccentricitySquared)/(1-eccentricitySquared*sind(vlaLatitude)^2)^1.5;
metersPerDegreeLongitude = pi/180*semiMajorAxis*cosd(vlaLatitude)/sqrt(1-eccentricitySquared*sind(vlaLatitude)^2);
east = (longitudes(:) - vlaLongitude)*metersPerDegreeLongitude;
north = (latitudes(:) - vlaLatitude)*metersPerDegreeLatitude;

searchDuration = 1800;                              % how far back the track is searched for the position of the source [s]
numTimes = numel(times);
sourceRanges = zeros(numTimes,1);
shipRanges = zeros(numTimes,1);
for timeIndex = 1:numTimes
    secondsShip = seconds(shipTimes - times(timeIndex));
    gridSeconds = (-searchDuration:1:0)';
    eastGrid = interp1(secondsShip,east,gridSeconds);
    northGrid = interp1(secondsShip,north,gridSeconds);
    if(any(isnan(eastGrid)))
        error('SBCEX:shipPositions','No ship positions for the %d s before %s',searchDuration,char(times(timeIndex)));
    end
    distances = hypot(eastGrid - eastGrid(end),northGrid - northGrid(end));
    lastFar = find(distances >= layback,1,'last');     % latest time at which the ship was at least layback away
    if(isempty(lastFar) || lastFar == numel(distances))
        error('SBCEX:shipPositions','The ship did not move by %g m in the %d s before %s',layback,searchDuration,char(times(timeIndex)));
    end
    fraction = (distances(lastFar) - layback)/(distances(lastFar) - distances(lastFar+1));
    eastSource = eastGrid(lastFar) + fraction*(eastGrid(lastFar+1) - eastGrid(lastFar));
    northSource = northGrid(lastFar) + fraction*(northGrid(lastFar+1) - northGrid(lastFar));
    sourceRanges(timeIndex) = hypot(eastSource,northSource);
    shipRanges(timeIndex) = hypot(eastGrid(end),northGrid(end));
end

end
