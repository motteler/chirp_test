%
% opts_airs_test - test driver for airs2chirp
%

year = 2017;
dlist = 101;

% set up source paths
addpath /home/motteler/cris/ccast/source
addpath /home/motteler/cris/ccast/motmsc/time
addpath /home/motteler/shome/airs_decon/source

% AIRS and CHIRP local homes
ahome = '/asl/xfs3/airs/L1C_v672';      % AIRS source home
chome = './test_airs_src';              % CHIRP output home

% AIRS and CHIRP annual data (home/yyyy)
ayear = fullfile(ahome, sprintf('%d', year));
cyear = fullfile(chome, sprintf('%d', year));

% run-specific CHIRP product attributes
prod_attr = init_prod_attr;
prod_attr.product_name_project    = 'SNDR';
prod_attr.product_name_platform   = 'SS1330';
prod_attr.product_name_instr      = 'CHIRP';
prod_attr.product_name_duration   = 'm06';
prod_attr.product_name_type_id    = 'L1_AQ';
prod_attr.product_name_variant    = 'std';
prod_attr.product_name_version    = 'v01_07';
prod_attr.product_name_producer   = 'U';
prod_attr.product_name_extension  = 'nc';

% airs2chirp options
proc_opts = struct;
proc_opts.verbose = 2;   % 0=quiet, 1=talky, 2=plots
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
    airs2chirp(agran, cpath, prod_attr, proc_opts);
  end % loop on granules
end % loop on days

