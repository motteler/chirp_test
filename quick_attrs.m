%
% quick look at chirp data and attributes
%

addpath /home/motteler/cris/ccast/source

% airs-parent chirp
p1 = '/asl/isilon/chirp/chirp_AQ_test4/2019/058';
g1 = 'SNDR.SS1330.CHIRP.20190227T0905.m06.g091.L1_AQ.std.v02_20.U.2008221733.nc';

% J1 cris-parent chirp
p2 = '/asl/isilon/chirp/chirp_J1_test4/2019/058';
g2 = 'SNDR.SS1000.CHIRP.20190227T0859.m06.g091.L1_J1.std.v02_20.U.2008221530.nc';

% SN cris-parent chirp
% p2 = '/asl/isilon/chirp/chirp_SN_test4/2019/058';
% g2 = 'SNDR.SS1330.CHIRP.20190227T0859.m06.g091.L1_SN.std.v02_20.U.2008221709.nc';

% AIRS L1C data
p3 = '/asl/airs/l1c_v672/2019/061';
g3 = 'AIRS.2019.03.02.005.L1C.AIRS_Rad.v6.7.2.0.G19364174212.hdf';

% CrIS L1b data
p4 = '.';
g4 = 'data/uw_test_sdr.nc';

[d1, a1] = read_netcdf_h5(fullfile(p1, g1));  % AIRS parent CHIRP
[d2, a2] = read_netcdf_h5(fullfile(p2, g2));  % CrIS parent CHIRP
[d3, a3] = read_airs_h4(fullfile(p3, g3));    % AIRS L1C data
[d4, a4] = read_netcdf_h5(fullfile(p4, g4));  % CrIS L1B data

% return
ax = a2;

ax.AutomaticQualityFlag
ax.day_night_flag
ax.geospatial_bounds
ax.geospatial_lat_max
ax.geospatial_lat_mid
ax.geospatial_lat_min
ax.geospatial_lon_max
ax.geospatial_lon_mid
ax.geospatial_lon_min
ax.granule_number
ax.history
ax.orbitDirection
ax.qa_no_data
ax.qa_pct_data_missing
ax.qa_pct_data_geo
ax.qa_pct_data_sci_mode
ax.time_coverage_duration
ax.time_coverage_end
ax.time_coverage_mid
ax.time_coverage_start
ax.time_of_first_valid_obs
ax.time_of_last_valid_obs

return

a2.history
a2.production_host
a2.date_created
% a2.algorithm_version
a2.source
a2.shortname
