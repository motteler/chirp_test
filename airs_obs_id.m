%
%  airs_obs_id - generate obs id strings for AIRS
%

function obs_id = airs_obs_id(obs_time_utc, airs_atrack, airs_xtrack)

[~, nobs] = size(obs_time_utc);

obs_id = strings(nobs, 1);

sfmt = '%04d%02d%02dT%02d%02d.%03dE%02d';

for i = 1 : nobs
  obs_id(i) = ...
     sprintf(sfmt, obs_time_utc(1:5, 1), airs_atrack(i), airs_xtrack(i));
end

