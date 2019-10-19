%
% NAME
%   airs_obs_list - list selected AIRS obs
%
% SYNOPSIS
%   airs_obs_list(year, dlist, ofile, opt1)
%
% INPUTS
%   year   - year, as an integer
%   dlist  - list of days-of-the-year
%   ofile  - save file for obs lists
%
% DISCUSSION
%   uses channel list rather than window span
%
% AUTHOR
%  H. Motteler, 3 July 2017
%

function airs_obs_list(year, dlist, ofile, opt1)

% default params 
adir = '/asl/data/airs/L1C';   % path to AIRS data
ixt = 1 : 90;                  % full scans

% default frequency list (LW and SW windows)
vlist = [902.040, 902.387, 2499.533, 2500.601];

% process input options
if nargin == 4
  if isfield(opt1, 'adir'),  adir  = opt1.adir; end
  if isfield(opt1, 'ixt'),   ixt   = opt1.ixt; end
  if isfield(opt1, 'vlist'), vlist = opt1.vlist; end
else
  opt1 = struct;
end

% path to AIRS data, including year
ayear = fullfile(adir, sprintf('%d', year));

% get L1c channel indices
afrq = load('freq2645.txt');
ixv = interp1(afrq, 1:2645, vlist, 'nearest');
nchan = numel(ixv);
vlist = afrq(ixv);

% initialize obs lists
rad_list = [];
lat_list = [];
lon_list = [];
tai_list = [];
zen_list = [];
sol_list = [];

% loop on days of the year
for di = dlist

  % loop on AIRS granules
  doy = sprintf('%03d', di);
  fprintf(1, 'doy %s ', doy)
  flist = dir(fullfile(ayear, doy, 'AIRS*L1C*.hdf'));

  for fi = 1 : length(flist)

    if mod(fi, 10) == 0, fprintf(1, '.'), end

    % read radiance, nchan x 90 x 135
    afile = fullfile(ayear, doy, flist(fi).name);
    try
      rad = hdfread(afile, 'radiances');
    catch
      fprintf(1, '\nairs_rad_list: bad file %s', afile)
      continue
    end
    rad = rad(:, ixt, ixv);        % cross track and channel subset
    rad = permute(rad, [3,2,1]);   % transpose to column order

    % read geo data, 90 x 135
    lat = single(hdfread(afile, 'Latitude'));
    lon = single(hdfread(afile, 'Longitude'));
    tai = single(airs2tai(hdfread(afile, 'Time')));
    zen = hdfread(afile, 'satzen');
    sol = hdfread(afile, 'solzen');

    % cross track subset and transpose
    lat = lat(:,ixt); lat = permute(lat, [2,1]);
    lon = lon(:,ixt); lon = permute(lon, [2,1]);
    tai = tai(:,ixt); tai = permute(tai, [2,1]);
    zen = zen(:,ixt); zen = permute(zen, [2,1]);
    sol = sol(:,ixt); sol = permute(sol, [2,1]);

    % typical values
    %  lat     90x135   97200  double
    %  lon     90x135   97200  double
    %  rad  14x90x135  680400  single
 
    % basic radiance and latitude QC
    iOK = -90 <= lat & lat <= 90 & cAND(-1 < rad & rad < 250);

    % latitude subsample
    nxt = length(ixt);
    lat_rad = deg2rad(lat);
    jx = rand(nxt, 135) < abs(cos(lat_rad));
    jx = jx & iOK;

    % apply subsetting
    rad = rad(:,jx);
    lat = lat(jx);
    lon = lon(jx);
    tai = tai(jx);
    zen = zen(jx);
    sol = sol(jx);
    if isempty(lat), continue, end

    % typical values
    %  lat     2177x1   17416  double              
    %  lon     2177x1   17416  double              
    %  rad  14x2177    121912  single              

    % add obs to lists
    rad_list = [rad_list, rad];
    lat_list = [lat_list; lat];
    lon_list = [lon_list; lon];
    tai_list = [tai_list; tai];
    zen_list = [zen_list; zen];
    sol_list = [sol_list; sol];

  end % loop on granules
  fprintf(1, '\n')
end % loop on days

save(ofile, 'year', 'dlist', 'adir', 'ixt', 'ixv', 'vlist', 'nchan', ...
     'rad_list', 'lat_list', 'lon_list', 'tai_list', 'zen_list', 'sol_list');

