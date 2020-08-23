%
% NAME
%   airs2chirp - translate AIRS to CHIRP granules
%
% SYNOPSIS
%   airs2chirp(airs_gran, chirp_dir, proc_opts, prod_attr)
%
% INPUTS
%   airs_gran  - AIRS input granule file
%   chirp_dir  - CHIRP output granule dir
%   proc_opts  - processing options
%   prod_attr  - product attributes
%
% DISCUSSION
%   This function takes AIRS to CHIRP granules, and adds a lot of
%   CHIRP-specific support info.  The actual radiance translation is
%   done by the function airs2cris, from the airs_decon repo.
%
% AUTHOR
%  H. Motteler, 8 July 2019
%

function airs2chirp(airs_gran, chirp_dir, proc_opts, prod_attr)

%--------------------------
% setup and default options
%---------------------------

% default parameters
verbose = 0;                  % 0=quiet, 1=talky, 2=plots
hapod = 1;                    % apply Hamming apodization
scorr = 1;                    % do a statistical correction
bcorr = 1;                    % do a bias correction
cfile = 'corr_midres.mat';    % statistical correction weights
sfile = 'airs_demo_srf.hdf';  % AIRS SRF tabulation file
bfile = 'airs_bias_v01a.mat'; % AIRS bias file
tchunk = 400;                 % translation chunk size
synlim = 0.15;                % syn channel warn threshold
nc_init = 'chirp_1330.nc';    % initial empty netcdf file

% option to override defaults 
if nargin == 4
  if isfield(proc_opts, 'verbose'), verbose = proc_opts.verbose; end
  if isfield(proc_opts, 'hapod'),   hapod   = proc_opts.hapod; end
  if isfield(proc_opts, 'scorr'),   scorr   = proc_opts.scorr; end
  if isfield(proc_opts, 'bcorr'),   bcorr   = proc_opts.bcorr; end
  if isfield(proc_opts, 'cfile'),   cfile   = proc_opts.cfile; end
  if isfield(proc_opts, 'sfile'),   sfile   = proc_opts.sfile; end
  if isfield(proc_opts, 'bfile'),   bfile   = proc_opts.bfile; end
  if isfield(proc_opts, 'tchunk'),  tchunk  = proc_opts.tchunk; end
  if isfield(proc_opts, 'synlim'),  synlim  = proc_opts.synlim; end
  if isfield(proc_opts, 'nc_init'), nc_init = proc_opts.nc_init; end
end

% fixed CHIRP parameters
user_res = 'midres';      % translation user resolution
nchan_chirp = 1679;       % should match the chirp cdl spec
d1 = load('chirp_wnum');  % frequency grid from cris2chirp
wnum_chirp = d1.wnum;

% options for airs2cris
opt2 = struct;
opt2.hapod = hapod;
opt2.scorr = scorr;
opt2.cfile = cfile;
opt2.user_res = user_res;

% fixed AIRS parameters
nchan_airs = 2645;  % L1c channels
nobs = 90 * 135;    % xtrack x atrack obs
L1c_err = 999;      % L1c error flag

% this function name
fstr = mfilename;  

% optional parameter summary
if verbose
  fprintf(1, '%s: hapod=%d scorr=%d tchunk=%d synlim=%g\n', ...
             fstr, hapod, scorr, tchunk, synlim);
  fprintf(1, '%s: cfile=%s\n', fstr, cfile);
  fprintf(1, '%s: sfile=%s\n', fstr, sfile);
  fprintf(1, '%s: nc_init=%s\n', fstr, nc_init);
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
  [d1, airs_attr] = read_airs_h4(airs_gran);
catch
  fprintf(1, '%s: could not read %s\n', fstr, airs_gran)
  return
end

% get the granule number from airs attributes
gran_num = double(airs_attr.granule_number);

%----------------------------------
% reshape and rename the AIRS data
%----------------------------------

% per-granule values
freq_airs  = d1.nominal_freq;
nsynth_airs = double(d1.L1cNumSynth);

% nchan x xtrack x atrack to nchan x nobs
rad_airs   = reshape(d1.radiances, [nchan_airs, nobs]);
nedn_airs  = reshape(d1.NeN,       [nchan_airs, nobs]);

% xtrack x atrack to nobs
obs_time_tai93   = reshape(d1.Time,      nobs, 1);
obs_time_utc     = tai93_to_tuple(obs_time_tai93);
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
sat_alt        = reshape(repmat(d1.satheight', 90, 1), nobs, 1) * 1000;
sun_glint_lat  = reshape(repmat(d1.glintlat',  90, 1), nobs, 1);
sun_glint_lon  = reshape(repmat(d1.glintlon',  90, 1), nobs, 1);
asc_flag       = reshape(repmat(d1.scan_node_type', 90, 1), nobs, 1);

% basic AIRS atrack and xtrack indices
airs_atrack = reshape(repmat(1:135, 90, 1), nobs, 1);
airs_xtrack = reshape(repmat((1:90)', 1, 135), nobs, 1);

% CrIS-style 3 x 3 tiling (from Evan Manning)
atrack = floor((airs_atrack - 1) / 3) + 1;
xtrack = floor((airs_xtrack - 1) / 3) + 1;
fov = mod(airs_xtrack-1, 3) + 3 * mod(airs_atrack-1, 3) + 1;

% generate an obs_id for AIRS 
obs_id = airs_obs_id(obs_time_utc, airs_atrack, airs_xtrack);

% call airs_fov_gen for FOV polygons and sat range
[lat_bnds, lon_bnds, sat_range] = ...
  airs_fov_gen(d1.sat_lat, d1.sat_lon, ...
               d1.Latitude, d1.Longitude, ...
               d1.satheight * 1e3, ...
               d1.scanang, d1.satazi, 1.1);

% reshape airs_fov_gen outputs to chirp spec
lat_bnds = reshape(lat_bnds, 8, nobs);
lon_bnds = reshape(lat_bnds, 8, nobs);
sat_range =  reshape(sat_range, nobs, 1);

% set global attributes
obs_time = airs2dnum(obs_time_tai93(1));
prod_attr = copy_airs_attr(airs_attr, prod_attr);
prod_attr = airs_src_attr(gran_num, obs_time, airs_gran, prod_attr);
prod_attr = airs_geo_attr(d1, prod_attr);

% build the output filename
chirp_name = nasa_fname(prod_attr);

% print a status message
dstr = datestr(airs2dnum(obs_time_tai93(1)));
sfmt = '%s: processing granule %03d, %s\n';
fprintf(1, sfmt, fstr, gran_num, dstr);

clear d1

%--------------------------
% AIRS to CrIS translation
%--------------------------

% initialize output
rad_chirp = nan(nchan_chirp, nobs);

% loop on chunks
for j = 1 : tchunk : nobs
  
  % indices for current chunk
  cix = j : min(j+tchunk-1, nobs);

  % call airs2cris on the chunk
  [rtmp, freq_cris] = airs2cris(rad_airs(:, cix), freq_airs, sfile, opt2);

  % eix embeds the cris translation in the chirp output grid
  if j == 1
    eix = interp1(wnum_chirp, 1:nchan_chirp, freq_cris, 'nearest');
    nchan_cris = length(freq_cris);
    % temporary sanity check
    [i2, j2] = seq_match(wnum_chirp, freq_cris);
    if ~isequal(eix, i2) || ~isequal((1:length(freq_cris))', j2)
      error('unexpected channel list length difference')
    end
  end

  % save the current chunk
  rad_chirp(eix, cix) = rtmp;

end

% option to do the bias correction
if bcorr
  db = load(bfile);
  rad_chirp = bias_correct(wnum_chirp, rad_chirp, db.bias);
end

%-------------------
% AIRS to CrIS NEdN
%-------------------

nedn_cris = ...
  nedn_est(nedn_airs, freq_airs, sfile, opt2);

% check cris sizes before embedding
if length(nedn_cris) ~= length(freq_cris)
  error('length(nedn_cris) != length(freq_cris)')
end

% embed nedn_cris in nedn_chirp
nedn_chirp = nan(nchan_chirp, 1);
nedn_chirp(eix, 1) = nedn_cris;

% copy across 9 columns to match CrIS-parent CDL spec
nedn_chirp = nedn_chirp * ones(1, 9);

%-----------------
% AIRS-to-CrIS QC
%-----------------

% we create two QC fields, rad_qc, an nobs-vector with one flag
% value per obs, and syn_qc, an nchan-vector with one flag value per
% channel.  For both, 0 = OK, 1 = warn, and 2 = bad.  But rad_qc is
% always 0 or 2 (because AIRS L1c doesn't have a "warn" flag) while
% synth_qc is 0 or 1.

% A linearized version of the AIRS to CrIS transform is used for
% translation QC.  It is simply the translation of the identity
% matrix.

opt3 = opt2;     % use options as set above
opt3.scorr = 0;  % turn off statistical correction
[Tac, freq_cris] = airs2cris(eye(nchan_airs), freq_airs, sfile, opt3);
Tac = real(Tac);

% find the synthetic fraction for each airs-to-cris channel.
% take the abs because this can have small negative excursions
% and our concern is the magnitude of the effect, not the sign.
nsynth_cris = Tac * nsynth_airs;
synfrac = nsynth_cris / max(nsynth_cris);
synfrac = abs(synfrac);
synfrac(synfrac > 1) = 1;

% sOK is true if the synthetic fraction is within acceptable limits
sOK = synfrac < synlim;

% translate sOK to NASA-style 3-value flags, 0=OK, 1=warn, 2=bad
syn_qc = ~sOK;

% embed syn_qc in the chirp chan_qc
chan_qc = ones(nchan_chirp, 1) * 2;  % initially all are missing
chan_qc(eix) = syn_qc;  % valid channels are flagged with syn_qc

% embed synfrac in synfrac_chirp
synfrac_chirp = nan(nchan_chirp, 1);
synfrac_chirp(eix) = synfrac;

if verbose
  fprintf(1, '%s: %d / %d synthetic channels\n', ...
          fstr, sum(syn_qc), nchan_cris);
end
if verbose == 2;
  plot_syn(freq_airs, nsynth_airs, freq_cris, synfrac)
end

% true if geo, radiance, and instrument_state are all OK
iOK = -90 <= lat & lat <= 90 & -180 <= lon & lon <= 180 ...
      & cAND(-1 < rad_airs & rad_airs < 250)' & instrument_state == 0;

% translate iOK to NASA-style flags, 0=OK, 1=warn, 2=bad.  
% Note rad_qc set this way does not give a "warn"; just OK or bad.
rad_qc = ~iOK * 2;

% QC summary checks
radOK = sum(rad_qc == 0);
if radOK == 0
  fprintf(1, '%s: no valid obs, skipping this granule...\n', fstr)
  return
elseif radOK < nobs
  fprintf(1, '%s: %d / %d valid obs\n', fstr, radOK, nobs)
end

chanBAD = sum(chan_qc == 2);
if chanBAD == nchan_chirp
  fprintf(1, '%s: no valid channels, skipping this granule...\n', fstr)
  return
end

%----------------------------
% save translation as netCDF
%----------------------------

nc_data = fullfile(chirp_dir, chirp_name);
copyfile(nc_init, nc_data);

h5write(nc_data, '/rad', single(rad_chirp));
h5write(nc_data, '/rad_qc', int8(rad_qc));
h5write(nc_data, '/chan_qc', int8(chan_qc));
h5write(nc_data, '/synth_frac', single(synfrac_chirp));
h5write(nc_data, '/nedn', single(nedn_chirp));
h5write(nc_data, '/wnum', wnum_chirp);

h5write(nc_data, '/obs_time_tai93', obs_time_tai93);
h5write(nc_data, '/obs_time_utc', obs_time_utc);
h5write(nc_data, '/obs_id', obs_id);

h5write(nc_data, '/lat', single(lat));
h5write(nc_data, '/lon', single(lon));
h5write(nc_data, '/view_ang', view_ang);
h5write(nc_data, '/sat_zen', sat_zen);
h5write(nc_data, '/sat_azi', sat_azi);
h5write(nc_data, '/sol_zen', sol_zen);
h5write(nc_data, '/sol_azi', sol_azi);
h5write(nc_data, '/land_frac', land_frac);
h5write(nc_data, '/surf_alt', surf_alt);
h5write(nc_data, '/surf_alt_sdev', surf_alt_sdev);

h5write(nc_data, '/subsat_lat', single(subsat_lat));
h5write(nc_data, '/subsat_lon', single(subsat_lon));
h5write(nc_data, '/scan_mid_time', scan_mid_time);
h5write(nc_data, '/sat_alt', sat_alt);
h5write(nc_data, '/sun_glint_lat', sun_glint_lat);
h5write(nc_data, '/sun_glint_lon', sun_glint_lon);
h5write(nc_data, '/asc_flag', uint8(asc_flag));

h5write(nc_data, '/airs_atrack', uint8(airs_atrack));
h5write(nc_data, '/airs_xtrack', uint8(airs_xtrack));
h5write(nc_data, '/atrack', uint8(atrack));
h5write(nc_data, '/xtrack', uint8(xtrack));
h5write(nc_data, '/fov_num', uint8(fov));

h5write(nc_data, '/lat_bnds', lat_bnds);
h5write(nc_data, '/lon_bnds', lon_bnds);
h5write(nc_data, '/sat_range', sat_range);

% write the global attributes
write_prod_attr(nc_data, prod_attr);

end

% plot AIRS and CrIS synthetic values
function plot_syn(freq_airs, nsynth_airs, freq_cris, synfrac)

figure(1)
y1 = nsynth_airs / max(nsynth_airs);
subplot(2,1,1)
plot(freq_airs, y1, '+') 
axis([600, 2600,-0.1, 1.1])
title('nsynth\_airs')
ylabel('synthetic fraction')
grid on; zoom on
 
subplot(2,1,2)
plot(freq_cris, synfrac, '+')
axis([600, 2600,-0.1, 1.1])
title('nsynth\_airs CrIS Translation')
xlabel('wavenumber (cm-1)')
ylabel('synthetic fraction')
grid on; zoom on
input('<return> to continue > ', 's');

end

