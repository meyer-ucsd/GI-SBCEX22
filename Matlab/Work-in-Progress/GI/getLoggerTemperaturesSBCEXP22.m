function [temperatures,heights] = getLoggerTemperaturesSBCEXP22(loggerFolder,hydrophoneHeights,timeStart,duration)
% Temperatures of the 17 temperature loggers of VLA1 (HOBO, one value per
% minute) for the time span from timeStart to timeStart + duration (datetime
% and duration, UTC), and the heights of the loggers above the seafloor. Both
% are ordered from the top (marker float) to the bottom (hydrophone 1). The
% temperatures are the mean of the values within half a minute of the span.
%
% loggerFolder: folder with the files SBCEXP22_<serial number>.mat of the
% experiment folder (processed/TLoggers_HOBO/HOBOs_matfiles; temp [deg C] and
% tempTime [datenum, UTC]). The value Depth_offSeafloor of these files does
% not belong to the deployment at the 200 m contour and is not used.
%
% Positions (documents/VLA1_HOBO_Staroddi_Locations.txt of the experiment
% folder): one logger 0.2286 m below each hydrophone, serial numbers 20475327
% (hydrophone 16) to 20475342 (hydrophone 1), and 20475326 on the marker
% float, 5.8 m (+/- 0.2 m) above the logger of hydrophone 16.
% hydrophoneHeights: heights of the hydrophones above the seafloor, hydrophone
% 1 first (scenario.hydrophoneHeights).
%
% Calibration: all loggers were on the frame of CTD #28 (JD 151). The median
% of logger minus CTD on the plateaus of that cast is subtracted (0.03 deg C
% on average, 0.03 deg C between the loggers; CHANGES.md, Section 31).

serialNumbers = (20475326:20475342)';
calibrationOffsets = [0.021;0.082;0.025;0.002;0.052;0.058;-0.026;0.036;0.042;-0.005;0.022;0.048;-0.005;0.056;0.065;-0.030;-0.011];      % logger minus CTD #28 [deg C], in the order of the serial numbers
loggerBelowHydrophone = 0.2286;                     % [m]
floatAboveTopLogger = 5.8;                          % [m]

heightsBelowHydrophones = flip(hydrophoneHeights(:)) - loggerBelowHydrophone;       % logger of hydrophone 16 first
heights = [heightsBelowHydrophones(1) + floatAboveTopLogger;heightsBelowHydrophones];

temperatures = zeros(numel(serialNumbers),1);
for loggerIndex = 1:numel(serialNumbers)
    logger = load(fullfile(loggerFolder,sprintf('SBCEXP22_%d.mat',serialNumbers(loggerIndex))),'temp','tempTime');
    loggerTimes = datetime(logger.tempTime(:),'ConvertFrom','datenum');
    inSpan = loggerTimes >= timeStart - seconds(30) & loggerTimes <= timeStart + duration + seconds(30);
    if(~any(inSpan))
        error('SBCEX:loggerData','Logger %d has no value between %s and %s',serialNumbers(loggerIndex),char(timeStart),char(timeStart + duration));
    end
    temperatures(loggerIndex) = mean(logger.temp(inSpan)) - calibrationOffsets(loggerIndex);
end

end
