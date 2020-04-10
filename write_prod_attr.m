%
% NAME
%   write_prod_attr - write global attributes from prod_attr
%
% SYNOPSIS
%   write_prod_attr(nc_data, prod_attr);
%

function write_prod_attr(nc_data, prod_attr)

ftmp = fieldnames(prod_attr);

for i = 1 : length(ftmp)
  ncwriteatt(nc_data, '/', ftmp{i}, prod_attr.(ftmp{i}))
end
