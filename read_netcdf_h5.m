%
% read basic netcdf with H5 reads, to preserve data types
% 
% only reads top-level variables, top-level groups, and global
% attributes
%

function [s, a] = read_netcdf_h5(fn);
s = struct;
a = struct;

% top level variables
ni = ncinfo(fn);
if isfield(ni,'Variables')
  n = length(ni.Variables);
  for i=1:n
    s.(ni.Variables(i).Name) = h5read(fn, strcat('/',ni.Variables(i).Name));
  end
end

% top level groups
ng = length(ni.Groups);
for g = 1:ng
  n = length(ni.Groups(g).Variables);
  for i=1:n
    s.(ni.Groups(g).Name).(ni.Groups(g).Variables(i).Name) = ...
      h5read(fn,['/' ni.Groups(g).Name '/' ni.Groups(g).Variables(i).Name]);
  end
end

% global attributes
if isfield(ni,'Attributes')
  n = length(ni.Attributes);
  for i=1:n
    ntmp = ni.Attributes(i).Name;
    a.(ntmp) = h5readatt(fn, '/', ntmp);
  end
end

