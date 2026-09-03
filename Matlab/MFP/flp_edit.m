%% (1) Write the input file
fid = fopen('SBCEXP_200m.flp', 'w');

%% (2) the title
TITLE = '''SBCEXP 2022 Shelfbreak 200 m''';
fprintf(fid,'%s \n',TITLE);

%% (3) Option
OPT = '''RA''';                          
fprintf(fid,'%s \n',OPT);

%% (4) number of mode to include 
M = 9999;
fprintf(fid, '%d \n', M);

%% (5) profile ranges
NPROF = 1;
RPROF = [0.0];

fprintf(fid, '%d   \n', NPROF);
for idx = 1:length(RPROF)
    fprintf(fid, '%4.2f ', RPROF);
end
fprintf(fid,'%s \n', '/');

%% (6) Range
RR = 3.0;
fprintf(fid,'%d\n', length(RR));
fprintf(fid,'%f ', RR);
fprintf(fid,'%c', '/');
fprintf(fid,'%c\n', ' '); 

SD = zs;
fprintf(fid,'%d \n', length(SD));
for ii = 1:length(SD)
    fprintf(fid,'%f ', SD(ii));
end
fprintf(fid,'%s \n', '/');

% RD = linspace(94.125,212.25,64);
fprintf(fid,'%d\n', length(RD));
for ii = 1:length(RD)
    fprintf(fid,'%4.4f ', RD(ii));
end
fprintf(fid,'%s \n', '/');

% receiver displacement;
RRD = [0.0];
fprintf(fid,'%d \n', length(RRD));
fprintf(fid,'%1.1f %s \n', RRD, '/');

fclose(fid);