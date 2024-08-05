#!/bin/bash
#
#SBATCH --account=b1134                	# Our account/allocation
#SBATCH --partition=buyin      		# 'Buyin' submits to our node qhimem0018
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=24GB
#SBATCH -t 12:00:00
#SBATCH --job-name FWHM
#SBATCH -o /projects/b1134/analysis/ccyr/logs/FWHM_%a_%A.out
#SBATCH -e /projects/b1134/analysis/ccyr/logs/FWHM_%a_%A.err
##########################################################################

module load matlab/r2020b
matlab -batch "addpath('/projects/b1134/tools/eeganalysis/STIM'); ListeningZone_run('$1')"
