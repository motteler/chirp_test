%
% NAME
%   airs_src_attr - airs-parent per-granule product attributes
%
% SYNOPSIS
%   prod_attr = airs_src_attr(gran_num, obs_time, airs_gran, prod_attr);
%
% INPUTS
%   gran_num  - integer granule number
%   obs_time  - obs start time, matlab datenum
%   airs_gran - airs granule path and filename
%   prod_attr - global product attributes
%
% NOTES
%   most of the text values are returned as char arrays, with the
%   exception of history.  This is a string because (at least for
%   cris-parent) this could be the concatenation with an earlier
%   string history.

function prod_attr = airs_src_attr(gran_num, obs_time, airs_gran, prod_attr);

% granule number as uint16
prod_attr.granule_number = uint16(gran_num);

% granule id (yyyymmddThhmm) as a char array
obs_vec = datevec(obs_time);
gran_id = sprintf('%04d%02d%02dT%02d%02d', obs_vec(1:5));
prod_attr.gran_id = gran_id;

% granule number (gxxx) as a char array
gran_num_str = sprintf('g%03d', gran_num); 
prod_attr.product_name_granule_number = gran_num_str;

% timestamp (yymmddhhmmss) as a char array
run_time = now;
run_vec = datevec(run_time);
run_vec(1) = mod(run_vec(1), 100);  % 2-digit year
run_vec(6) = round(run_vec(6));     % integer seconds
timestamp = sprintf('%02d%02d%02d%02d%02d%02d', run_vec);
prod_attr.product_name_timestamp = timestamp;
  
% date created (as a char array)
prod_attr.date_created = utc_string(run_time);

% production host
[s,w] = unix('uname -a');
if s == 0, prod_attr.production_host = w(1:end-1); end

% algorithm version, from the git repo.  this is saved in the file
% ALGVERS when the package is compiled
fid = fopen('ALGVERS');
if fid > 0
  tx = textscan(fid, '%s');
  prod_attr.algorithm_version = tx{1}{1};
  fclose(fid);
else
  prod_attr.algorithm_version = 'unassigned';
end

% user string, for history
[s,w] = unix('whoami');
if s == 0
  run_user = string(w(1:end-1));
else
  run_user = "unassigned_user";
end

% history is a concatenation; do this as a string because
% (at least for CrIS parent) we might have to concatenate 
% with an earlier string history.
prod_attr.history = ...
  string(prod_attr.date_created) + " " + ...
  run_user + " " + ...
 "chirp_cris_main" + " " + ...
  string(prod_attr.algorithm_version) + " " + ...
  string(prod_attr.gran_id);

% qa_no_data should always be false, since we skip granules 
% where all the data is bad, and it would be TRUE.
prod_attr.qa_no_data = 'FALSE';

% granule input file name, date, and type
fdir = dir(airs_gran);
prod_attr.input_file_names = fdir.name;
% dtmp = fdir.name(end-10:end);
% dstr = ['20', dtmp(1:2), '-', dtmp(3:4), '-', dtmp(5:6)];
[yy, mm, dd, ~, ~, ~] = datevec(fdir.datenum);
dstr = sprintf('%d-%d-%d', yy, mm, dd);
prod_attr.input_file_dates = dstr;
prod_attr.input_file_types = 'AIRS_L1C';

% add other input files
prod_attr.input_file_names = ...
  [prod_attr.input_file_names, ' ', ...
  'leap-seconds.list ', 'airs_l1c_srf_tables_lls_20181205.hdf ', ...
   'bias_AQ_v01d.mat ', 'corr_midres_v2.mat'];

prod_attr.input_file_dates = ...
  [prod_attr.input_file_dates, ' ', ...
  'git repo ',  'git repo ', 'git repo ', 'git repo'];

prod_attr.input_file_types = ...
  [prod_attr.input_file_types, ' ', ...
  'data ', 'data ', 'data ', 'data'];

