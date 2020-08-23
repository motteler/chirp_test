%
% NAME
%   umbc_cris_loop - set cris2chirp options and loop on days
%
% SYNOPSIS
%   umbc_cris_loop(year, dlist)
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

function umbc_cris_loop(year, dlist)

% set up source paths
addpath /home/motteler/cris/ccast/source
addpath /home/motteler/cris/ccast/motmsc/time
addpath /home/motteler/shome/airs_decon/source
addpath /home/motteler/matlab/yaml

% CrIS and CHIRP local data homes
% cris_home = '/home/motteler/shome/daac_test/SNPPCrISL1B.2';
cris_home = '/asl/isilon/cris/nasa_l1b/npp';
chirp_home = '/asl/isilon/chirp/chirp_SN_test4';

% CrIS and CHIRP annual data (home/yyyy)
cris_year = fullfile(cris_home, sprintf('%d', year));
chirp_year = fullfile(chirp_home, sprintf('%d', year));

% yaml config files
  yaml_init = 'chirp_SN_init.yaml';  % initial config
  yaml_gran = 'chirp_SN_gran.yaml';  % current granule 
% yaml_init = 'chirp_J1_init.yaml';  % initial config
% yaml_gran = 'chirp_J1_gran.yaml';  % current granule 

% read the initial yaml specs
[proc_opts, prod_attr] = read_yaml_cfg(yaml_init);

% cris2chirp options (now set in yaml_init)
% proc_opts = struct;
% proc_opts.verbose = 1;   % 0=quiet, 1=talky, 2=plots

% run-specific CHIRP product attributes
% prod_attr = struct;
% prod_attr.product_name_project    = 'SNDR';
% prod_attr.product_name_platform   = 'SS1330';
% prod_attr.product_name_instr      = 'CHIRP';
% prod_attr.product_name_duration   = 'm06';
% prod_attr.product_name_type_id    = 'L1_SN';
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
  cris_dir = fullfile(cris_year, doy);
  chirp_dir = fullfile(chirp_year, doy);

  % check that the source path exists
  if exist(cris_dir) ~= 7
    fprintf(1, '%s: bad source path %s\n', fstr, cris_dir)
    continue
  end

  % create the output path, if needed
  if exist(chirp_dir) ~= 7, mkdir(chirp_dir), end

  % loop on CrIS granules
  flist = dir(fullfile(cris_dir, 'SNDR.*.CRIS*L1B.*.nc'));
  for fi = 1 : length(flist)
    cris_l1b = flist(fi).name;
    cris_gran = fullfile(cris_dir, cris_l1b);

%   % direct call of airs2chirp
%   cris2chirp(cris_gran, chirp_dir, proc_opts, prod_attr);

    % call cris2chirp via yaml_gran and chirp_main

    % set up proc_opts
    proc_opts.cris_l1b = cris_l1b;
    proc_opts.cris_dir = cris_dir;
    proc_opts.chirp_dir = chirp_dir;

    % write the updated yaml spec for this granule
    write_yaml_cfg(yaml_gran, proc_opts, prod_attr);

    % chirp main calls airs2chirp
    chirp_cris_main(yaml_gran);

  end % loop on granules
end % loop on days

