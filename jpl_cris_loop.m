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
% DISCUSSION
%   set to CrIS FSR SNPP in granule loop, for tests
%

function jpl_cris_loop(year, month, dlist)

% set up source paths
addpath /home/motteler/cris/ccast/source
addpath /home/motteler/shome/airs_decon/source
addpath ./time
addpath ./yaml

% CrIS and CHIRP local data homes
cris_home = '/peate_archive/NPPOps/snpp/gdisc/2';
chirp_home = './chirp_SN_test1';

% CrIS and CHIRP path with year and month
cris_month = fullfile(cris_home, sprintf('%d/%02d', year, month));
chirp_month = fullfile(chirp_home, sprintf('%d/%02d', year, month));

% yaml config files
yaml_init = 'chirp_cris_init.yaml';  % initial config
yaml_gran = 'chirp_cris_gran.yaml';  % current granule 

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
  flist = dir(fullfile(cris_dir, 'SNDR.SNPP.CRIS*L1B.*.nc'));
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
    chirp_main('SN', yaml_gran);

  end % loop on granules
end % loop on days
