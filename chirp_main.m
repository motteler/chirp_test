%
% NAME
%   chirp_main - process a chirp granule from yaml spec
%
% SYNOPSIS
%   chirp_main(parent, yaml_cfg)
%
% INPUTS
%   parent   - 'AQ', 'SN', 'J1', 'J2', etc.
%   yaml_cfg  - yaml proc_opts and prod_addr structs
%
% DISCUSSION
%   This is the top-level function for JPL processing.  Processing
%   options (proc_opts) and product attributes (prod_attr) are set
%   in the yaml config file (yaml_cfg), and airs or cris2chirp is
%   called to translate one granule.  Paths to libs are set here for
%   the interpreted version or as includes for the compiled version.
%
% AUTHOR
%   H. Motteler, 26 Jun 2020
%

function chirp_main(parent, yaml_cfg)

% set up source paths (comment out for compiler)
% addpath /home/motteler/cris/ccast/source
% addpath /home/motteler/cris/ccast/motmsc/time
% addpath /home/motteler/shome/airs_decon/source
% addpath /home/motteler/matlab/yaml

% get the yaml config sepcs
[proc_opts, prod_attr] = read_yaml_cfg(yaml_cfg);

switch parent
  case 'AQ', 
    airs_gran = fullfile(proc_opts.airs_dir, proc_opts.airs_l1c);
    chirp_dir = proc_opts.chirp_dir;
    airs2chirp(airs_gran, chirp_dir, proc_opts, prod_attr);
  case 'SN', 
    cris_gran = fullfile(proc_opts.cris_dir, proc_opts.cris_l1b);
    chirp_dir = proc_opts.chirp_dir;
    cris2chirp(cris_gran, chirp_dir, proc_opts, prod_attr);
  otherwise,
    error(sprintf('unexpected parent %s', parent))
end

