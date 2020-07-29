%
% NAME
%   write_prod_attr - write global attributes from prod_attr
%
% SYNOPSIS
%   write_prod_attr(nc_data, prod_attr);
%

function write_prod_attr(nc_data, prod_attr)

% check strange compiler bug with char arrays
% prod_attr.qa_no_data = "TRUE";  % try a string
% display(prod_attr.qa_no_data)
% prod_attr = rmfield(prod_attr, 'qa_no_data');

ftmp = fieldnames(prod_attr);

% fprintf(1, 'length(ftmp) = %d\n', length(ftmp))

% the CDL spec for string attributes is string, so as a precaution
% coerce char arrays to strings before calling writeatt.  This does
% not seem to be necessary for the interpreter, but should not hurt,
% and fixes the problem for the compiler.

for i = 1 : length(ftmp)
  vtmp = prod_attr.(ftmp{i});
  if ischar(vtmp)
    vtmp = string(vtmp);
  end

  h5writeatt(nc_data, '/', ftmp{i}, vtmp)
% ncwriteatt(nc_data, '/', ftmp{i}, vtmp)

end
