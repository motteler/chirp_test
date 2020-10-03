%
% NAME
%   chirp_airs_main - top-level wrapper for chirp translation
%
% SYNOPSIS
%   chirp_airs_main(yaml_cfg)
%
% INPUTS
%   yaml_cfg  - yaml file with proc_opts and prod_addr 
%
% DISCUSSION
%   This is the top-level function for translating a granule from
%   AIRS to CHIRP.  It reads a YAML spec that specifies processing
%   options and product attributes and calls airs2chirp.  Paths to
%   libs can be set here for the interpreted version.
%
% AUTHOR
%   H. Motteler, 26 Jun 2020
%

function chirp_airs_main(yaml_cfg)

% source paths for interpreted code
if ~isdeployed
  addpath /home/motteler/repos/ccast/source
  addpath /home/motteler/repos/airs_decon/source
  addpath /home/motteler/matlab/yaml
  addpath ./time
  addpath ./yaml
end

% read the yaml config specs
[proc_opts, prod_attr] = read_yaml_cfg(yaml_cfg);

% get input file and output path
airs_gran = fullfile(proc_opts.airs_dir, proc_opts.airs_l1c);
chirp_dir = proc_opts.chirp_dir;

% call airs2chirp
airs2chirp(airs_gran, chirp_dir, proc_opts, prod_attr);

