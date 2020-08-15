%
% NAME
%   airs_fov_gen - FOV polygons and range from AIRS L1b data
%
% SYNOPSIS
%   [lat_bnds, lon_bnds, sat_range] = ...
%      airs_fov_gen(slat, slon, lat, lon, h, zen, azi, beam)
%
% INPUTS
%   slat - 135 x 1,  sat latitude
%   slon - 135 x 1,  sat longitude
%   lat  - 90 x 135  obs latitude
%   lon  - 90 x 135, obs longitude
%   h    - 135 x 1,  sat altitude, m
%   zen  - 90 x 135, scan angle wrt footprint
%   azi  - 90 x 135, spacecraft azimuth angle
%   beam - scalar, 1.1 deg for AIRS
%
% OUTPUTS
%   lat_bnds  - 8 x 90 x 135, FOV polygon lat bounds
%   lon_bnds  - 8 x 90 x 135, FOV polygon lon bounds
%   sat_range - 90 x 135, dist from sat to FOV center, m
%
% DISCUSSION
%   This is a transliteration of Alex Goodman's Python script of
%   the same name, which reads an AIRS L1c granule and writes the
%   values above to a netCDF file.  Python is row-order, so we flip
%   the inputs from column to row-order at the start, and back to
%   column-order at the end
%
%   The dimensions above are fixed in the reshape, below; to make
%   this more general-purpose, we could use the input sizes, instead
%   of fixed values.
%
%   The comments below are from the original Python
%

function [lat_bnds, lon_bnds, sat_range] = ...
  airs_fov_gen(slat, slon, lat0, lon0, h0, zen0, azi0, beam)

% transpose 90 x 135 inputs to 135 x 90
lat0 = lat0';
lon0 = lon0';
zen0 = zen0';
azi0 = azi0';

% Build FOV from satellite position and orientation.
% 
% Parameters
% ----------
% slat, slon : array_like
%     Subsatellite lat/lon.
% lat0, lon0 : array_like
%     FOV center lat/lon.
% h0 : array_like
%     Satellite altitude above subsatellite point (m).
% zen0, azi, beam : array_like
%     Zenith, azimuth, and aperture angles.

  % Earth's Radius in m
  R = 6371008.8;

  % Step 1: Determine length of semi-major axis
  azi0 = mod(azi0 + 180, 360);
  sazi = initial_azi(slat, slon, lat0, lon0);
  s1 = great_circle_arc(h0, zen0 - beam/2);
  s2 = great_circle_arc(h0, zen0 + beam/2);
  [lat1, lon1] = destination_point(slat, slon, s1, sazi);
  [lat2, lon2] = destination_point(slat, slon, s2, sazi);
  a = haversine(lat1, lon1, lat2, lon2)/2;

  % Step 2: Determine length of semi-minor axis
  h = distance(lat0, lon0, R, slat, slon, R + h0);
  b = great_circle_arc(h, beam/2);

  % Step 3: Determine "diagonal" length
  s = sqrt((a.^2 + b.^2)/2);

  % Step 4: Find 8 boundary points along the FOV ellipse
  azih = rad2deg(acos(a./sqrt(a.^2+b.^2)));
  azis = [azi0, azi0 + azih, azi0 + 90, azi0 + 180 - azih, ...
          azi0 + 180, azi0 + 180 + azih, azi0 + 270, azi0 - azih];

  % first try at reshaping the data
  s_tmp = cat(3, a, s, b, s, a, s, b, s);
  azi_tmp = reshape(azis, 135, 90, 8);
  [lat_bnds, lon_bnds] = destination_point(lat0, lon0, s_tmp, azi_tmp);

  lat_bnds = permute(lat_bnds, [3,2,1]);
  lon_bnds = permute(lon_bnds, [3,2,1]);
  sat_range = permute(h, [2,1]);

end % of airs_fov_gen

function dist = haversine(lat0, lon0, lat1, lon1)

% Great circle distance between two sets of points.
% 
% Parameters
% ----------
% lat0, lon0 : array_like
%     Latitude and Longitude of starting point.
% lat1, lon1 : array_like
%     Latitude and Longitude of ending point.
% 
% Returns
% -------
% array_like
%     Great circle distance.

  % Earth's Radius in m
  R = 6371008.8;

  % Convert all angles to radians
  lon0 = deg2rad(lon0);
  lat0 = deg2rad(lat0);
  lon1 = deg2rad(lon1);
  lat1 = deg2rad(lat1);

  dlon = lon1 - lon0;
  dlat = lat1 - lat0;

  % Calculate Great Circle distance
  a = sin(dlat/2.0).^2 + cos(lat0) .* cos(lat1) .* sin(dlon/2.0).^2;
  c = 2 * asin(sqrt(a));
  dist = abs(R * c);
end

function dist = great_circle_arc(h, zen)

% Calculate length of great circle arc from altitude and zenith angle.
% 
% Parameters
% ----------
% h : array_like
%     Distance to satellite from reference point (m).
% zen : array_like
%     Zenith angle.
%
% Returns
% -------
% array_like
%     Great circle distance.

  % Earth's Radius in m
  R = 6371008.8;

  zen = deg2rad(zen);
  dist = R*abs(asin((1+h/R).*sin(zen)) - zen);
end

function azi = initial_azi(lat0, lon0, lat1, lon1)

% Determine initial azimuth given start and end points.
% 
% Parameters
% ----------
% lat0, lon0 : array_like
%     Latitude and Longitude of starting point.
% lat1, lon1 : array_like
%     Latitude and Longitude of ending point.
% 
% Returns
% -------
% array_like
%     Initial azimuth from start to end point.

  % Convert all angles to radians
  lon0 = deg2rad(lon0);
  lat0 = deg2rad(lat0);
  lon1 = deg2rad(lon1);
  lat1 = deg2rad(lat1);

  dlon = lon1 - lon0;

  % Calculate initial azimuth
  n = sin(dlon) .* cos(lat1);
  d = cos(lat0) .* sin(lat1) - sin(lat0).*cos(lat1).*cos(dlon);
  azi = rad2deg(atan2(n, d));
end

function [lat2, lon2] = destination_point(lat0, lon0, s, azi)

% Locate destination point on Earth given given starting point, total
% distance, and azimuth angle.
% 
% Parameters
% ----------
% lat0, lon0 : array_like
%     Latitude and Longitude of starting point.
% s : array_like
%     Great circle distance from starting point to destination point.
% azi : array_like
%     Azimuth angle, measured E of N.
% 
% Returns
% -------
% array_like
%     Latitude and Longitude of destination point.

  % Earth's Radius in m
  R = 6371008.8;

  % Convert all angles to radians
  lon0 = deg2rad(lon0);
  lat0 = deg2rad(lat0);
  azi  = deg2rad(azi);

  % Calculate destination point
  delta = s/R;
  fact = cos(lat0) .* sin(delta);
  az1 = fact .* cos(azi);
  az2 = fact .* sin(azi);
  lat1 = asin(sin(lat0) .* cos(delta) + az1);
  lon1 = lon0 + atan2(az2, cos(delta) - sin(lat0) .* sin(lat1));
  lat2 = rad2deg(lat1);
  lon2 = rad2deg(lon1);
end

function [x, y, z] = spherical_to_cart(lat, lon, r)

% Spherical to Cartesian coordinate tranformation
% 
% Parameters
% ----------
% lat, lon, r : array_like
%     Latitude, Longitude, and distance to center of Earth.
% 
% Returns
% -------
% array_like
%     Input position expressed in cartesian coordinates.

  lat = deg2rad(lat);
  lon = deg2rad(lon);
  x = r .* cos(lat) .* cos(lon);
  y = r .* cos(lat) .* sin(lon);
  z = r .* sin(lat);
end    

function h = distance(lat0, lon0, r0, lat1, lon1, r1)

% Determine LOS distance between two points.
% 
% Parameters
% ----------
% lat0, lon0, r0 : array_like
%     Latitude, Longitude, and earth-center distance of starting point.
% lat1, lon1, r1 : array_like
%     Latitude, Longitude, and earth-center distance of ending point.
% 
% Returns
% -------
% array_like
%     LOS distance between points in m.

    [x0, y0, z0] = spherical_to_cart(lat0, lon0, r0);
    [x1, y1, z1] = spherical_to_cart(lat1, lon1, r1);
    h = sqrt((x1 - x0).^2 + (y1 - y0).^2 + (z1 - z0).^2);
end

