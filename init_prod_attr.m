%
% init_prod_attr - initial values for global attributes
%
% fields set here will override values from the CDL spec, 
% and in turn cat be overridden by subsequent assignments.
%

function prod_attr = init_prod_attr

prod_attr = struct;

% % used to build the filename
% prod_attr.product_name_project    = "SNDR" ;
% prod_attr.product_name_platform   = "SS1330" ;
% prod_attr.product_name_instr      = "CHIRP" ;
% prod_attr.product_name_duration   = "m06" ;
% prod_attr.product_name_type_id    = "L1" ;
% prod_attr.product_name_variant    = "std" ;
% prod_attr.product_name_version    = "v01_05" ;
% prod_attr.product_name_producer   = "U" ;
% prod_attr.product_name_extension  = "nc" ;
% 
% % from the CDL spec, some need to be set
% prod_attr.date_created = "Unassigned" ;
% prod_attr.creator_name = "Unassigned" ;
% prod_attr.creator_email = "Unassigned" ;
% prod_attr.creator_url = "Unassigned" ;
% prod_attr.institution = "Unassigned" ;
% 
% prod_attr.publisher_name = "Unassigned" ;
% prod_attr.publisher_email = "Unassigned" ;
% prod_attr.publisher_url = "Unassigned" ;
% prod_attr.geospatial_lat_min = 9.96921e+36f ;
% prod_attr.geospatial_lat_max = 9.96921e+36f ;
% prod_attr.geospatial_lon_min = 9.96921e+36f ;
% prod_attr.geospatial_lon_max = 9.96921e+36f ;
% prod_attr.time_coverage_start = "" ;
% prod_attr.time_of_first_valid_obs = "" ;
% prod_attr.time_coverage_mid = "" ;
% prod_attr.time_coverage_end = "" ;
% prod_attr.time_of_last_valid_obs = "" ;
% prod_attr.time_coverage_duration = "P0000-00-00T00:06:00" ;
% 
% prod_attr.creator_type = "institution" ;
% prod_attr.creator_institution = "Jet Propulsion Laboratory --
% California Institute%  of Technology" ;
% prod_attr.product_version = "v01.00.00" ;
% 
% prod_attr.granule_number = 0US ;
% prod_attr.product_name_granule_number = "g000" ;
% prod_attr.gran_id = "yyyymmddThhmm" ;
% prod_attr.geospatial_lat_mid = 9.96921e+36f ;
% prod_attr.geospatial_lon_mid = 9.96921e+36f ;
% prod_attr.id = "Unassigned" ;
% prod_attr.identifier_product_doi = "Unassigned" ;
% prod_attr.identifier_product_doi_authority = "Unassigned" ;
% prod_attr.algorithm_version = "" ;
% prod_attr.production_host = "" ;
% prod_attr.input_file_names = "" ;
% prod_attr.input_file_types = "" ;
% prod_attr.input_file_dates = "" ;
% prod_attr.qa_pct_data_missing = 100.f ;
% prod_attr.qa_pct_data_geo = 0.f ;
% prod_attr.qa_pct_data_sci_mode = 0.f ;
% prod_attr.qa_no_data = "TRUE" ;
% prod_attr.title = "13:30 orbit L1 CHIRP" ;
% prod_attr.shortname = "SS1330CHIRP1_placeholder" ;
% prod_attr.product_group = "l1_chirp" ;
% prod_attr.references = "" ;
% 
