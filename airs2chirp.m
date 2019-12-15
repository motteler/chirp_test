%
% NAME
%   airs2chirp - translate an AIRS granule to CHIRP
%
% SYNOPSIS
%   airs2chirp(agran, cdir, opt1)
%
% INPUTS
%   agran - AIRS input granule file
%   cdir  - CHIRP output granule dir
%   opt1  - processing options
%
% AUTHOR
%  H. Motteler, 8 July 2019
%
% NOTES
%   need to check that cdir exists 
%

function airs2chirp(agran, cdir, opt1)

verbose = 0;

% test values
% addpath /home/motteler/cris/ccast/source
% addpath /home/motteler/shome/airs_decon/source
% addpath /home/motteler/cris/ccast/motmsc/time
% s1 = '/asl/data/airs/L1C/2019/120';
% s2 = 'AIRS.2019.04.30.036.L1C.AIRS_Rad.v6.1.2.0.G19120112646.hdf';
% s1 = '/asl/data/airs/L1C/2017/183';
% s2 = 'AIRS.2017.07.02.047.L1C.AIRS_Rad.v6.1.2.0.G17183112059.hdf';
% agran = fullfile(s1, s2);

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
tchunk = 400;                    % translation chunk size

nchan = 2645;     % L1c channels
nobs = 90 * 135;  % xtrack x atrack obs
L1c_err = 999;    % L1c error flag

fstr = mfilename;  % this function name

%---------------------
% read the AIRS data
%---------------------
try
  d1 = read_airs_h4(agran);
catch
  fprintf(1, '%s: could not read %s\n', fstr, agran)
  return
end

% get the AIRS granule ID
[~, gstr, ~] = fileparts(agran);
gran_id = str2double(gstr(17:19));

%----------------------------------
% reshape and rename the AIRS data
%----------------------------------
% nchan x xtrack x atrack to nchan x nobs
rad_airs   = reshape(d1.radiances, [nchan, nobs]);
nedn_airs  = reshape(d1.NeN,       [nchan, nobs]);

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

% add nobs atrack and xtrack indices
atrack_ind = reshape(repmat(1:135, 90, 1), nobs, 1);
xtrack_ind = reshape(repmat((1:90)', 1, 135), nobs, 1);

% AIRS per-granule values
freq_airs  = d1.nominal_freq;
nsynth_airs = double(d1.L1cNumSynth);

% whos rad_airs nedn_airs
% whos obs_time_tai93 lat lon view_ang sat_zen sat_azi ...
%   sol_zen sol_azi land_frac surf_alt surf_alt_sdev instrument_state
% whos subsat_lat subsat_lon scan_mid_time sat_alt ...
%   sun_glint_lat sun_glint_lon asc_flag xtrack_ind atrack_ind ...
%   freq_airs nsynth_airs

% clear d1

% build the output filename
% set sounder source and code version here, for now
  sdr_src = 'AIRS-L1C';   % SDR sounder source
% sdr_src = 'CRIS-NPP';
% sdr_src = 'CRIS-J01';
vtag = '01a';            % translation version
dvec = datevec(airs2dnum(obs_time_tai93(1)));
dvec(6) = round(dvec(6) * 10);
cfmt = 'CHIRP_%s_d%04d%02d%02d_t%02d%02d%03d_g%03d_v%s.nc';
chirp_name = sprintf(cfmt, sdr_src, dvec, gran_id, vtag);

% print a status message
sfmt = '%s: processing d%04d%02d%02d_t%02d%02d%03d_g%03d\n';
fprintf(1, sfmt, fstr, dvec, gran_id);

%------------------------
% linearized translation
%------------------------

% A linearized version of the AIRS to CrIS transform is used for
% translation QC and NEdN estimates.  It is simply the translation
% of the identity matrix.

opt2 = opt1;     % use options as set above
opt2.scorr = 0;  % turn off statistical correction
[Tac, freq_cris] = airs2cris(eye(nchan), freq_airs, sfile, opt2);
Tac = real(Tac);

%-----------------
% AIRS-to-CrIS QC
%-----------------

% we create two QC fields, rad_qc, an nobs-vector with one flag
% value per obs, and syn_qc, an nchan-vector with one flag value per
% channel.  For both, 0 = OK, 1 = warn, and 2 = bad.  But note that
% rad_qc will always be 0 or 2, while synth_qc will always be 0 or
% 1.

nsynth_cris = Tac * nsynth_airs;
synfrac = nsynth_cris / max(nsynth_cris);

% true if the synthetic fraction is within acceptable limits
sOK = synfrac < 0.15;  % for now, us a nominal or test value

% translate sOK to NASA-style 3-value flags, 0=OK, 1=warn, 2=bad
syn_qc = ~sOK;

fprintf(1, '%s: flagging %d out of %d synthetic channels\n', ...
        fstr, sum(syn_qc), nchan);

if verbose
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
end % if verbose

% true if geo, radiance, and instrument_state are all OK
iOK = -90 <= lat & lat <= 90 & -180 <= lon & lon <= 180 ...
      & cAND(-1 < rad_airs & rad_airs < 250)' & instrument_state == 0;

% translate iOK to NASA-style flags, 0=OK, 1=warn, 2=bad
rad_qc = ~iOK * 2;

%-------------------
% AIRS to CrIS NEdN
%-------------------

nedn_tran = ...
  nedn_chirp(nedn_airs, freq_airs, nsynth_airs, Tac, sfile, opt1);

%--------------------------
% AIRS to CrIS translation
%--------------------------

% loop on chunks
for j = 1 : tchunk : nobs
  
  % indices for current chunk
  ix = j : min(j+tchunk-1, nobs);

  % call airs2cris on the chunk
  [rtmp, freq_cris] = airs2cris(rad_airs(:, ix), freq_airs, sfile, opt1);

  % initialize output after first obs
  if j == 1
    [m, ~] = size(rtmp);
    crad = zeros(m, nobs);
  end

  % save the current chunk
  crad(:, ix) = rtmp;

% fprintf(1, '.');
end
% fprintf(1, '\n');

%----------------------------
% save translation as netCDF
%----------------------------

nc_init = 'chirp_init.nc';
nc_data = fullfile(cdir, chirp_name);
copyfile(nc_init, nc_data);

ncwrite(nc_data, 'rad', single(crad));
ncwrite(nc_data, 'rad_qc', uint8(rad_qc));
ncwrite(nc_data, 'syn_qc', uint8(syn_qc));
ncwrite(nc_data, 'synfrac', single(synfrac));
ncwrite(nc_data, 'nedn', single(nedn_tran));
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

ncwrite(nc_data, 'atrack_ind', uint8(atrack_ind));
ncwrite(nc_data, 'xtrack_ind', uint8(xtrack_ind));

% return

% quick sanity checks
% wnum2 = ncread(nc_data, 'wnum');
% rad2 = ncread(nc_data, 'rad');

% isequal(freq_cris, wnum2)
% isequal(single(crad), rad2)

