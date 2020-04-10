%
% NAME
%   gran_prod_attr - update per-granule product attributes
%
% SYNOPSIS
%   prod_attr = gran_prod_attr(gran_num, obs_time, run_time, prod_attr);
%
% INPUTS
%   gran_num  - integer granule number
%   obs_time  - obs start time, matlab datenum
%   run_time  - processing start time, matlab datenum
%   prod_attr - global product attributes
%

function prod_attr = gran_prod_attr(gran_num, obs_time, run_time, prod_attr);

% granule number as uint16
prod_attr.granule_number = uint16(gran_num);

% "granule id" (yyyymmddThhmm) as a string
obs_vec = datevec(obs_time);
gran_id = sprintf('%04d%02d%02dT%02d%02d', obs_vec(1:5));
prod_attr.gran_id = gran_id;

% granule number (gxxx) as a string
gran_num_str = sprintf('g%03d', gran_num); 
prod_attr.product_name_granule_number = gran_num_str;

% "timestamp" (yymmddhhmmss) as a string
run_vec = datevec(run_time);
run_vec(1) = mod(run_vec(1), 100);  % 2-digit year
run_time = sprintf('%02d%02d%02d%02d%02d%02d', run_vec(1:5));
prod_attr.product_name_timestamp = run_time;

