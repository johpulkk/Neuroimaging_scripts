#!/bin/bash

# This is a bash script to Z normalize (https://en.wikipedia.org/wiki/Standard_score) 
# VBM data using control data as a reference using FSL tools
# Author: Johannes Lieslehto 13th of July 2019

# Before running the script, make sure you have:
# 1. Run preprocessing pipeline in (e.g., CAT12) beforehand for each subject
# 2. Grouped each subject into either "Controls" or "Schizophrenia" folders

# Run this script in the directory where the preprocessed 
# Controls and Schizophrenia directories are located
workingDir=$(pwd)

mkdir HC_Znormalized
mkdir HC_Znormalized/Controls
mkdir HC_Znormalized/Schizophrenia

echo Calculating mean and sd using control VBM maps
fslmerge -t $workingDir/controls $workingDir/Controls/*.nii
fslmaths $workingDir/controls -Tmean $workingDir/controls_mean
fslmaths $workingDir/controls -Tstd $workingDir/controls_sd

for group in Controls Schizophrenia
do
echo normalizing "$group"

for subject in `ls -1d "$workingDir"/"$group"/*.nii`
do
subj_name=$(basename ${subject} .nii)

fslmaths $subject -sub $workingDir/controls_mean $workingDir/HC_Znormalized/"$group"/"$subj_name"_subs
fslmaths $workingDir/HC_Znormalized/"$group"/"$subj_name"_subs -div $workingDir/controls_sd $workingDir/HC_Znormalized/"$group"/"$subj_name"_normalized


done
# Gunzip the files
gunzip -f "$workingDir"/HC_Znormalized/"$group"/*_normalized.nii.gz
rm -f "$workingDir"/HC_Znormalized/"$group"/*.nii.gz
done


