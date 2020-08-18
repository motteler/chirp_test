%
% quick look at chirp data and attributes
%

addpath /home/motteler/cris/ccast/source

% airs-parent chirp
p1 = '/asl/isilon/chirp/chirp_AQ_test4/2019/063';
g1 = 'SNDR.SS1330.CHIRP.20190304T0223.m06.g024.L1_AQ.std.v02_20.U.2008161625.nc';

% cris_parent chirp
p2 = '/asl/isilon/chirp/chirp_SN_test4/2019/063';
g2 = 'SNDR.SS1330.CHIRP.20190304T0217.m06.g024.L1_SN.std.v02_20.U.2008161547.nc';

% AIRS L1b data
p3 = '/asl/airs/l1c_v672/2019/061';
g3 = 'AIRS.2019.03.02.005.L1C.AIRS_Rad.v6.7.2.0.G19364174212.hdf';

% CrIS L1b data
p4 = '.';
g4 = 'uw_sdr_test.nc';

[d1, a1] = read_netcdf_h5(fullfile(p1, g1));  % AIRS parent
[d2, a2] = read_netcdf_h5(fullfile(p2, g2));  % CrIS parent
[d3, a3] = read_airs_h4(fullfile(p3, g3));    % AIRS data
[d4, a4] = read_netcdf_h5(fullfile(p4, g4));  % CrIS data

return

a2.history
a2.production_host
a2.date_created
% a2.algorithm_version
a2.source
a2.shortname
