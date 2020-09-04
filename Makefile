#
# Makefile to build and test chirp_airs_main and chirp_cris_main
#
# There are too many dependencies to properly sort out, so we call
# clean_cris or clean_airs before a new compilation.
# 
# The environment variable MCR_CACHE_ROOT should be set to the
# desired location for the MCR cache before running the compiled
# file, for example
# 
#   MCR_CACHE_ROOT=/home/motteler/runlib
#   MCR_CACHE_VERBOSE=1
#   export MCR_CACHE_ROOT MCR_CACHE_VERBOSE
#   make cris_all; make airs_all
#

cris_all: show_cache clean_cris chirp_cris_main
airs_all: show_cache clean_airs chirp_airs_main

chirp_cris_main:
	mcc -m -I /home/motteler/cris/ccast/source \
	-I /home/motteler/shome/airs_decon/source \
	-I ./time \
	-I ./yaml \
	-a ./ALGVERS \
	-a ./yaml/external/snakeyaml-1.9.jar \
	-a ./time/leap-seconds.list \
	chirp_cris_main.m

chirp_airs_main:
	mcc -m -I /home/motteler/cris/ccast/source \
	-I ../airs_decon/source \
	-I ./time \
	-I ./yaml \
	-a ./ALGVERS \
	-a ./time/leap-seconds.list \
	-a ./yaml/external/snakeyaml-1.9.jar \
	-a ./airs_demo_srf.hdf \
	-a ./bias_AQ_v01b.mat \
	-a ../airs_decon/source/corr_midres.mat \
	chirp_airs_main.m

run_SN: chirp_cris_main run_chirp_cris_main.sh
	./run_chirp_cris_main.sh /opt/matlab/R2020a 'chirp_SN_gran.yaml'

run_J1: chirp_cris_main run_chirp_cris_main.sh
	./run_chirp_cris_main.sh /opt/matlab/R2020a 'chirp_J1_gran.yaml'

run_AQ: chirp_airs_main run_chirp_airs_main.sh
	./run_chirp_airs_main.sh /opt/matlab/R2020a 'chirp_AQ_gran.yaml'

clean_cris:
	rm chirp_cris_main 2> /dev/null || true

clean_airs:
	rm chirp_airs_main 2> /dev/null || true

show_cache:
	echo "MCR cache root:" ${MCR_CACHE_ROOT}

version:
	git tag | tail -1 > ALGVERS

