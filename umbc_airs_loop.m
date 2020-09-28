%
% NAME
%   umbc_airs_loop - set airs2chirp options and loop on days
%
% SYNOPSIS
%   umbc_airs_loop(year, dlist)
%
% INPUTS
%   year   - integer year
%   dlist  - integer vector of days-of-the-year
%
% DISCUSSION
%   Assumes data is organized as home/yyyy/doy/granules.
%
% AUTHOR
%   H. Motteler, 12 Dec 2019
%

function umbc_airs_loop(year, dlist)

% set up source paths
addpath /home/motteler/cris/ccast/source
addpath /home/motteler/cris/ccast/motmsc/time
addpath /home/motteler/shome/airs_decon/source
addpath /home/motteler/matlab/yaml

% AIRS and CHIRP local homes
airs_home = '/asl/airs/l1c_v672';
chirp_home = '/asl/isilon/chirp/chirp_AQ_test2';

% AIRS and CHIRP annual data (home/yyyy)
airs_year = fullfile(airs_home, sprintf('%d', year));
chirp_year = fullfile(chirp_home, sprintf('%d', year));

% yaml config files
yaml_init = 'chirp_AQ_demo.yaml';  % initial config
yaml_gran = 'chirp_AQ_gtmp.yaml';  % current granule 

% read the initial yaml specs
[proc_opts, prod_attr] = read_yaml_cfg(yaml_init);

% airs2chirp options (now set in yaml_init)
% proc_opts = struct;
% proc_opts.verbose = 1;   % 0=quiet, 1=talky, 2=plots
% proc_opts.tchunk = 400;  % translation chunk size

% run-specific CHIRP product attributes
% prod_attr = struct;
% prod_attr.product_name_project    = 'SNDR';
% prod_attr.product_name_platform   = 'SS1330';
% prod_attr.product_name_instr      = 'CHIRP';
% prod_attr.product_name_duration   = 'm06';
% prod_attr.product_name_type_id    = 'L1_AQ';
% prod_attr.product_name_variant    = 'std';
% prod_attr.product_name_version    = 'v01_07';
% prod_attr.product_name_producer   = 'U';
% prod_attr.product_name_extension  = 'nc';

% this function name
fstr = mfilename;

% loop on days of the year
for di = dlist

  % add day-of-year to paths
  doy = sprintf('%03d', di);
  fprintf(1, '%s: processing %d doy %s\n', fstr, year, doy)
  airs_dir = fullfile(airs_year, doy);
  chirp_dir = fullfile(chirp_year, doy);

  % check that the source path exists
  if exist(airs_dir) ~= 7
    fprintf(1, '%s: bad source path %s\n', fstr, airs_dir)
    continue
  end

  % create the output path, if needed
  if exist(chirp_dir) ~= 7, mkdir(chirp_dir), end

  % loop on AIRS granules
  flist = dir(fullfile(airs_dir, 'AIRS*L1C*.hdf'));
  for fi = 1 : length(flist);
    airs_l1c = flist(fi).name;
    airs_gran = fullfile(airs_dir, airs_l1c);

%   % direct call of airs2chirp
%   airs2chirp(airs_gran, chirp_dir, proc_opts, prod_attr);

    % call airs2chirp via yaml_gran and chirp_main

    % set up proc_opts
    proc_opts.airs_l1c = airs_l1c;
    proc_opts.airs_dir = airs_dir;
    proc_opts.chirp_dir = chirp_dir;

    % write the updated yaml spec for this granule
    write_yaml_cfg(yaml_gran, proc_opts, prod_attr);

    % chirp main calls airs2chirp
    chirp_airs_main(yaml_gran);

  end % loop on granules
end % loop on days

