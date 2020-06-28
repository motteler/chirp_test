%
% NAME
%   write_yaml_cfg - write yaml proc opts and prod attr
%
% SYNOPSIS
%   write_yaml_cfg(yaml_cfg, proc_opts, prod_attr);
%
% INPUTS
%   yaml_cfg   - yaml config file
%   proc_opts  - granule processing options
%   prod_attr  - granule product attributes
%

function write_yaml_cfg(yaml_cfg, proc_opts, prod_attr);

s1 = struct;
s1.proc_opts = proc_opts;
s1.prod_attr = prod_attr;

WriteYaml(yaml_cfg, s1);

