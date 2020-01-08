%
% NAME
%   airs_loop - run airs2chirp on a list of days
%
% SYNOPSIS
%   airs_loop(year, dlist)
%
% INPUTS
%   year   - year, as an integer
%   dlist  - list of days-of-the-year
%
% DISCUSSION
%   this is where run parameters and paths should be set
%   assumes data is organized as home/yyyy/doy/granules
%
% AUTHOR
%  H. Motteler, 12 Dec 2019
%

function airs_loop(year, dlist)

% test params
% year = 2019;
% dlist = 61 : 63;

% set up source paths
addpath /home/motteler/cris/ccast/source
addpath /home/motteler/shome/airs_decon/source
addpath /home/motteler/cris/ccast/motmsc/time

% AIRS and CHIRP local homes
ahome = '/asl/xfs3/airs/L1C';  % AIRS source home
chome = '/asl/hpcnfs1/chirp/airs_L1c';  % CHIRP output home

% AIRS and CHIRP annual data (home/yyyy)
ayear = fullfile(ahome, sprintf('%d', year));
cyear = fullfile(chome, sprintf('%d', year));

% airs2chirp options
opt1 = struct;
opt1.sdr_src = 'AIRS-L1C';  % sounder source intrument
opt1.vtag = '01a';          % translation version for output files
opt1.verbose = 0;           % 0 = quiet, 1 = talky, 2 = plots
opt1.tchunk = 400;

fstr = mfilename;  % this function name

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
    airs2chirp(agran, cpath, opt1);
  end % loop on granules
end % loop on days

