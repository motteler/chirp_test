
% run after quick_look.m, to define d1 and d2

addpath /home/motteler/cris/ccast/motmsc/time
addpath /home/motteler/cris/ccast/motmsc/utils

% time check index
% ix = 131:165;
  ix = 231:265;  
  ix = 31 : 65;
  ix = 66 : 90;

% show the utc discretization
u1 = d1.obs_time_utc(:, ix);
u2 = d2.obs_time_utc(:, ix);

% get tai 93 residual in us
t1 = d1.obs_time_tai93(ix);
t2 = d2.obs_time_tai93(ix);
t1u = mod(t1*1e6, 1e3);
t2u = mod(t2*1e6, 1e3);
t1m = mod(t1*1e3, 1e3);
t2m = mod(t2*1e3, 1e3);

t1s = mod(tai2utc(airs2tai(t1)), 60);
t2s = mod(tai2utc(airs2tai(t2)), 60);

% AIRS comparison
% [u1(6:8,:)', floor(t1s), floor(t1m), round2n(floor(t1u),1)]
  [u1(6:8,:)', floor(t1s), floor(t1m), floor(t1u)]

return
% CrIS comparison
% [u2(6:8,:)', floor(t2s), floor(t2m), round2n(floor(t2u),1)]
  [u2(6:8,:)', floor(t2s), floor(t2m), floor(t2u)]

