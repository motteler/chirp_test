%
% NAME
%   copy_airs_attr - copy global attributes from AIRS data
%
% SYNOPSIS
%   prod_attr = copy_airs_attr(airs_attr, prod_attr);
%
% INPUTS
%   airs_attr - airs global product attributes
%   prod_attr - chirp global product attributes
%
% NOTE
%   for AIRS-parent CHIRP we have have to do some renaming and
%   calculations from the AIRS attributes.  reference: email from
%   Evan and Alex, 3 Jun 2020.  The AIRS text attributes are char
%   arrays, and utc_string also returns a char array, so the text
%   values here are all returned as char arrays.

function prod_attr = copy_airs_attr(airs_attr, prod_attr);

fstr = mfilename;

prod_attr.AutomaticQualityFlag = airs_attr.AutomaticQAFlag;
prod_attr.orbitDirection       = airs_attr.node_type;
prod_attr.day_night_flag       = airs_attr.DayNightFlag;
prod_attr.geospatial_lat_mid   = airs_attr.LatGranuleCen;
prod_attr.geospatial_lon_mid   = airs_attr.LonGranuleCen;
prod_attr.granule_number       = airs_attr.granule_number;

% convert int32 to single
NumTotalData    = single(airs_attr.NumTotalData);
NumMissingData  = single(airs_attr.NumMissingData);
NumProcessData  = single(airs_attr.NumProcessData);
NumSpecialData  = single(airs_attr.NumSpecialData);

% report the following three values as a percentage
prod_attr.qa_pct_data_missing = 100 * (NumMissingData / NumTotalData);
prod_attr.qa_pct_data_sci_mode = 100 * (NumProcessData / NumTotalData);
prod_attr.qa_pct_data_geo = ...
  100 * ((NumProcessData + NumSpecialData) / NumTotalData);

prod_attr.time_coverage_start = utc_string(airs2dnum(airs_attr.start_Time));

prod_attr.time_coverage_end = utc_string(airs2dnum(airs_attr.end_Time));

prod_attr.time_coverage_mid = ...
  utc_string(airs2dnum((airs_attr.start_Time + airs_attr.end_Time) / 2));

