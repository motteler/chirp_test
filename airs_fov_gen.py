import sys
import numpy as np
import xarray as xr
from pyhdf.HDF import *
from pyhdf.VS import *

# Earth's Radius in m
R = 6371008.8

def haversine(lat0, lon0, lat1, lon1):
    """Great circle distance between two sets of points.

    Parameters
    ----------
    lat0, lon0 : array_like
        Latitude and Longitude of starting point.
    lat1, lon1 : array_like
        Latitude and Longitude of ending point.

    Returns
    -------
    array_like
        Great circle distance.
    """
    # Convert all angles to radians
    lon0, lat0, lon1, lat1 = map(np.radians, [lon0, lat0, lon1, lat1])

    dlon = lon1 - lon0
    dlat = lat1 - lat0

    # Calculate Great Circle distance
    a = np.sin(dlat/2.0)**2 + np.cos(lat0) * np.cos(lat1) * np.sin(dlon/2.0)**2
    c = 2 * np.arcsin(np.sqrt(a))
    distance = R * c
    return np.abs(distance)


def great_circle_arc(h, zen):
    """Calculate length of great circle arc from altitude and zenith angle.

    Parameters
    ----------
    h : array_like
        Distance to satellite from reference point (m).
    zen : array_like
        Zenith angle.

    Returns
    -------
    array_like
        Great circle distance.
    """
    zen = np.deg2rad(zen)
    return R*np.abs(np.arcsin((1+h/R)*np.sin(zen)) - zen)


def initial_azi(lat0, lon0, lat1, lon1):
    """Determine initial azimuth given start and end points.

    Parameters
    ----------
    lat0, lon0 : array_like
        Latitude and Longitude of starting point.
    lat1, lon1 : array_like
        Latitude and Longitude of ending point.

    Returns
    -------
    array_like
        Initial azimuth from start to end point.
    """
    # Convert all angles to radians
    lon0, lat0, lon1, lat1 = map(np.radians, [lon0, lat0, lon1, lat1])
    dlon = lon1 - lon0

    # Calculate initial azimuth
    n = np.sin(dlon)*np.cos(lat1)
    d = np.cos(lat0)*np.sin(lat1) - np.sin(lat0)*np.cos(lat1)*np.cos(dlon)
    return np.rad2deg(np.arctan2(n, d))


def destination_point(lat0, lon0, s, azi):
    """Locate destination point on Earth given given starting point, total
    distance, and azimuth angle.

    Parameters
    ----------
    lat0, lon0 : array_like
        Latitude and Longitude of starting point.
    s : array_like
        Great circle distance from starting point to destination point.
    azi : array_like
        Azimuth angle, measured E of N.

    Returns
    -------
    array_like
        Latitude and Longitude of destination point.
    """
    # Convert all angles to radians
    lat0, lon0, azi = map(np.radians, [lat0, lon0, azi])

    # Calculate destination point
    delta = s/R
    fact = np.cos(lat0) * np.sin(delta)
    az1 = fact * np.cos(azi)
    az2 = fact * np.sin(azi)
    lat1 = np.arcsin(np.sin(lat0) * np.cos(delta) + az1)
    lon1 = lon0 + np.arctan2(az2, np.cos(delta) - np.sin(lat0) * np.sin(lat1))
    return np.rad2deg(lat1), np.rad2deg(lon1)


def spherical_to_cart(lat, lon, r):
    """Spherical to Cartesian coordinate tranformation

    Parameters
    ----------
    lat, lon, r : array_like
        Latitude, Longitude, and distance to center of Earth.

    Returns
    -------
    array_like
        Input position expressed in cartesian coordinates.
    """
    lat = np.deg2rad(lat)
    lon = np.deg2rad(lon)
    x = r * np.cos(lat) * np.cos(lon)
    y = r * np.cos(lat) * np.sin(lon)
    z = r * np.sin(lat)
    return x, y, z


def distance(lat0, lon0, r0, lat1, lon1, r1):
    """Determine LOS distance between two points.

    Parameters
    ----------
    lat0, lon0, r0 : array_like
        Latitude, Longitude, and earth-center distance of starting point.
    lat1, lon1, r1 : array_like
        Latitude, Longitude, and earth-center distance of ending point.

    Returns
    -------
    array_like
        LOS distance between points in m.
    """
    x0, y0, z0 = spherical_to_cart(lat0, lon0, r0)
    x1, y1, z1 = spherical_to_cart(lat1, lon1, r1)
    h = np.sqrt((x1 - x0)**2 + (y1 - y0)**2 + (z1 - z0)**2)
    return h


class FOV:
    def __init__(self, slat, slon, lat0, lon0, h0, zen0, azi0, beam):
        """Build FOV from satellite position and orientation.

        Parameters
        ----------
        slat, slon : array_like
            Subsatellite lat/lon.
        lat0, lon0 : array_like
            FOV center lat/lon.
        h0 : array_like
            Satellite altitude above subsatellite point (m).
        zen0, azi, beam : array_like
            Zenith, azimuth, and aperture angles.
        """
        def concat_arrays(*arrays):
            arrays = [arr.values if isinstance(arr, xr.DataArray) else arr
                     for arr in arrays]
            return np.asarray(arrays)

        # Step 1: Determine length of semi-major axis
        azi0 = (azi0 + 180) % 360
        sazi = initial_azi(slat, slon, lat0, lon0)
        s1 = great_circle_arc(h0, zen0 - beam/2)
        s2 = great_circle_arc(h0, zen0 + beam/2)
        lat1, lon1 = destination_point(slat, slon, s1, sazi)
        lat2, lon2 = destination_point(slat, slon, s2, sazi)
        a = haversine(lat1, lon1, lat2, lon2)/2

        # Step 2: Determine length of semi-minor axis
        h = distance(lat0, lon0, R, slat, slon, R + h0)
        b = great_circle_arc(h, beam/2)

        # Step 3: Determine "diagonal" length
        s = np.sqrt((a**2 + b**2)/2)

        # Step 4: Find 8 boundary points along the FOV ellipse
        azih = np.rad2deg(np.arccos(a/np.sqrt(a**2+b**2)))
        azis = [azi0, azi0 + azih, azi0 + 90, azi0 + 180 - azih, azi0 + 180,
                azi0 + 180 + azih, azi0 + 270, azi0 - azih]

        # Note: We are storing all of the necessary parameters into an xarray
        # Dataset object because it supports automatic broadcasting, and
        # therefore vectorization. This significantly speeds things up.
        ds = xr.Dataset()
        ds['s'] = ('fov_poly', 'atrack', 'xtrack'), concat_arrays(a, s, b, s, a, s, b, s)
        ds['azi'] = ('fov_poly', 'atrack', 'xtrack'), concat_arrays(*azis)
        ds['lat'] = ('atrack', 'xtrack'), lat0
        ds['lon'] = ('atrack', 'xtrack'), lon0
        ds = ds.transpose('atrack', 'xtrack', 'fov_poly')
        lat_bnds, lon_bnds = destination_point(ds.lat, ds.lon, ds.s, ds.azi)

        # Set attributes
        self.a = a
        self.b = b
        self.sat_range = h
        self.lat, self.lon = lat0, lon0
        self.lat_bnds, self.lon_bnds = lat_bnds, lon_bnds


def load_hdf_var(vs, variable):
    """Load a single variable into memory from an HDF file.

    Parameters
    ----------
    vs : pyhdf.VS
        Start of vdata
    variable : str
        Name of variable

    Returns
    -------
    numpy.ndarray
        Variable values expressed as a numpy array
    """
    return np.asarray(vs.attach(variable)[:]).squeeze()


if __name__ == '__main__':
    fname = sys.argv[1]
    sds = xr.open_dataset(fname)
    hdf = HDF(fname)
    vs = hdf.vstart()
    slat = ('atrack'), load_hdf_var(vs, 'sat_lat')
    slon = ('atrack'), load_hdf_var(vs, 'sat_lon')
    lat = ('atrack', 'xtrack'), sds.Latitude.values
    lon = ('atrack', 'xtrack'), sds.Longitude.values
    h = ('atrack'), load_hdf_var(vs, 'satheight') * 1e3
    zen = ('atrack', 'xtrack'), sds.scanang.values
    azi = ('atrack', 'xtrack'), sds.satazi.values
    beam = 1.1
    ds = xr.Dataset(dict(slat=slat, slon=slon, lat=lat, lon=lon, h=h, zen=zen, azi=azi))
    fov = FOV(ds.slat, ds.slon, ds.lat, ds.lon, ds.h, ds.zen, ds.azi, beam)
    lat_bnds = fov.lat_bnds
    lon_bnds = fov.lon_bnds
    sat_range = ('atrack', 'xtrack'), fov.sat_range
    (xr.Dataset(dict(lat_bnds=lat_bnds, lon_bnds=lon_bnds, sat_range=sat_range))
        .transpose('atrack', 'xtrack', 'fov_poly')
        .to_netcdf('airs_fov_bnds.nc'))
