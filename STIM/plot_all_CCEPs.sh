#!/bin/bash
#
#SBATCH --array=0-50 ## number of jobs to run "in parallel"
#SBATCH --account=b1134                	# Our account/allocation
#SBATCH --partition=buyin      		# 'Buyin' submits to our node qhimem0018
#SBATCH --mem=8GB
#SBATCH -t 00:05:00
#SBATCH --job-name PreprocQC
#SBATCH -o /projects/b1134/processed/eegqc/logs/preprocoutput_%a_%A.out
#SBATCH -e /projects/b1134/processed/eegqc/logs/preprocoutput_%a_%A.err
##########################################################################
#Braga Lab EEG QC Master Script
#Created by Chris Cyr September 2022
#creates post-preprocessing QC documents for all stim runs that have already been preprocessed. 
#Skips runs that already have the output document from this script
#Usage:
#sbatch /projects/b1134/tools/eeganalysis/STIM/plot_all_CCEPs.sh

##########################################################################

module load matlab/r2020b
#module load fftw/3.3.3-gcc
module load R/4.0.3

echo "Checking for processed iEEG Stimulation runs"

OLDIFS=$IFS

#search for preprocessed stim data
directories=$(ls -d  /projects/b1134/processed/ieeg_stim/*/*/*/*/*/*/*z_flip.mat 2> /dev/null)
directory_list=(${directories// / })
if (( $SLURM_ARRAY_TASK_ID > ${#directory_list[@]} )); then
    echo "This array ID is unused because it exceeds the number of EEG directories."
    exit
else
	i=${directory_list[$SLURM_ARRAY_TASK_ID]}
fi

#extract file information
IFS='/'
read -a fileinfo <<< "$i"
end=${#fileinfo[*]}
ProjectID=${fileinfo[$end-7]}
SubjectID=${fileinfo[$end-6]}
SessionID=${fileinfo[$end-5]}
TaskID=${fileinfo[$end-4]}
StimID=${fileinfo[$end-3]}
CurrentID=${fileinfo[$end-2]}

OUTPATH="/projects/b1134/processed/ieeg_stim/$ProjectID/$SubjectID/$SessionID/$TaskID/$StimID/$CurrentID"
IFS=$OLDIFS

#check if output document already exists
#if [ ! -e $OUTPATH/${SubjectID}_${SessionID}_${TaskID}_${StimID}_${CurrentID}_preprocoutput.pdf ]; then

echo Creating new document at $OUTPATH
matlab -batch "addpath('/projects/b1134/tools/eeganalysis/STIM'); plot_all_CCEPs('$OUTPATH')"
Rscript  /projects/b1134/tools/eeganalysis/STIM/plot_all_CCEPs.R $OUTPATH

#fi

