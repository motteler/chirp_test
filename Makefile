#
# Makefile to build chirp_main.  Do "make clean" before "make",
# there are too many dependencies to properly sort out.
# 
# The environment variable MCR_CACHE_ROOT should be set to the
# desired location for the MCR cache before running the compiled
# file, for example
# 
#   MCR_CACHE_ROOT=/home/motteler/runlib
#   MCR_CACHE_VERBOSE=1
#   export MCR_CACHE_ROOT MCR_CACHE_VERBOSE
#   make run
#

all: chirp_airs_main chirp_cris_main

chirp_cris_main:
	mcc -m -I /home/motteler/cris/ccast/source \
	-I /home/motteler/shome/airs_decon/source \
	-I ./time \
	-I /home/motteler/matlab/yaml \
	-a ./yaml/external/snakeyaml-1.9.jar \
	-a ./time/leap-seconds.list \
	chirp_cris_main.m

chirp_airs_main:
	mcc -m -I /home/motteler/cris/ccast/source \
	-I /home/motteler/shome/airs_decon/source \
	-I ./time \
	-I ./yaml \
	-a ./time/leap-seconds.list \
	-a ./yaml/external/snakeyaml-1.9.jar \
	-a ./airs_demo_srf.hdf \
	-a ./airs_bias_v01a.mat \
	chirp_airs_main.m

run_cris_main: chirp_cris_main run_chirp_cris_main.sh
	./run_chirp_cris_main.sh /opt/matlab/R2020a 'chirp_cris_gran.yaml'

run_airs_main: chirp_airs_main run_chirp_airs_main.sh
	./run_chirp_airs_main.sh /opt/matlab/R2020a 'chirp_airs_gran.yaml'

clean:
	rm chirp_cris_main 2> /dev/null || true
	rm chirp_airs_main 2> /dev/null || true

