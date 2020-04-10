%
%  new_obs_id - generate a new obs id string from TAI 93
%
% the obs ID format is yyyymmddThhmm, for example 20160125T1300
%

% NOTE: need to check how the obs id array looks from UW/NASA data

function obs_id = new_obs_id(obs_time_utc, xtrack, xtrack)

[~,nobs] = size(obs_time_utc);

obs_id = sprintf('%04d%02d%02dT%02d%02d', obs_time_utc(1:5));

