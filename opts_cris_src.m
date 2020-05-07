%
% NAME
%   opts_cris_src - set cris2chirp options and loop on days
%
% SYNOPSIS
%   opts_cris_src(year, dlist)
%
% INPUTS
%   year   - integer year
%   dlist  - integer vector of days-of-the-year
%
% DISCUSSION
%   This is where run parameters and paths should be set.
%   Assumes data is organized as home/yyyy/doy/granules.
%
% AUTHOR
%  H. Motteler, 12 Dec 2019
%

function opts_cris_src(year, dlist)

% test params
% year = 2019;
% dlist = 61 : 63;

% set up source paths
addpath /home/motteler/cris/ccast/source
addpath /home/motteler/cris/ccast/motmsc/time
addpath /home/motteler/shome/airs_decon/source

% CrIS and CHIRP local data homes
% ahome = '/asl/cris/ccast/sdr45_j01_HR';
ahome = '/home/motteler/shome/daac_test/SNPPCrISL1B.2';  % CrIS source home
chome = '/asl/hpcnfs1/chirp/cris_npp_src';               % CHIRP output home

% CrIS and CHIRP annual data (home/yyyy)
ayear = fullfile(ahome, sprintf('%d', year));
cyear = fullfile(chome, sprintf('%d', year));

% run-specific CHIRP product attributes
prod_attr = init_prod_attr;
prod_attr.product_name_project    = 'SNDR';
prod_attr.product_name_platform   = 'SS1330';
prod_attr.product_name_instr      = 'CHIRP';
prod_attr.product_name_duration   = 'm06';
prod_attr.product_name_type_id    = 'L1_SN';
prod_attr.product_name_variant    = 'std';
prod_attr.product_name_version    = 'v01_07';
prod_attr.product_name_producer   = 'U';
prod_attr.product_name_extension  = 'nc';

% cris2chirp options
proc_opts = struct;
proc_opts.verbose = 1;   % 0=quiet, 1=talky, 2=plots

% this function name
fstr = mfilename;  

% loop on days of the year
for di = dlist

  % add day-of-year to paths
  doy = sprintf('%03d', di);
  fprintf(1, '%s: processing %d doy %s\n', fstr, year, doy)
  apath = fullfile(ayear, doy);
  cpath = fullfile(cyear, doy);

  % check that the source path exists
  if exist(apath) ~= 7
    fprintf(1, '%s: bad source path %s\n', fstr, apath)
    continue
  end

  % create the output path, if needed
  if exist(cpath) ~= 7, mkdir(cpath), end

  % loop on CrIS granules
  flist = dir(fullfile(apath, 'SNDR*CRIS*.nc'));
  for fi = 1 : length(flist)
    agran = fullfile(apath, flist(fi).name);
    cris2chirp(agran, cpath, prod_attr, proc_opts);
  end % loop on granules
end % loop on days

