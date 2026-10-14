function [speeds,cast] = readSoundSpeedCastMFP(processedFolder,castType,castNumber,depths,salinities)
% Sound speed profile [m/s] at depths [m] (regular grid) from an SBCEXP 2022
% CTD or XBT cast in the processed data folder. Samples are averaged in depth
% bins centered on the grid points; above the shallowest and below the deepest
% bin with data the profile is held constant.
% CTD: downcast of the Chen-Millero sound speed in the CTD matfiles.
% XBT: measured temperature and the given salinity profile (e.g., from a CTD)
% in Mackenzie's (1981) equation, which reproduces the Chen-Millero sound
% speed of the shelf-break CTDs to within 0.03 m/s.
% cast: name, launch time (UTC), latitude and longitude [deg, east positive],
% temperature [deg C] and salinity [PSU] at depths.

depths = depths(:);
binEdges = [depths(1)-(depths(2)-depths(1))/2; (depths(1:end-1)+depths(2:end))/2; depths(end)+(depths(end)-depths(end-1))/2];

switch upper(castType)
    case 'CTD'
        data = load(fullfile(processedFolder,'CTDs','ctd_SSP_mat',sprintf('SBCEXP22_ssp_ctd%03d.mat',castNumber)));
        [~,deepestIndex] = max(data.ctd_Depth);
        sampleDepths = data.ctd_Depth(1:deepestIndex);
        speeds = binAverage(sampleDepths,data.ctd_ssp(1:deepestIndex),binEdges);
        temperatures = binAverage(sampleDepths,data.ctd_temp(1:deepestIndex),binEdges);
        castSalinities = binAverage(sampleDepths,data.ctd_sal(1:deepestIndex),binEdges);
        [launchTime,latitude,longitude] = readCtdLog(processedFolder,castNumber);
    case 'XBT'
        data = load(fullfile(processedFolder,'XBTs','xbt_matfiles',sprintf('xbt%03d_TEMP.mat',castNumber)));
        temperatures = binAverage(data.xbt_depth,data.xbt_temp,binEdges);
        castSalinities = salinities(:);
        speeds = mackenzieSoundSpeed(temperatures,castSalinities,depths);
        launchTime = datetime(data.xbtTimeStamp,'ConvertFrom','datenum');
        latitude = data.xbtLAT;
        longitude = -abs(data.xbtLON);      % stored as degrees west
    otherwise
        error('Unknown cast type %s (CTD or XBT)',castType);
end

cast = struct('name',sprintf('%s %d',upper(castType),castNumber),'time',launchTime,'latitude',latitude, ...
    'longitude',longitude,'temperature',temperatures,'salinity',castSalinities);

end


function values = binAverage(sampleDepths,sampleValues,binEdges)

sampleDepths = sampleDepths(:);
sampleValues = sampleValues(:);
[~,~,binIndexes] = histcounts(sampleDepths,binEdges);
inGrid = binIndexes > 0 & ~isnan(sampleValues);
values = accumarray(binIndexes(inGrid),sampleValues(inGrid),[numel(binEdges)-1,1],@mean,nan);

measured = find(~isnan(values));
if isempty(measured)
    error('Cast has no samples within the depth grid');
end
values(1:measured(1)-1) = values(measured(1));
values(measured(end)+1:end) = values(measured(end));
gaps = isnan(values);
if any(gaps)
    values(gaps) = interp1(find(~gaps),values(~gaps),find(gaps));
end

end


function [launchTime,latitude,longitude] = readCtdLog(processedFolder,castNumber)
% launch time and position from the CTD log (cast, date, Julian day, time,
% latitude N, longitude W, ...)

fid = fopen(fullfile(processedFolder,'CTDs','ReadMe_CTDtimes.csv'));
if fid == -1
    error('CTD log ReadMe_CTDtimes.csv not found');
end
columns = textscan(fid,'%f %s %f %s %f %s %f %*[^\n]','Delimiter',',','HeaderLines',2);
fclose(fid);

row = find(columns{1} == castNumber,1);
if isempty(row)
    error('CTD %d is not in the CTD log',castNumber);
end
launchTime = datetime([strtrim(columns{2}{row}),' ',strtrim(columns{4}{row})],'InputFormat','MM/dd/yyyy HH:mm:ss');
latitude = columns{5}(row);
longitude = -columns{7}(row);

end


function speeds = mackenzieSoundSpeed(temperatures,salinities,depths)
% Mackenzie (1981), J. Acoust. Soc. Am. 70(3), 807-812

speeds = 1448.96 + 4.591*temperatures - 5.304e-2*temperatures.^2 + 2.374e-4*temperatures.^3 ...
    + 1.340*(salinities-35) + 1.630e-2*depths + 1.675e-7*depths.^2 ...
    - 1.025e-2*temperatures.*(salinities-35) - 7.139e-13*temperatures.*depths.^3;

end
