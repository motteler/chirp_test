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

chirp_main:
	mcc -m -I /home/motteler/cris/ccast/source \
	-I /home/motteler/shome/airs_decon/source \
	-I ./time \
	-I ./yaml \
	-a ./time/leap-seconds.list \
	-a ./yaml/external/snakeyaml-1.9.jar \
	chirp_main.m

clean:
	rm chirp_main 2> /dev/null || true

run: chirp_main run_chirp_main.sh
	./run_chirp_main.sh /opt/matlab/R2020a 'SN' 'chirp_cris_gran.yaml'

# run: chirp_main
#	./run_chirp_main.sh /usr/ebuild/software/MATLAB/2020a \
#	'SN' 'chirp_cris_gran.yaml'


