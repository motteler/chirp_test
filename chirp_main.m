%
% NAME
%   chirp_main - top-level wrapper for translations to chirp
%
% SYNOPSIS
%   chirp_main(parent, yaml_cfg)
%
% INPUTS
%   parent   - 'AQ', 'SN', 'J1', 'J2', etc.
%   yaml_cfg  - yaml file with proc_opts and prod_addr info
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

function chirp_main(parent, yaml_cfg)

% source paths for interpreted code
if ~isdeployed
  addpath /home/motteler/cris/ccast/source
  addpath /home/motteler/shome/airs_decon/source
  addpath ./time
  addpath ./yaml
end

% matlabpath
% javaclasspath
  ctfroot
% which leap-seconds.list
% which snakeyaml-1.9.jar

% get the yaml config specs
[proc_opts, prod_attr] = read_yaml_cfg(yaml_cfg);

switch parent
  case 'AQ', 
    airs_gran = fullfile(proc_opts.airs_dir, proc_opts.airs_l1c);
    chirp_dir = proc_opts.chirp_dir;
    airs2chirp(airs_gran, chirp_dir, proc_opts, prod_attr);
  case {'SN', 'J1', 'J2'}
    cris_gran = fullfile(proc_opts.cris_dir, proc_opts.cris_l1b);
    chirp_dir = proc_opts.chirp_dir;
    cris2chirp(cris_gran, chirp_dir, proc_opts, prod_attr);
  otherwise,
    error(sprintf('unexpected parent %s', parent))
end

