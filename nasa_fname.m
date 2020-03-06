%
% NAME
%   nasa_fname - build a nasa product filename
%
% SYNOPSIS
%   fname = nasa_fname(gran_num, obs_time, run_time, prod_name);
%
% INPUTS
%   gran_num  - integer granule number
%   obs_time  - obs start time, matlab datenum
%   run_time  - processing start time, matlab datenum
%   prod_name - all other product fields
%
% EXAMPLE
% 
%   gran_num = 33;
%   obs_time = datenum('30 Nov 2018, 13:20:32');
%   run_time = datenum('12 Feb 2020, 3:23:59');
%   prod_name = struct;
%   prod_name.project   = 'SNDR';
%   prod_name.platform  = 'CHIRP';
%   prod_name.instr     = 'SNPP';
%   prod_name.duration  = 'm06';
%   prod_name.type_id   = 'L1C';
%   prod_name.variant   = 'std';
%   prod_name.version   = 'v01_03';
%   prod_name.producer  = 'U';
%   prod_name.extension = 'nc';
%
%   fname = nasa_fname(gran_num, obs_time, run_time, prod_name);
%
% DISCUSSION
%   prod_name fields that are omitted are filled with "X"s, 
%   see comments below for full attribute names and definitions
%
% AUTHOR
%  H. Motteler, 2 Mar 2020
%

%     NASA filename and header attribute fields
%
%   attribute name        format  example   description
% ---------------------------------------------------------
% product_name_project     nnnn    SNDR   Sounder SIPS ID
% product_name_platform    pppp    SNPP   Satellite platform
% product_name_instr       iiii    CRIS   Instrument ID
% gran_id                 (see note #1)
% product_name_duration    m##     m06    6 minute granule
% granule_number           g###    g042   granule #42  
% product_name_type_id     text    L1B    product type
% product_name_variant     text    std    run, default std
% product_name_version    v##_##  v02_05
% product_name_producer      p      G     product location
% product_name_timestamp   (see note #2)  
% product_name_extension     nc     nc    netCDF file type
% 
% note 1. yyyymmddThhmm, example 20160101T0012
% note 2. yymmddhhmmss, example 180315115022
% 
% platforms include AIRS, SNPP, JPSS1, etc.
% 
% Example file names
% 
% SNDR.SNPP.CRIS.20160101T0012.m06.g003.L1B.std.v02_05.G.180315115022.nc
% 1234567890123456789012345678901234567890123456789012345678901234567890
% 0        1         2         3         4         5         6         7     
% 
% SNDR.CHIRP.AIRS.20160101T0012.m06.g003.L1B.std.v02_05.G.180315115022.nc
% 1234567890123456789012345678901234567890123456789012345678901234567890
% 0        1         2         3         4         5         6         7     
% 
% SNDR.CHIRP.1330.20160101T0012.m06.g003.L1B.std.v02_05.G.180315115022.nc
% 1234567890123456789012345678901234567890123456789012345678901234567890
% 0        1         2         3         4         5         6         7     
% 

function fname = nasa_fname(gran_num, obs_time, run_time, prod_name);

% granule number (gxxx) as a string
gran_str = sprintf('g%03d', gran_num);

% "granule id" (yyyymmddThhmm) as a string
obs_vec = datevec(obs_time);
obs_time = sprintf('%04d%02d%02dT%02d%02d', obs_vec(1:5));

% "timestamp" (yymmddhhmmss) as a string
run_vec = datevec(run_time);
run_vec(1) = mod(run_vec(1), 100);  % 2-digit year
run_time = sprintf('%02d%02d%02d%02d%02d%02d', run_vec(1:5));

% set product name defaults
project   = 'XXXX';
platform  = 'XXXXX';
instr     = 'XXXX';
duration  = 'mXX';
type_id   = 'XXX';
variant   = 'std';
version   = 'vXX_XX';
producer  = 'X';
extension = 'nc';

% prod_name overrides defaults
if isfield(prod_name, 'project'),   project   = prod_name.project; end
if isfield(prod_name, 'platform'),  platform  = prod_name.platform; end
if isfield(prod_name, 'instr'),     instr     = prod_name.instr; end
if isfield(prod_name, 'duration'),  duration  = prod_name.duration; end
if isfield(prod_name, 'type_id'),   type_id   = prod_name.type_id; end
if isfield(prod_name, 'variant'),   variant   = prod_name.variant; end
if isfield(prod_name, 'version'),   version   = prod_name.version; end
if isfield(prod_name, 'producer'),  producer  = prod_name.producer; end
if isfield(prod_name, 'extension'), extension = prod_name.extension; end

% build the filename
fname = [ ...
  project,   '.', ...   % product_name_project
  platform,  '.', ...   % product_name_platform
  instr,     '.', ...   % product_name_instr
  obs_time,  '.', ...   % gran_id (yyyymmddThhmm)
  duration,  '.', ...   % product_name_duration
  gran_str,  '.', ...   % granule_number (string)
  type_id,   '.', ...   % product_name_type_id
  variant,   '.', ...   % product_name_variant
  version,   '.', ...   % product_name_version
  producer,  '.', ...   % product_name_producer
  run_time,  '.', ...   % product_name_timestamp
  extension];           % product_name_extension

