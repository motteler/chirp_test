%
% NAME
%   copy_cris_attr - update per-granule product attributes
%
% SYNOPSIS
%   prod_attr = copy_cris_attr(cris_attr, prod_attr);
%
% INPUTS
%   cris_attr - cris global product attributes
%   prod_attr - chirp global product attributes
%
% NOTE
%   for CrIS-parent simply copy global attributes with matching
%   names
%

function prod_attr = copy_cris_attr(cris_attr, prod_attr);

fstr = mfilename;

alist = {
  'day_night_flag', ...
  'geospatial_bounds', ...
  'geospatial_lat_max', ...
  'geospatial_lat_mid', ...
  'geospatial_lat_min', ...
  'geospatial_lon_max', ...
  'geospatial_lon_mid', ...
  'geospatial_lon_min', ...
  'granule_number', ...
  'orbitDirection', ...
  'time_coverage_duration', ...
  'time_coverage_end', ...
  'time_coverage_mid', ...
  'time_coverage_start', ...
  'time_of_first_valid_obs', ...
  'time_of_last_valid_obs'};

for i = 1 : length(alist)

  if ~isfield(cris_attr, alist{i})
    fprintf(1, '%s: no %s in CrIS attributes\n', fstr, alist{i})
    continue
  end

% if ~isfield(prod_attr, alist{i})
%   fprintf(1, '%s: no %s in CHIRP attributes\n', fstr, alist{i})
%   continue
% end

  prod_attr.(alist{i}) = cris_attr.(alist{i});

end
