%
% NAME
%   opts_cris_src - cris2chirp options and loop on days
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
chome = '/asl/hpcnfs1/chirp/cris_npp';                   % CHIRP output home

% CrIS and CHIRP annual data (home/yyyy)
ayear = fullfile(ahome, sprintf('%d', year));
cyear = fullfile(chome, sprintf('%d', year));

% CHIRP product attributes
prod_name = struct;
prod_name.project   = 'SNDR';
prod_name.platform  = 'SNPP';
prod_name.instr     = 'CHIRP';
prod_name.duration  = 'm06';
prod_name.type_id   = 'L1C';
prod_name.variant   = 'std';
prod_name.version   = 'v01d';
prod_name.producer  = 'U';
prod_name.extension = 'nc';

% cris2chirp options
proc_opts = struct;
proc_opts.verbose = 0;   % 0 = quiet, 1 = talky, 2 = plots

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
    cris2chirp(agran, cpath, prod_name, proc_opts);
  end % loop on granules
end % loop on days

