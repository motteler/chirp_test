%
% NAME
%   write_prod_attr - write global attributes from prod_attr struct
%
% SYNOPSIS
%   write_prod_attr(nc_data, prod_attr);
%
% INPUTS
%   nc_data   - initial ".nc" file, from CDL spec
%   prod_attr - cumulative global attribute struct
%
% DISCUSSION
%   prod_attr is a mix of text and numeric values, with most of
%   the text values as char arrays, with a few strings in the mix.
%   The CDL spec for global text attributes is string, so we coerce
%   char arrays to strings before calling writeatt.  Text from the
%   CDL spec appears as strings, so if we don't do this we get a mix
%   of strings and char arrays in the netCDF global attributes.
%
%   In addition there seems to be a problem compiling code without
%   the coercion when prod_attr.qa_no_data is set to 'TRUE' rather
%   than "TRUE".
%
%   ncwriteatt (commented out below) ignores the string coercion and
%   writes everything as char arrays

function write_prod_attr(nc_data, prod_attr)

ftmp = fieldnames(prod_attr);

for i = 1 : length(ftmp)
  vtmp = prod_attr.(ftmp{i});
  if ischar(vtmp)
    vtmp = string(vtmp);
  end

  h5writeatt(nc_data, '/', ftmp{i}, vtmp)
% ncwriteatt(nc_data, '/', ftmp{i}, vtmp)  % string coercion fails

end
