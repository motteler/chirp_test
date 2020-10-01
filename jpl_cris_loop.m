%
% NAME
%   jpl_cris_loop - set cris2chirp options and loop on days
%
% SYNOPSIS
%   opts_cris_loop(year, month, dlist)
%
% INPUTS
%   year   - integer year
%   month  - integer month
%   dlist  - integer vector of days
%

function jpl_cris_loop(year, month, dlist)

% set up source paths
addpath /home/motteler/repos/ccast/source
addpath /home/motteler/repos/airs_decon/source
addpath /home/motteler/matlab/yaml
addpath ./time

% CrIS and CHIRP local data homes
  cris_home =  '/peate_archive/NPPOps/jpss1/gdisc/2';
  chirp_home = '/home/motteler/data/chirp_J1_test9';
% cris_home =  '/peate_archive/NPPOps/snpp/gdisc/2';
% chirp_home = '/home/motteler/data/chirp_SN_test9';

% CrIS and CHIRP path with year and month
cris_month = fullfile(cris_home, sprintf('%d/%02d', year, month));
chirp_month = fullfile(chirp_home, sprintf('%d/%02d', year, month));

% yaml config files
  yaml_init = 'chirp_J1_demo.yaml';  % initial config
  yaml_gran = 'chirp_J1_gtmp.yaml';  % current granule 
% yaml_init = 'chirp_SN_demo.yaml';  % initial config
% yaml_gran = 'chirp_SN_gtmp.yaml';  % current granule 

% read the initial yaml specs
[proc_opts, prod_attr] = read_yaml_cfg(yaml_init);

% this function name
fstr = mfilename;  

% loop on days of the month
for di = dlist

  % add day of month to paths
  dom = sprintf('%02d', di);
  fprintf(1, '%s: processing %d/%02d/%s\n', fstr, year, month, dom)
  cris_dir = fullfile(cris_month, dom, 'crisl1b');
  chirp_dir = fullfile(chirp_month, dom, 'crisl1b');

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

