#!/bin/bash
#
#SBATCH --account=b1134                	# Our account/allocation
#SBATCH --partition=buyin      		# 'Buyin' submits to our node qhimem0018
#SBATCH --mem=8GB
#SBATCH -t 1:00:00
#SBATCH --job-name FUNCROI
#SBATCH -o /projects/b1134/analysis/ccyr/logs/FUNCROI_%a_%A.out
#SBATCH -e /projects/b1134/analysis/ccyr/logs/FUNCROI_%a_%A.err
##########################################################################
#USAGE: sbatch /projects/b1134/tools/eeganalysis/FUNC_MAPPING/Create_FunctionalMappingResults_Table.sh
module load freesurfer
module load matlab/r2020b

matlab -batch "addpath('/projects/b1134/tools/eeganalysis/FUNC_MAPPING'); Create_FunctionalMappingResults_Table"
