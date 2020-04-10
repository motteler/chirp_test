%
% NAME
%   read_cris_h5 - read a CrIS H5/netCDF granule
%
% SYNOPSIS
%   d1 = read_cris_h5(cgran) 
%
% INPUT
%   cgran - CrIS input granule file
%
% OUTPUT
%   d1 - struct with CrIS data
%
% DISCUSSION
%   we only read the fields needed for CHIRP processing
%
% AUTHOR
%   H. Motteler, 22 Dec 2019
%

function d1 =read_cris_h5(cgran)

d1 = struct;

% radiance, nchan x nFOV x nFOR x nscan
d1.rad_lw = h5read(cgran, '/rad_lw');
d1.rad_mw = h5read(cgran, '/rad_mw');
d1.rad_sw = h5read(cgran, '/rad_sw');

% per-granule NEdN, nchan x nFOV arrays
d1.nedn_lw = h5read(cgran, '/nedn_lw');
d1.nedn_mw = h5read(cgran, '/nedn_mw');
d1.nedn_sw = h5read(cgran, '/nedn_sw');

% per-band frequency, nchan vectors
d1.wnum_lw = h5read(cgran, '/wnum_lw');
d1.wnum_mw = h5read(cgran, '/wnum_mw');
d1.wnum_sw = h5read(cgran, '/wnum_sw');

% TAI time, nFOR x nscan array
d1.obs_time_tai93   = h5read(cgran, '/obs_time_tai93');

% *** TEST ***  added fields
d1.obs_time_utc = h5read(cgran, '/obs_time_utc');
d1.obs_id       = h5read(cgran, '/obs_id');
d1.fov_obs_id   = h5read(cgran, '/fov_obs_id');
d1.sat_range    = h5read(cgran, '/sat_range');
d1.lat_bnds     = h5read(cgran, '/lat_bnds');
d1.lon_bnds     = h5read(cgran, '/lon_bnds');

% full swath data, nFOV x nFOR x nscan arrays
d1.lat              = h5read(cgran, '/lat');
d1.lon              = h5read(cgran, '/lon');
d1.view_ang         = h5read(cgran, '/view_ang');
d1.sat_zen          = h5read(cgran, '/sat_zen');
d1.sat_azi          = h5read(cgran, '/sat_azi');
d1.sol_zen          = h5read(cgran, '/sol_zen');
d1.sol_azi          = h5read(cgran, '/sol_azi');
d1.land_frac        = h5read(cgran, '/land_frac');
d1.surf_alt         = h5read(cgran, '/surf_alt');
d1.surf_alt_sdev    = h5read(cgran, '/surf_alt_sdev');
d1.instrument_state = h5read(cgran, '/instrument_state');
d1.rad_lw_qc        = h5read(cgran, '/rad_lw_qc');
d1.rad_mw_qc        = h5read(cgran, '/rad_mw_qc');
d1.rad_sw_qc        = h5read(cgran, '/rad_sw_qc');

% along-track data, nscan vectors
d1.subsat_lat     = h5read(cgran, '/subsat_lat');
d1.subsat_lon     = h5read(cgran, '/subsat_lon');
d1.scan_mid_time  = h5read(cgran, '/scan_mid_time');
d1.sat_alt        = h5read(cgran, '/sat_alt');
d1.sun_glint_lat  = h5read(cgran, '/sun_glint_lat');
d1.sun_glint_lon  = h5read(cgran, '/sun_glint_lon');
d1.asc_flag       = h5read(cgran, '/asc_flag');

