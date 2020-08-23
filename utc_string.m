%
% datenum to UTC format char array, for global attributes
%

function s = utc_string(d)
v = datevec(d);
v(6) = round(v(6));
s = sprintf('%04d-%02d-%02dT%02d:%02d:%02dZ', v);

