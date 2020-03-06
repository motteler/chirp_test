%
% demo of AIRS 3 x 3 FOV tiling
%

% AIRS
% nx = 90;
% na = 135;

% test spec
nx = 6;
na = 9;
nobs = nx * na;

% basic AIRS atrack and xtrack indices
airs_atrack = reshape(repmat(1:na, nx, 1), nobs, 1);
airs_xtrack = reshape(repmat((1:nx)', 1, na), nobs, 1);
whos airs_atrack airs_xtrack 

% CrIS-style 3 x 3 tiling (from Evan Manning)
atrack = floor((airs_atrack - 1) / 3) + 1;
xtrack = floor((airs_xtrack - 1) / 3) + 1;
fov = mod(airs_xtrack-1, 3) + 3 * mod(airs_atrack-1, 3) + 1;
whos atrack xtrack fov

ar = reshape(atrack, nx, na);
xr = reshape(xtrack, nx, na);
fr = reshape(fov, nx, na);

ar
xr
fr

