%
% NAME
%   airs2chirp - translate AIRS to CHIRP granules
%
% SYNOPSIS
%   airs2chirp(airs_gran, chirp_dir, prod_name, proc_opts)
%
% INPUTS
%   airs_gran  - AIRS input granule file
%   chirp_dir  - CHIRP output granule dir
%   prod_name  - product attributes
%   proc_opts  - processing options
%
% proc_opts are mainly for testing; the default values should be
% used for production.
%
% AUTHOR
%  H. Motteler, 8 July 2019
%

function airs2chirp(airs_gran, chirp_dir, prod_name, proc_opts)

%--------------------------
% setup and default options
%---------------------------

% general options
verbose = 0;  % 0 = quiet, 1 = talky, 2 = plots

% translation options
hapod = 1;                  % apply Hamming apodization
scorr = 1;                  % do a statistical correction
user_res = 'midres';        % translation user resolution
cfile = 'corr_midres.mat';  % statistical correction weights
tchunk = 400;               % translation chunk size

% AIRS SRF tabulation file
sfile = './airs_demo_srf.hdf';

% option to override defaults 
if nargin == 4
  if isfield(proc_opts, 'verbose'),  verbose  = proc_opts.verbose; end
  if isfield(proc_opts, 'hapod'),    hapod    = proc_opts.hapod; end
  if isfield(proc_opts, 'scorr'),    scorr    = proc_opts.scorr; end
  if isfield(proc_opts, 'user_res'), user_res = proc_opts.user_res; end
  if isfield(proc_opts, 'cfile'),    cfile    = proc_opts.cfile; end
  if isfield(proc_opts, 'tchunk'),   tchunk   = proc_opts.tchunk; end
  if isfield(proc_opts, 'sfile'),    sfile    = proc_opts.sfile; end
end

% options for airs2cris.m
opt2 = struct;
opt2.hapod = hapod;
opt2.scorr = scorr;
opt2.user_res = user_res;
opt2.cfile = cfile;

% AIRS parameters
nchan = 2645;     % L1c channels
nobs = 90 * 135;  % xtrack x atrack obs
L1c_err = 999;    % L1c error flag

% this function name
fstr = mfilename;  

% optional parameter summary
if verbose
  fprintf(1, '------------------------------------------------\n')
  fprintf(1, '%s: hapod=%d scorr=%d user_res=%s\n', fstr, hapod, scorr, user_res);
  fprintf(1, '%s: cfile=%s tchunk=%d sfile=%s\n', fstr, cfile, tchunk, sfile);
end

% check source file 
if exist(airs_gran) ~= 2
  fprintf(1, '%s: missing source file %s\n', fstr, airs_gran)
  return
end

% check output directory
if exist(chirp_dir) ~= 7, 
  fprintf(1, '%s: bad output path %s\n', fstr, chirp_dir)
  return
end

%---------------------
% read the AIRS data
%---------------------
try
  d1 = read_airs_h4(airs_gran);
catch
  fprintf(1, '%s: could not read %s\n', fstr, airs_gran)
  return
end

% get the AIRS granule ID
[~, gstr, ~] = fileparts(airs_gran);
gran_num = str2double(gstr(17:19));

%----------------------------------
% reshape and rename the AIRS data
%----------------------------------

% per-granule values
freq_airs  = d1.nominal_freq;
nsynth_airs = double(d1.L1cNumSynth);

% nchan x xtrack x atrack to nchan x nobs
rad_airs   = reshape(d1.radiances, [nchan, nobs]);
nedn_airs  = reshape(d1.NeN,       [nchan, nobs]);

% xtrack x atrack to nobs
obs_time_tai93   = reshape(d1.Time,      nobs, 1);
lat              = reshape(d1.Latitude,  nobs, 1);
lon              = reshape(d1.Longitude, nobs, 1);
view_ang         = abs(reshape(d1.scanang,   nobs, 1));
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

clear d1

% basic AIRS atrack and xtrack indices
airs_atrack = reshape(repmat(1:135, 90, 1), nobs, 1);
airs_xtrack = reshape(repmat((1:90)', 1, 135), nobs, 1);

% CrIS-style 3 x 3 tiling (from Evan Manning)
atrack = floor((airs_atrack - 1) / 3) + 1;
xtrack = floor((airs_xtrack - 1) / 3) + 1;
fov = mod(airs_xtrack-1, 3) + 3 * mod(airs_atrack-1, 3) + 1;

% whos rad_airs nedn_airs
% whos obs_time_tai93 lat lon view_ang sat_zen sat_azi ...
%   sol_zen sol_azi land_frac surf_alt surf_alt_sdev instrument_state
% whos subsat_lat subsat_lon scan_mid_time sat_alt ...
%   sun_glint_lat sun_glint_lon asc_flag airs_xtrack airs_atrack ...
%   freq_airs nsynth_airs

% build the output filename
run_time = now;
obs_time = airs2dnum(obs_time_tai93(1));
chirp_name = nasa_fname(gran_num, obs_time, run_time, prod_name);

% print a status message
dstr = datestr(airs2dnum(obs_time_tai93(1)));
sfmt = '%s: processing granule %03d, %s\n';
fprintf(1, sfmt, fstr, gran_num, dstr);

%--------------------------
% AIRS to CrIS translation
%--------------------------

% loop on chunks
for j = 1 : tchunk : nobs
  
  % indices for current chunk
  ix = j : min(j+tchunk-1, nobs);

  % call airs2cris on the chunk
  [rtmp, freq_cris] = airs2cris(rad_airs(:, ix), freq_airs, sfile, opt2);

  % initialize output after first obs
  if j == 1
    [m, ~] = size(rtmp);
    rad_cris = zeros(m, nobs);
  end

  % save the current chunk
  rad_cris(:, ix) = rtmp;

% fprintf(1, '.');
end
% fprintf(1, '\n');

%-------------------
% AIRS to CrIS NEdN
%-------------------

nedn_cris = ...
  nedn_est(nedn_airs, freq_airs, sfile, opt2);

%-----------------
% AIRS-to-CrIS QC
%-----------------

% we create two QC fields, rad_qc, an nobs-vector with one flag
% value per obs, and syn_qc, an nchan-vector with one flag value per
% channel.  For both, 0 = OK, 1 = warn, and 2 = bad.  But note that
% rad_qc will always be 0 or 2, while synth_qc will always be 0 or
% 1.

% A linearized version of the AIRS to CrIS transform is used for
% translation QC.  It is simply the translation of the identity
% matrix.

opt3 = opt2;     % use options as set above
opt3.scorr = 0;  % turn off statistical correction
[Tac, freq_cris] = airs2cris(eye(nchan), freq_airs, sfile, opt3);
Tac = real(Tac);

nsynth_cris = Tac * nsynth_airs;
synfrac = nsynth_cris / max(nsynth_cris);

% true if the synthetic fraction is within acceptable limits
sOK = synfrac < 0.15;  % for now, us a nominal or test value

% translate sOK to NASA-style 3-value flags, 0=OK, 1=warn, 2=bad
syn_qc = ~sOK;

nchan_cris = length(nsynth_cris);

if verbose
  fprintf(1, '%s: %d / %d synthetic channels\n', ...
          fstr, sum(syn_qc), nchan_cris)
end

if verbose == 2;
  % plot AIRS and CrIS synthetic values
  figure(1)
  y1 = nsynth_airs / max(nsynth_airs);
  subplot(2,1,1)
  plot(freq_airs, y1, '+') 
  axis([600, 2600,-0.1, 1.1])
  title('nsynth_airs')
  ylabel('synthetic fraction')
  grid on; zoom on
  
  subplot(2,1,2)
  plot(freq_cris, synfrac, '+')
  axis([600, 2600,-0.1, 1.1])
  title('nsynth_airs CrIS Translation')
  xlabel('wavenumber (cm-1)')
  ylabel('synthetic fraction')
  grid on; zoom on
end

% true if geo, radiance, and instrument_state are all OK
iOK = -90 <= lat & lat <= 90 & -180 <= lon & lon <= 180 ...
      & cAND(-1 < rad_airs & rad_airs < 250)' & instrument_state == 0;

% translate iOK to NASA-style flags, 0=OK, 1=warn, 2=bad
rad_qc = ~iOK * 2;

% QC summary
nOK = sum(rad_qc == 0);
if nOK == 0
  fprintf(1, '%s: no valid AIRS data, skipping this granule...\n', fstr)
  return
elseif nOK < nobs
  fprintf(1, '%s: %d / %d valid AIRS obs\n', fstr, nOK, nobs)
end

%----------------------------
% save translation as netCDF
%----------------------------

nc_init = 'chirp_master.nc';
nc_data = fullfile(chirp_dir, chirp_name);
copyfile(nc_init, nc_data);

ncwrite(nc_data, 'rad', single(rad_cris));
ncwrite(nc_data, 'rad_qc', uint8(rad_qc));
ncwrite(nc_data, 'syn_qc', uint8(syn_qc));
ncwrite(nc_data, 'synfrac', single(synfrac));
ncwrite(nc_data, 'nedn', single(nedn_cris));
ncwrite(nc_data, 'wnum', freq_cris);

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

ncwrite(nc_data, 'airs_atrack', uint8(airs_atrack));
ncwrite(nc_data, 'airs_xtrack', uint8(airs_xtrack));
ncwrite(nc_data, 'atrack', uint8(atrack));
ncwrite(nc_data, 'xtrack', uint8(xtrack));
ncwrite(nc_data, 'fov', uint8(fov));

% return

% quick sanity checks
% wnum2 = ncread(nc_data, 'wnum');
% rad2 = ncread(nc_data, 'rad');

% isequal(freq_cris, wnum2)
% isequal(single(rad_cris), rad2)

