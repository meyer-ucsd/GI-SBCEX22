% Write a KRAKEN environment file for the SBCEXP 2022 shelf break: water
% column with measured sound speed, thin sediment layer with a gradient, and an
% acoustic halfspace. The upper phase-speed limit equals the halfspace speed, so
% only trapped modes are computed (leaky modes would require KRAKENC).

function writeKrakenEnv(envFile,frequency,waterDepth,sspDepths,sspSpeeds,sediment,halfspace,sourceDepths,receiverDepths)

fid = fopen(envFile,'w');
if fid == -1
    error('Cannot open %s for writing',envFile);
end

% title, frequency, number of media, and SSP option (C-linear, vacuum above, dB/(m kHz))
fprintf(fid,'%s\n','''SBCEXP 2022 Shelfbreak (Layered Sediment + Sandy Halfspace)''');
fprintf(fid,'%f\n',frequency);
fprintf(fid,'%d\n',2);
fprintf(fid,'%s\n','''CVF''');

% medium 1: water column
fprintf(fid,'%d %1.1f %8.3f\n',0,0.0,waterDepth);
for sspIndex = 1:numel(sspDepths)
    if sspIndex == 1
        fprintf(fid,'%8.3f %8.3f %4.1f %5.3f %4.1f %4.1f /\n',sspDepths(sspIndex),sspSpeeds(sspIndex),0.0,1.000,0.0,0.0);
    else
        fprintf(fid,'%8.3f %8.3f /\n',sspDepths(sspIndex),sspSpeeds(sspIndex));
    end
end

% medium 2: thin sediment layer with linear gradient
sedimentBottomDepth = waterDepth + sediment.thickness;
fprintf(fid,'%d %1.1f %8.3f\n',0,0.0,sedimentBottomDepth);
fprintf(fid,'%8.3f %8.3f %4.1f %5.3f %6.4f %4.1f /\n',waterDepth,sediment.speeds(1),0.0,sediment.densities(1),sediment.attenuations(1),0.0);
fprintf(fid,'%8.3f %8.3f %4.1f %5.3f %6.4f %4.1f /\n',sedimentBottomDepth,sediment.speeds(2),0.0,sediment.densities(2),sediment.attenuations(2),0.0);

% acoustic halfspace below the sediment layer
fprintf(fid,'%s\n','''A'' 0.0');
fprintf(fid,'%8.3f %8.3f %4.1f %5.3f %6.4f %4.1f /\n',sedimentBottomDepth,halfspace.speed,0.0,halfspace.density,halfspace.attenuation,0.0);

% phase-speed limits and maximum range in km
fprintf(fid,'%8.2f %8.2f\n',0.0,halfspace.speed);
fprintf(fid,'%8.2f\n',20.0);

% source and receiver depths
fprintf(fid,'%d\n',numel(sourceDepths));
fprintf(fid,'%8.3f ',sourceDepths);
fprintf(fid,'/\n');
fprintf(fid,'%d\n',numel(receiverDepths));
fprintf(fid,'%8.3f ',receiverDepths);
fprintf(fid,'/\n');

fclose(fid);

end
