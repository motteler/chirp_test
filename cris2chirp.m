%
% NAME
%   cris2chirp - interpolate CrIS to CHIRP granules
%
% SYNOPSIS
%   cris2chirp(cris_gran, chirp_dir, prod_name, proc_opts)
%
% INPUTS
%   cris_gran  - CrIS input granule file
%   chirp_dir  - CHIRP output granule dir
%   prod_name  - product attributes
%   proc_opts  - processing options
%
% proc_opts are mainly for testing; the default values should be
% used for production.
%
% AUTHOR
%  H. Motteler, 18 Dec 2019
%

function cris2chirp(cris_gran, chirp_dir, prod_name, proc_opts)

%---------------------------
% setup and default options
%---------------------------

% general options
verbose = 0;  % 0 = quiet, 1 = talky, 2 = plots

% interpolation options
hapod = 1;             % apply Hamming apodization
user_res = 'midres';   % target user resolution
inst_res = 'hires3';   % nominal value for inst res
wlaser = 773.1301;     % nominal value for wlaser

% mid-res apodized scale factors for high res CrIS NEdN
nedn_lw_sf = 0.6325;   % Hamming apodization only
nedn_mw_sf = 0.5455;   % interpolation and Hamming
nedn_sw_sf = 0.4446;   % interpolation and Hamming

% option to override defaults 
if nargin == 4
  if isfield(proc_opts, 'verbose'),    verbose    = proc_opts.verbose; end
  if isfield(proc_opts, 'hapod'),      hapod      = proc_opts.hapod; end
  if isfield(proc_opts, 'user_res'),   user_res   = proc_opts.user_res; end
  if isfield(proc_opts, 'nedn_lw_sf'), nedn_lw_sf = proc_opts.nedn_lw_sf; end
  if isfield(proc_opts, 'nedn_mw_sf'), nedn_mw_sf = proc_opts.nedn_mw_sf; end
  if isfield(proc_opts, 'nedn_sw_sf'), nedn_sw_sf = proc_opts.nedn_sw_sf; end
end

% options for inst_params.m
opt2 = struct;
opt2.user_res = user_res;
opt2.inst_res = inst_res;

% this function name
fstr = mfilename;  

% optional parameter summary
if verbose
 fprintf(1, '------------------------------------------------\n')
 fprintf(1, '%s: hapod=%d user_res=%s \n', fstr, hapod, user_res)
 fprintf(1, '%s: NEdN scale factors %.4f %.4f %.4f\n', ...
    fstr, nedn_lw_sf, nedn_mw_sf, nedn_sw_sf)
end

% check source file 
if exist(cris_gran) ~= 2
  fprintf(1, '%s: missing source file %s\n', fstr, cris_gran)
  return
end

% check output directory
if exist(chirp_dir) ~= 7, 
  fprintf(1, '%s: bad output path %s\n', fstr, chirp_dir)
  return
end

%----------------
% read CrIS data
%----------------
try
  d1 = read_cris_h5(cris_gran);
catch
  fprintf(1, '%s: could not read %s\n', fstr, cris_gran)
  return
end

% get the CrIS granule ID from filenames
[~, gstr, ~] = fileparts(cris_gran);
% gran_num = str2double(gstr(38:40));  % UMBC CCAST SDR filenames
  gran_num = str2double(gstr(35:37));  % UW SDR filenames

% get data sizes
[~, nscan] = size(d1.obs_time_tai93);
iFOV = 1 : 9;
iFOR = 1 : 30;
nFOV = length(iFOV);
nFOR = length(iFOR);
nxtr = nFOV * nFOR;
nobs = nFOV * nFOR * nscan;

[nchan_lw,~] = size(d1.wnum_lw);
[nchan_mw,~] = size(d1.wnum_mw);
[nchan_sw,~] = size(d1.wnum_sw);

%-----------------------
% reshape CrIS to CHIRP
%-----------------------

% per-granule values
wnum_lw = d1.wnum_lw;
wnum_mw = d1.wnum_mw;
wnum_sw = d1.wnum_sw;

nedn_lw = d1.nedn_lw;
nedn_mw = d1.nedn_mw;
nedn_sw = d1.nedn_sw;

% reshape radiance to nchan x nobs arrays
rad_lw = reshape(d1.rad_lw, nchan_lw, nobs);
rad_mw = reshape(d1.rad_mw, nchan_mw, nobs);
rad_sw = reshape(d1.rad_sw, nchan_sw, nobs);

% copy time across FOVs and reshape as an nobs vector
obs_time_tai93 = ...
  reshape(ones(nFOV,1)*d1.obs_time_tai93(:)', nobs, 1);

% reshape nFOV x nFOR x nscan arrays to nobs vectors
lat              = reshape(d1.lat,            nobs, 1);
lon              = reshape(d1.lon,            nobs, 1);
view_ang         = reshape(d1.view_ang,       nobs, 1);
sat_zen          = reshape(d1.sat_zen,        nobs, 1);
sat_azi          = reshape(d1.sat_azi,        nobs, 1);
sol_zen          = reshape(d1.sol_zen,        nobs, 1);
sol_azi          = reshape(d1.sol_azi,        nobs, 1);
land_frac        = reshape(d1.land_frac,      nobs, 1);
surf_alt         = reshape(d1.surf_alt,       nobs, 1);
surf_alt_sdev    = reshape(d1.surf_alt_sdev,  nobs, 1);
instrument_state = reshape(d1.instrument_state, nobs, 1);
rad_lw_qc        = reshape(d1.rad_lw_qc,      nobs, 1);
rad_mw_qc        = reshape(d1.rad_mw_qc,      nobs, 1);
rad_sw_qc        = reshape(d1.rad_sw_qc,      nobs, 1);

% reshape nscan arrays to nobs (copy values across scans)
subsat_lat     = reshape(repmat(d1.subsat_lat',    nxtr, 1), nobs, 1);
subsat_lon     = reshape(repmat(d1.subsat_lon',    nxtr, 1), nobs, 1);
scan_mid_time  = reshape(repmat(d1.scan_mid_time', nxtr, 1), nobs, 1);
sat_alt        = reshape(repmat(d1.sat_alt',       nxtr, 1), nobs, 1);
sun_glint_lat  = reshape(repmat(d1.sun_glint_lat', nxtr, 1), nobs, 1);
sun_glint_lon  = reshape(repmat(d1.sun_glint_lon', nxtr, 1), nobs, 1);
asc_flag       = reshape(repmat(d1.asc_flag',      nxtr, 1), nobs, 1);

% clear d1

% TEST
% extend asc from nscan to nFOV x nFOR x nscan
% atmp = d1.sat_alt(:);
% sat_alt2 = reshape(ones(nFOV*nFOR,1)*atmp', nobs, 1);
% isequal(sat_alt, sat_alt2)

% add a FOV index
fov_ind = reshape(iFOV' * ones(1,nFOR*nscan), nobs, 1);

% add a FOR index
ftmp = reshape(iFOR' * ones(1,nscan), nFOR, nscan);
for_ind = reshape(ones(nFOV,1)*ftmp(:)', nobs, 1);

% add a scan index
scan_ind = reshape(ones(nFOV*nFOR,1) * (1:nscan), nobs, 1);

% build the output filename
run_time = now;
obs_time = airs2dnum(obs_time_tai93(1));
chirp_name = nasa_fname(gran_num, obs_time, run_time, prod_name);

% print a status message
dstr = datestr(airs2dnum(obs_time_tai93(1)));
sfmt = '%s: processing granule %03d, %s\n';
fprintf(1, sfmt, fstr, gran_num, dstr);

%-----------------------------
% CrIS to CHIRP interpolation
%-----------------------------
% trim the LW user grid
[~, user_lw] = inst_params('LW', wlaser, opt2);
rad_lw = double(rad_lw);
if hapod, rad_lw = hamm_app(rad_lw); end
ix_lw = find(user_lw.v1 <= wnum_lw & wnum_lw <= user_lw.v2);
vtmp_lw = wnum_lw(ix_lw);
rtmp_lw = rad_lw(ix_lw, :); 
clear rad_lw

% interpolate and trim the MW user grid
[~, user_mw] = inst_params('MW', wlaser, opt2);
[rtmp_mw, vtmp_mw] = finterp(rad_mw, wnum_mw, user_mw.dv);
rtmp_mw = double(real(rtmp_mw));
if hapod, rtmp_mw = hamm_app(rtmp_mw); end
ix_mw = find(user_mw.v1 <= vtmp_mw & vtmp_mw <= user_mw.v2);
vtmp_mw = vtmp_mw(ix_mw);
rtmp_mw = rtmp_mw(ix_mw, :); 
clear rad_mw

% interpolate and trim the SW user grid
[~, user_sw] = inst_params('SW', wlaser, opt2);
[rtmp_sw, vtmp_sw] = finterp(rad_sw, wnum_sw, user_sw.dv);
rtmp_sw = double(real(rtmp_sw));
if hapod, rtmp_sw = hamm_app(rtmp_sw); end
ix_sw = find(user_sw.v1 <= vtmp_sw & vtmp_sw <= user_sw.v2);
vtmp_sw = vtmp_sw(ix_sw);
rtmp_sw = rtmp_sw(ix_sw, :); 
clear rad_sw

% concatenate the bands
rad = [rtmp_lw; rtmp_mw; rtmp_sw];
wnum = [vtmp_lw; vtmp_mw; vtmp_sw];
clear rtmp_lw rtmp_mw rtmp_sw

%--------------------
% CrIS to CHIRP NEdN
%--------------------

% interpolate to the CHIRP grid
[ntmp_mw, ~] = finterp(nedn_mw, wnum_mw, user_mw.dv);
[ntmp_sw, ~] = finterp(nedn_sw, wnum_sw, user_sw.dv);
ntmp_lw = real(nedn_lw(ix_lw, :));
ntmp_mw = real(ntmp_mw(ix_mw, :));
ntmp_sw = real(ntmp_sw(ix_sw, :));

% j = 5;
% plot(wnum_mw, nedn_mw(:,j), vtmp_mw, ntmp_mw(:,j))
% legend('original', 'interpolated')
% grid on; zoom on

% incude scale factors
ntmp_lw = ntmp_lw * nedn_lw_sf;
ntmp_mw = ntmp_mw * nedn_mw_sf;
ntmp_sw = ntmp_sw * nedn_sw_sf;

% combine the bands
nedn = [ntmp_lw; ntmp_mw; ntmp_sw];

% semilogy(wnum, nedn);
% axis([600, 2600, 0, 1])
% grid on; zoom on

%------------------
% CrIS to CHIRP QC
%------------------

% combine band QC
rad_qc = max(rad_lw_qc, max(rad_lw_qc, rad_lw_qc));

% true if geo, radiance, and instrument_state are all OK
% iOK = -90 <= lat & lat <= 90 & -180 <= lon & lon <= 180 ...
%       & cAND(-1 < rad_airs & rad_airs < 250)' & instrument_state == 0;

% translate iOK to NASA-style flags, 0=OK, 1=warn, 2=bad
% rad_qc = ~iOK * 2;

%----------------------------
% save translation as netCDF
%----------------------------

nc_init = 'chirp_master.nc';
nc_data = fullfile(chirp_dir, chirp_name);
copyfile(nc_init, nc_data);

ncwrite(nc_data, 'rad', single(rad));
ncwrite(nc_data, 'rad_qc', uint8(rad_qc));
% ncwrite(nc_data, 'syn_qc', uint8(syn_qc));
% ncwrite(nc_data, 'synfrac', single(synfrac));
ncwrite(nc_data, 'nedn', single(nedn));
ncwrite(nc_data, 'wnum', wnum);

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

% renamings from CrIS to CHIRP indices
ncwrite(nc_data, 'fov', uint8(fov_ind));
ncwrite(nc_data, 'xtrack', uint8(for_ind));
ncwrite(nc_data, 'atrack', uint8(scan_ind));

% the following aren't defined for CrIS-parent
% ncwrite(nc_data, 'airs_atrack', uint8(atrack_ind));
% ncwrite(nc_data, 'airs_xtrack', uint8(xtrack_ind));

% quick sanity checks
% wnum2 = ncread(nc_data, 'wnum');
% rad2 = ncread(nc_data, 'rad');

% isequal(wnum, wnum2)
% isequal(rad, single(rad2))

