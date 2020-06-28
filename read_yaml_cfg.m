%
% NAME
%   read_yaml_cfg - read yaml proc opts and prod attr
%
% SYNOPSIS
%   [proc_opts, prod_attr] = read_yaml_cfg(yaml_cfg);
%
% INPUTS
%   yaml_cfg  - yaml config file
%
% OUTPUTS
%   proc_opts  - granule processing options
%   prod_attr  - granule product attributes
%

function [proc_opts, prod_attr] = read_yaml_cfg(yaml_file);

% function name
fstr = mfilename;

% output initially empty
proc_opts = struct([]);
prod_attr = struct([]);

% error if no yaml file
if exist(yaml_file) ~= 2
  error(sprintf('%s: can''t find config file %s\n', fstr, yaml_file))
end

% read the yaml file
s1 = ReadYaml(yaml_file);

% copy processing options
if isfield(s1, 'proc_opts')
  proc_opts = s1.proc_opts;
else
  fprintf(1, '%s: warning, no processing options (proc_opts)\n', fstr);
end

% copy product attributes
if isfield(s1, 'prod_attr')
  prod_attr = s1.prod_attr;
else
  fprintf(1, '%s: warning, no product attributes (prod_attr)\n', fstr);
end


