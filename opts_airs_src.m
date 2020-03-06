%
% NAME
%   opts_airs_src - run airs2chirp on a list of days
%
% SYNOPSIS
%   opts_airs_src(year, dlist)
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

function opts_airs_src(year, dlist)

% test params
% year = 2019;
% dlist = 61 : 63;

% set up source paths
addpath /home/motteler/cris/ccast/source
addpath /home/motteler/cris/ccast/motmsc/time
addpath /home/motteler/shome/airs_decon/source

% AIRS and CHIRP local homes
ahome = '/asl/hpcnfs1/airs/L1C';        % AIRS source home
chome = '/asl/hpcnfs1/chirp/airs_L1c';  % CHIRP output home

% AIRS and CHIRP annual data (home/yyyy)
ayear = fullfile(ahome, sprintf('%d', year));
cyear = fullfile(chome, sprintf('%d', year));

% CHIRP product attributes
prod_name = struct;
prod_name.project   = 'SNDR';
prod_name.platform  = 'AIRS';
prod_name.instr     = 'CHIRP';
prod_name.duration  = 'm06';
prod_name.type_id   = 'L1C';
prod_name.variant   = 'std';
prod_name.version   = 'v01c';
prod_name.producer  = 'U';
prod_name.extension = 'nc';

% airs2chirp options
proc_opts = struct;
proc_opts.verbose = 0;   % 0 = quiet, 1 = talky, 2 = plots
proc_opts.tchunk = 400;  % translation chunk size

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

  % loop on AIRS granules
  flist = dir(fullfile(apath, 'AIRS*L1C*.hdf'));
  for fi = 1 : length(flist);
    agran = fullfile(apath, flist(fi).name);
    airs2chirp(agran, cpath, prod_name, proc_opts);
  end % loop on granules
end % loop on days

