%% Write KRAKEN environment file for the SBCEXP 2022 Shelfbreak (200 m)
%% (Two-Media Model: Thin Sediment Layer + Sandy Halfspace)

fid = fopen('SBCEXP_200m.env', 'w');

%% Title
TITLE = '''SBCEXP 2022 Shelfbreak 200 m (Layered Sediment + Sandy Halfspace)''';
fprintf(fid, '%s\n', TITLE);

%% Frequency
fprintf(fid, '%f\n', f0);

%% Number of media
% Medium 1 = Water column
% Medium 2 = Thin sediment layer
NMEDIA = 2;
fprintf(fid, '%d\n', NMEDIA);

%% SSP option
SSPOPT = '''CVF''';
fprintf(fid, '%s\n', SSPOPT);

%% -------------------------
% Medium 1: Water column
% -------------------------
water_depth = 200.0;
NMESH = 0;
SIGMA = 0.0;
fprintf(fid, '%d %1.1f %4.2f\n', NMESH, SIGMA, water_depth);

Nssp = 500;
z_env = linspace(0, water_depth, Nssp).';
c_env = interp1(z_new(:), c_new(:), z_env, 'pchip', 'extrap');

for ii = 1:Nssp
    if ii == 1
        % depth, cp, cs, density, compressional attenuation, shear attenuation
        fprintf(fid, '%8.3f %8.3f %4.1f %5.3f %4.1f %4.1f /\n', ...
            z_env(ii), c_env(ii), 0.0, 1.000, 0.0, 0.0);
    else
        fprintf(fid, '%8.3f %8.3f /\n', z_env(ii), c_env(ii));
    end
end

%% -------------------------
% Medium 2: Thin sediment layer
% -------------------------
% Based on shelf-break sediment cores (AC-18 to AC-23) reported in
% Ballard et al. (2024, Fig. 13).
NMESH2 = 0;
SIGMA2 = 0.0;
sed_thickness = 1.5;                    % [m] Thickness of the surface sediment layer (example value)
sed_bottom_depth = water_depth + sed_thickness;

fprintf(fid, '%d %1.1f %4.2f\n', NMESH2, SIGMA2, sed_bottom_depth);

% Top and bottom of the sediment layer (gradient profile)
z_sed  = [water_depth;      sed_bottom_depth];
cp_sed = [1550.0;           1620.0];    % [m/s] Compressional sound speed
rho_sed = [1.60;            1.80];      % [g/cm^3] Density
ap_sed  = [0.30;            0.55];      % [dB/m/kHz] (valid when SSPOPT(3) = 'F')
cs_sed  = 0.0;                          % Shear wave speed neglected

fprintf(fid, '%8.3f %8.3f %4.1f %5.3f %4.2f %4.1f /\n', ...
    z_sed(1), cp_sed(1), cs_sed, rho_sed(1), ap_sed(1), 0.0);
fprintf(fid, '%8.3f %8.3f %4.1f %5.3f %4.2f %4.1f /\n', ...
    z_sed(2), cp_sed(2), cs_sed, rho_sed(2), ap_sed(2), 0.0);

%% -------------------------
% Bottom Boundary Condition: Acoustic Halfspace
% -------------------------
BOTOPT = '''A'' 0.0';
fprintf(fid, '%s\n', BOTOPT);

% The acoustic halfspace begins immediately below the sediment layer
z_hs = sed_bottom_depth;
cp_hs = 1650.0;    % Compressional sound speed representative of sandy shelf-break sediments
                  % (recommended to verify using the sound-speed ratio in Fig. 4/6)
cs_hs = 0.0;
rho_hs = 1.85;     % [g/cm^3] Sandy sediment density
ap_hs = 0.65;      % Compressional attenuation [dB/m/kHz] (SSPOPT(3) = 'F')
as_hs = 0.0;

fprintf(fid, '%8.3f %8.3f %4.1f %5.3f %4.2f %4.1f /\n', ...
    z_hs, cp_hs, cs_hs, rho_hs, ap_hs, as_hs);

%% Phase speed limits
LOWMOD = 0.0;
UPMOD = 1800.0;   % Set sufficiently above cp_hs (1650 m/s)
fprintf(fid, '%8.2f %8.2f\n', LOWMOD, UPMOD);

%% Maximum range [km]
MAXR = 20.0;
fprintf(fid, '%8.2f\n', MAXR);

%% Source depths
SD = zs(:);
fprintf(fid, '%d\n', length(SD));
fprintf(fid, '%8.3f ', SD);
fprintf(fid, '/\n');

%% Receiver depths
RD = RD(:);
fprintf(fid, '%d\n', length(RD));
fprintf(fid, '%8.3f ', RD);
fprintf(fid, '/\n');

fclose(fid);