%
% NAME
%   chirp_main - top-level wrapper for chirp translation
%
% SYNOPSIS
%   chirp_main(yaml_cfg)
%
% INPUTS
%   yaml_cfg  - yaml file with proc_opts and prod_addr 
%
% DISCUSSION
% 
%   This is the top-level function for translating a single granule
%   from AIRS or CrIS to CHIRP.  It reads a YAML spec that specifies
%   processing options and product attributes and calls airs2chirp
%   or cris2chirp, as needed.  Paths to libs can be set here for the
%   interpreted version.
%
% AUTHOR
%   H. Motteler, 26 Jun 2020
%

function chirp_cris_main(yaml_cfg)

% source paths for interpreted code
if ~isdeployed
  addpath /home/motteler/cris/ccast/source
  addpath /home/motteler/shome/airs_decon/source
  addpath ./time
  addpath ./yaml
end

% matlabpath
% javaclasspath
% ctfroot
% which leap-seconds.list
% which snakeyaml-1.9.jar

% read the yaml config specs
[proc_opts, prod_attr] = read_yaml_cfg(yaml_cfg);

% get input file and output path
cris_gran = fullfile(proc_opts.cris_dir, proc_opts.cris_l1b);
chirp_dir = proc_opts.chirp_dir;

% call cris2chirp
cris2chirp(cris_gran, chirp_dir, proc_opts, prod_attr);

