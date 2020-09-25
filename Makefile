#
# Makefile to build and test chirp_airs_main and chirp_cris_main
#
# "make cris_all" and "make airs_all" compiles chirp_airs_main and
# chirp_cris_main.  The git version is saved to the file ALGVERS.
# This is made part of the deployable archive, and used to set the
# global attribute "algorithm_version".
#
# The environment variable MCR_CACHE_ROOT should be set to the
# desired location for the MCR cache before running the compiled
# file, for example
# 
#   MCR_CACHE_ROOT=/home/motteler/runlib
#   export MCR_CACHE_ROOT 
#   make run_SN
#

cris_all: clean_cris version chirp_cris_main
airs_all: clean_airs version chirp_airs_main

chirp_cris_main:
	mcc -m -I /home/motteler/cris/ccast/source \
	-I /home/motteler/shome/airs_decon/source \
	-I ./time \
	-I ./yaml \
	-a ./ALGVERS \
	-a ./yaml/external/snakeyaml-1.9.jar \
	-a ./time/leap-seconds.list \
	-a ./bias_j1_v01a.mat \
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
	-a ./bias_aq_v01c.mat \
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

