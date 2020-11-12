
% check UW time fields

addpath /home/motteler/cris/ccast/motmsc/time
addpath /home/motteler/cris/ccast/motmsc/utils

d1 = read_netcdf_h5('data/uw_test_sdr.nc');

% show the utc discretization
u1 = d1.obs_time_utc(:, :);

% get tai 93 residual in us
t1 = d1.obs_time_tai93(:);
t1u = mod(t1*1e6, 1e3);
t1m = mod(t1*1e3, 1e3);
t1s = mod(tai2utc(airs2tai(t1)), 60);

% UW CrIS comparison with tai93
% [u1(6:8,:), floor(t1s), floor(t1m), floor(t1u)]

% UW CrIS comparison with tai93_to_utc
% [u1(6:8,:)', u2(6:8,:)']
u2 = tai93_to_utc(t1);
isequal(u1, u2)



