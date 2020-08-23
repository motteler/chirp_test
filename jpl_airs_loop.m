%
% NAME
%   jpl_airs_loop - set airs2chirp options and loop on days
%
% SYNOPSIS
%   opts_airs_loop(year, month, dlist)
%
% INPUTS
%   year   - integer year
%   month  - integer month
%   dlist  - integer vector of days
%
% DISCUSSION
%   set to Airs FSR SNPP in granule loop, for tests
%

function jpl_airs_loop(year, month, dlist)

% set up source paths
addpath /home/motteler/cris/ccast/source
addpath /home/motteler/shome/airs_decon/source
addpath /home/motteler/matlab/yaml
addpath ./time

% AIRS and CHIRP local homes
airs_home =  '/archive/AIRSOps/airs/gdaac/v6.7';
chirp_home = '/home/motteler/data/chirp_AQ_test5';

% Airs and CHIRP path with year and month
airs_month = fullfile(airs_home, sprintf('%d/%02d', year, month));
chirp_month = fullfile(chirp_home, sprintf('%d/%02d', year, month));

% yaml config files
yaml_init = 'chirp_AQ_init.yaml';  % initial config
yaml_gran = 'chirp_AQ_gran.yaml';  % current granule 

% read the initial yaml specs
[proc_opts, prod_attr] = read_yaml_cfg(yaml_init);

% this function name
fstr = mfilename;  

% loop on days of the month
for di = dlist

  % add day of month to paths
  dom = sprintf('%02d', di);
  fprintf(1, '%s: processing %d/%02d/%s\n', fstr, year, month, dom)
  airs_dir = fullfile(airs_month, dom, 'airicrad');
  chirp_dir = fullfile(chirp_month, dom, 'airicrad');

  % check that the source path exists
  if exist(airs_dir) ~= 7
    fprintf(1, '%s: bad source path %s\n', fstr, airs_dir)
    continue
  end

  % create the output path, if needed
  if exist(chirp_dir) ~= 7, mkdir(chirp_dir), end

  % loop on AIRS granules
  flist = dir(fullfile(airs_dir, 'AIRS*L1C*.hdf'));
  for fi = 1 : length(flist)
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

