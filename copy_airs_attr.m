%
% NAME
%   copy_airs_attr - copy product attributes from AIRS data
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
%   Evan and Alex, 3 Jun 2020
%

function prod_attr = copy_airs_attr(airs_attr, prod_attr);

fstr = mfilename;

prod_attr.AutomaticQualityFlag = airs_attr.AutomaticQAFlag;
prod_attr.orbitDirection       = airs_attr.node_type;
prod_attr.day_night_flag       = airs_attr.DayNightFlag;
prod_attr.geospatial_lat_mid   = airs_attr.LatGranuleCen;
prod_attr.geospatial_lon_mid   = airs_attr.LonGranuleCen;
prod_attr.granule_number       = airs_attr.granule_number;

prod_attr.qa_pct_data_missing = ...
  airs_attr.NumMissingData / airs_attr.NumTotalData;

prod_attr.qa_pct_data_geo = ...
  (airs_attr.NumProcessData + airs_attr.NumSpecialData) / airs_attr.NumTotalData;

prod_attr.qa_pct_data_sci_mode = ...
  airs_attr.NumProcessData / airs_attr.NumTotalData;

prod_attr.time_coverage_start = utc_string(airs2dnum(airs_attr.start_Time));

prod_attr.time_coverage_end = utc_string(airs2dnum(airs_attr.end_Time));

prod_attr.time_coverage_mid = ...
  utc_string(airs2dnum((airs_attr.start_Time + airs_attr.end_Time) / 2));

