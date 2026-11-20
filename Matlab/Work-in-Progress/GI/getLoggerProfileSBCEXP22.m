function speeds = getLoggerProfileSBCEXP22(ssp,loggers,waterDepth)
% Sound speed profile of the water at VLA1 from the temperature loggers of the
% array and a reference cast, on the depths ssp.depths.
%
% ssp.depths, ssp.speeds: reference profile (the cast used so far, XBT #11)
% ssp.salinities:         salinity on ssp.depths (CTD #16)
% loggers.heights:        heights of the loggers above the seafloor, top first
% loggers.temperatures:   their temperatures [deg C] (getLoggerTemperaturesSBCEXP22.m)
%
% The loggers are on the array, which stands on the seafloor: their depths are
% waterDepth - loggers.heights and move with the water depth of the model, as
% the hydrophones do (getReceiverGeometrySBCEXP22.m).
%
% Between the top and the bottom logger: sound speed from the temperatures of
% the loggers (Mackenzie, J. Acoust. Soc. Am. 70, 807, 1981) with the salinity
% of ssp.salinities, interpolated over depth (pchip).
% Below the bottom logger: the reference profile, shifted by the difference at
% the bottom logger.
% Above the top logger: the reference profile; in the 10 m above the top
% logger the difference at the top logger is blended in linearly, so that the
% profile has no step.
% (CHANGES.md, Section 31.5.)

blendLength = 10;                                   % [m]

loggerDepths = waterDepth - loggers.heights(:);
loggerTemperatures = loggers.temperatures(:);
loggerSalinities = interp1(ssp.depths,ssp.salinities,loggerDepths,'linear','extrap');
loggerSpeeds = 1448.96 + 4.591*loggerTemperatures - 5.304e-2*loggerTemperatures.^2 + 2.374e-4*loggerTemperatures.^3 ...
    + 1.340*(loggerSalinities-35) + 1.630e-2*loggerDepths + 1.675e-7*loggerDepths.^2 ...
    - 1.025e-2*loggerTemperatures.*(loggerSalinities-35) - 7.139e-13*loggerTemperatures.*loggerDepths.^3;
referenceAtLoggers = interp1(ssp.depths,ssp.speeds,loggerDepths,'linear','extrap');

speeds = ssp.speeds;
isInside = ssp.depths >= loggerDepths(1) & ssp.depths <= loggerDepths(end);
speeds(isInside) = interp1(loggerDepths,loggerSpeeds,ssp.depths(isInside),'pchip');
isBelow = ssp.depths > loggerDepths(end);
speeds(isBelow) = ssp.speeds(isBelow) + (loggerSpeeds(end) - referenceAtLoggers(end));
isAbove = ssp.depths < loggerDepths(1) & ssp.depths >= loggerDepths(1) - blendLength;
speeds(isAbove) = ssp.speeds(isAbove) + (loggerSpeeds(1) - referenceAtLoggers(1))*(1 - (loggerDepths(1) - ssp.depths(isAbove))/blendLength);

end
