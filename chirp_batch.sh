#!/bin/bash
#
# NAME
#   chirp_batch -- run chirp trans on doy = job array ID
#
# SYNOPSIS
#   sbatch --array=<doy list> chirp_batch.sh <src> <year>
#
# src values include
#   AIRS_L1c, CCAST_NPP, CCAST_J01, UW_NPP, UW_J01
#

# sbatch options
#SBATCH --job-name=chirp
# #SBATCH --partition=batch
# #SBATCH --constraint=hpcf2009
#SBATCH --constraint=lustre
#SBATCH --partition=high_mem
#SBATCH --qos=medium+
# #SBATCH --qos=normal+
#SBATCH --account=pi_strow
#SBATCH --mem-per-cpu=20000
#SBATCH --oversubscribe
# #SBATCH --exclusive

# exclude list
# #SBATCH --exclude=cnode[106]

# matlab options
MATLAB=/usr/ebuild/software/MATLAB/2020a/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

srun --output=$1_%A_%a.out \
   $MATLAB $MATOPT -r "chirp_batch('$1', $2); exit"

