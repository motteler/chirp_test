%
% quick test of matlab version of airs_fov_gen
% 

p1 = '/asl/airs/l1c_v672/2019/175';
g1 = 'AIRS.2019.06.24.005.L1C.AIRS_Rad.v6.7.2.0.G19365195435.hdf';
[d1, a1] = read_airs_h4(fullfile(p1,g1));

% copy the fields we will be using
slat = d1.sat_lat;
slon = d1.sat_lon;
lat  = d1.Latitude;
lon  = d1.Longitude;
h    = d1.satheight * 1e3;
zen  = d1.scanang;
azi  = d1.satazi;
beam = 1.1;

% whos slat slon lat lon h zen azi

[lat_bnds, lon_bnds, sat_range] = ...
  airs_fov_gen(slat, slon, lat, lon, h, zen, azi, beam);

% whos lat_bnds lon_bnds sat_range

g2 = 'airs_fov_bnds.nc';
d2 = read_netcdf_h5(g2);

% these should be around 1e-7 to 1e-8
rms(lat_bnds(:) - d2.lat_bnds(:)) / rms(d2.lat_bnds(:))
rms(lon_bnds(:) - d2.lon_bnds(:)) / rms(d2.lon_bnds(:))
rms(sat_range(:) - d2.sat_range(:)) / rms(d2.sat_range(:))

