%
% NAME
%   chirp_cris_main - top-level wrapper for chirp translation
%
% SYNOPSIS
%   chirp_cris_main(yaml_cfg)
%
% INPUTS
%   yaml_cfg  - yaml file with proc_opts and prod_addr 
%
% DISCUSSION
%   This is the top-level function for translating a granule from
%   CrIS to CHIRP.  It reads a YAML spec that specifies processing
%   options and product attributes and calls cris2chirp.  Paths to
%   libs can be set here for the interpreted version.
%
% AUTHOR
%   H. Motteler, 26 Jun 2020
%

function chirp_cris_main(yaml_cfg)

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
cris_gran = fullfile(proc_opts.cris_dir, proc_opts.cris_l1b);
chirp_dir = proc_opts.chirp_dir;

% call cris2chirp
cris2chirp(cris_gran, chirp_dir, proc_opts, prod_attr);

