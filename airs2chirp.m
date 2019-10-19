%
% NAME
%   airs2chirp - AIRS granule to CHIRP granule
%
% SYNOPSIS
%   airs2chirp(agran, cgran, opt1)
%
% INPUTS
%   agran - AIRS input granule file
%   cgran - CHIRP output granule file
%   opt1  - processing options
%
% AUTHOR
%  H. Motteler, 8 July 2019
%

% function airs2chirp(agran, cgran, opt1)

% test values
addpath /home/motteler/cris/ccast/source
addpath /home/motteler/shome/airs_decon/source
s1 = '/asl/data/airs/L1C/2019/120';
s2 = 'AIRS.2019.04.30.036.L1C.AIRS_Rad.v6.1.2.0.G19120112646.hdf';
agran = fullfile(s1, s2);
cgran = './chirp_d20190430_g036';

% AIRS SRF tabulation file
sfile = './airs_demo_srf.hdf';

%-------------------
% setup and options
%-------------------

% translation options
opt1 = struct;
opt1.user_res = 'midres';        % target resolution
opt1.hapod = 1;                  % Hamming apodization
opt1.scorr = 1;                  % statistical correction
opt1.cfile = 'corr_midres.mat';  % correction weights
k = 400;                         % translation chunk size

nchan = 2645;
nobs = 135 * 90;

%---------------------
% read the AIRS data
%---------------------
try
  d1 = read_airs_h4(agran);
catch
  fprintf(1, 'airs2chirp: could not read %s\n', agran)
  return
end

%----------------------------------
% reshape and rename the AIRS data
%----------------------------------
% nchan x xtrack x atrack to nchan x nobs
rad   = reshape(d1.radiances, [nchan, nobs]);
nedn  = reshape(d1.NeN,       [nchan, nobs]);

% xtrack x atrack to nobs
obs_time_tai93   = reshape(d1.Time,      nobs, 1);
lat              = reshape(d1.Latitude,  nobs, 1);
lon              = reshape(d1.Longitude, nobs, 1);
view_ang         = reshape(d1.scanang,   nobs, 1);
sat_zen          = reshape(d1.satzen,    nobs, 1);
sat_azi          = reshape(d1.satazi,    nobs, 1);
sol_zen          = reshape(d1.solzen,    nobs, 1);
sol_azi          = reshape(d1.solazi,    nobs, 1);
land_frac        = reshape(d1.landFrac,  nobs, 1);
surf_alt         = reshape(d1.topog,     nobs, 1);
surf_alt_sdev    = reshape(d1.topog_err, nobs, 1);
instrument_state = reshape(d1.state,     nobs, 1);

% atrack to nobs (copy values across scans)
subsat_lat     = reshape(repmat(d1.sat_lat',   90, 1), nobs, 1);
subsat_lon     = reshape(repmat(d1.sat_lon',   90, 1), nobs, 1);
scan_mid_time  = reshape(repmat(d1.nadirTAI',  90, 1), nobs, 1);
sat_alt        = reshape(repmat(d1.satheight', 90, 1), nobs, 1);
sun_glint_lat  = reshape(repmat(d1.glintlat',  90, 1), nobs, 1);
sun_glint_lon  = reshape(repmat(d1.glintlon',  90, 1), nobs, 1);
asc_flag       = reshape(repmat(d1.scan_node_type', 90, 1), nobs, 1);

% add atrack and xtrack indices
atrack_ind = reshape(repmat(1:135, 90, 1), nobs, 1);
xtrack_ind = reshape(repmat((1:90)', 1, 135), nobs, 1);

% AIRS wnum shape is unchanged
wnum  = d1.nominal_freq;

% whos rad nedn
% whos obs_time_tai93 lat lon view_ang sat_zen sat_azi ...
%   sol_zen sol_azi land_frac surf_alt instrument_state
% whos subsat_lat subsat_lon scan_mid_time sat_alt ...
%   sun_glint_lat sun_glint_lon asc_flag xtrack_ind atrack_ind wnum

% clear d1

% AIRS scene QC from geo, radiance, and instrument_state
iOK = -90 <= lat & lat <= 90 & -180 <= lon & lon <= 180 ...
      & cAND(-1 < rad & rad < 250)' & instrument_state == 0;

% translate iOK to NASA-style flags, 0=OK, 1=maybe, 2=bad
rad_qc = ~iOK * 2;

return

%--------------------------
% AIRS to CrIS translation
%--------------------------

% profile clear
% profile on
  tic

% loop on chunks
for j = 1 : k : nobs
  
  % indices for current chunk
  ix = j : min(j+k-1, nobs);

  % call airs2cris on the chunk
  [rtmp, cfrq] = airs2cris(rad(:, ix), wnum, sfile, opt1);

  % initialize output after first obs
  if j == 1
    [m, ~] = size(rtmp);
    crad = zeros(m, nobs);
  end

  % save the current chunk
  crad(:, ix) = rtmp;

% fprintf(1, '.')
end
fprintf(1, '\n')

  toc
% profile report

%----------------------------
% save translation as netCDF
%----------------------------

nc_init = 'chirp_init.nc';
nc_data = 'chirp_data.nc';
copyfile(nc_init, nc_data);

ncwrite(nc_data, 'rad', single(crad))
% ncwrite(nc_data, 'nedn', nedn)

ncwrite(nc_data, 'obs_time_tai93', obs_time_tai93);
ncwrite(nc_data, 'lat', lat);
ncwrite(nc_data, 'lon', lon);
ncwrite(nc_data, 'view_ang', view_ang);
ncwrite(nc_data, 'sat_zen', sat_zen);
ncwrite(nc_data, 'sat_azi', sat_azi);
ncwrite(nc_data, 'sol_zen', sol_zen);
ncwrite(nc_data, 'sol_azi', sol_azi);
ncwrite(nc_data, 'land_frac', land_frac);
ncwrite(nc_data, 'surf_alt', surf_alt);
ncwrite(nc_data, 'surf_alt_sdev', surf_alt_sdev);
ncwrite(nc_data, 'instrument_state', instrument_state);

ncwrite(nc_data, 'subsat_lat', subsat_lat);
ncwrite(nc_data, 'subsat_lon', subsat_lon);
ncwrite(nc_data, 'scan_mid_time', scan_mid_time);
ncwrite(nc_data, 'sat_alt', sat_alt);
ncwrite(nc_data, 'sun_glint_lat', sun_glint_lat);
ncwrite(nc_data, 'sun_glint_lon', sun_glint_lon);
ncwrite(nc_data, 'asc_flag', asc_flag);
ncwrite(nc_data, 'atrack_ind', atrack_ind);
ncwrite(nc_data, 'xtrack_ind', xtrack_ind);
ncwrite(nc_data, 'wnum', cfrq)

return

wnum2 = ncread(nc_data, 'wnum');
rad2 = ncread(nc_data, 'rad');

isequal(cfrq, wnum2)
isequal(single(crad), rad2)

