%
% NAME
%   copy_prod_attr - update per-granule product attributes
%
% SYNOPSIS
%   prod_attr = copy_prod_attr(cris_attr, prod_attr, alist);
%
% INPUTS
%   cris_attr - cris global product attributes
%   prod_attr - chirp global product attributes
%   alist     - list of fields to copy

function prod_attr = copy_prod_attr(cris_attr, prod_attr, alist)

alist = {
  'day_night_flag', ...
  'geospatial_bounds', ...
  'geospatial_lat_max', ...
  'geospatial_lat_mid', ...
  'geospatial_lat_min', ...
  'geospatial_lon_max', ...
  'geospatial_lon_mid', ...
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
    fprintf(1, 'copy_prod_attr: no %s in CrIS attributes\n', alist{i})
    continue
  end

% if ~isfield(prod_attr, alist{i})
%   fprintf(1, 'copy_prod_attr: no %s in CHIRP attributes\n', alist{i})
%   continue
% end

  prod_attr.(alist{i}) = cris_attr.(alist{i});

end

