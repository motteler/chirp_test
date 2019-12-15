%
% NAME
%   airs_loop - call airs2chirp on AIRS L1C files
%
% SYNOPSIS
%   airs_loop(year, dlist, cdir, opt1)
%
% INPUTS
%   year   - year, as an integer
%   dlist  - list of days-of-the-year
%   cdir   - save file directory
%
% AUTHOR
%  H. Motteler, 12 Dec 2019
%

% function airs_loop(year, dlist, cdir, opt1)

addpath /home/motteler/cris/ccast/source
addpath /home/motteler/shome/airs_decon/source
addpath /home/motteler/cris/ccast/motmsc/time

% test params
year = 2018;
  dlist = 93 : 94;
% dlist = 181 : 182;
chome = './test_run';   % CHIRP output home
opt1 = struct;

fstr = mfilename;  % this function name

% default params 
ahome = '/asl/data/airs/L1C';   % AIRS source home

% paths to AIRS and CHIRP data (home/yyyy)
ayear = fullfile(ahome, sprintf('%d', year));
cyear = fullfile(chome, sprintf('%d', year));

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
  for fi = 1 : length(flist)

%   if mod(fi, 10) == 0, fprintf(1, '.'), end

    agran = fullfile(apath, flist(fi).name);

    tic
    airs2chirp(agran, cpath, opt1);
    toc

  end % loop on granules
% fprintf(1, '\n')
end % loop on days

