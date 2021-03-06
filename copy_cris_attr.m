%
% NAME
%   copy_cris_attr - copy global attributes from CRIS data
%
% SYNOPSIS
%   prod_attr = copy_cris_attr(cris_attr, prod_attr);
%
% INPUTS
%   cris_attr - cris global product attributes
%   prod_attr - chirp global product attributes
%
% NOTE
%   for CrIS-parent CHIRP we simply copy global attributes with
%   matching names.  Although the UW/NASA L1b global text attributes
%   are a mix of char and string types, the text values copied here
%   are all char arrays, possibly because they were written by the
%   L1b processing software rather than taken from the CDL spec.

function prod_attr = copy_cris_attr(cris_attr, prod_attr);

fstr = mfilename;

alist = {
  'AutomaticQualityFlag', ...
  'day_night_flag', ...
  'geospatial_bounds', ...
  'geospatial_lat_max', ...
  'geospatial_lat_mid', ...
  'geospatial_lat_min', ...
  'geospatial_lon_max', ...
  'geospatial_lon_mid', ...
  'geospatial_lon_min', ...
  'granule_number', ...
  'history', ...
  'orbitDirection', ...
  'qa_no_data', ...
  'qa_pct_data_missing', ...
  'qa_pct_data_geo', ...
  'qa_pct_data_sci_mode', ...
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

  prod_attr.(alist{i}) = cris_attr.(alist{i});

end

