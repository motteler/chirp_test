%
% NAME
%   airs_geo_attr - geo-dependent AIRS product attributes
%
% SYNOPSIS
%   prod_attr = airs_geo_attr(d1, prod_attr)
%
% INPUTS
%   d1        - airs data before reshape
%   prod_attr - global product attributes
%
% OUTPUT
%   prod_attr - global product attributes
%
% DISCUSSION
%   The values we want are easier to find with the original xtrack
%   by atrack L1b arrays, so we simply pass in the whole AIRS read
%   struct.  Matlab uses a conditional call by reference, so d1 is
%   not copied as long as it is not modified.
%
%   The prod_attr.geospatial_bounds spec is from Evan.  This is a
%   list of five lon, lat pairs as a text string, with the prefix
%   "POLYGON".  Looking along track from space we have the corner
%   indices
%
%       1,135 xtrack 90,135
%
%       1,1   xtrack 90,1
%
%   we list these counterclockwise, starting from (1,1), duplicating
%   (1,1) at the end
%

function prod_attr = airs_geo_attr(d1, prod_attr)

% start and end times as a string
prod_attr.time_of_first_valid_obs = utc_string(airs2dnum(d1.Time(1)));
prod_attr.time_of_last_valid_obs  = utc_string(airs2dnum(d1.Time(end)));

% attributes set from data
prod_attr.geospatial_lat_max = single(max(d1.Latitude(:)));
prod_attr.geospatial_lat_mid = single(d1.Latitude(45,68));
prod_attr.geospatial_lat_min = single(min(d1.Latitude(:)));
prod_attr.geospatial_lon_max = single(max(d1.Longitude(:)));
prod_attr.geospatial_lon_mid = single(d1.Longitude(45,68));
prod_attr.geospatial_lon_min = single(min(d1.Longitude(:)));

% granule corners, counterclockwise along track (v2 version)
gcorn = [d1.Latitude(1,1),    d1.Longitude(1,1), ...
         d1.Latitude(90,1),   d1.Longitude(90,1), ...
         d1.Latitude(90,135), d1.Longitude(90,135), ...
         d1.Latitude(1,135),  d1.Longitude(1,135), ...
         d1.Latitude(1,1),    d1.Longitude(1,1)];

% granule corners, counterclockwise along track (v3 version)
% gcorn = [d1.Longitude(1,1),    d1.Latitude(1,1), ...
%          d1.Longitude(90,1),   d1.Latitude(90,1), ...
%          d1.Longitude(90,135), d1.Latitude(90,135), ...
%          d1.Longitude(1,135),  d1.Latitude(1,135), ...
%          d1.Longitude(1,1),    d1.Latitude(1,1)];

sfmt = 'POLYGON ((%.2f %.2f, %.2f %.2f, %.2f %.2f, %.2f %.2f, %.2f %.2f))';

prod_attr.geospatial_bounds = sprintf(sfmt, gcorn);

