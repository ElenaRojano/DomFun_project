#! /usr/bin/env bash

#SBATCH --cpus=1
#SBATCH --mem=10gb
#SBATCH --time=7-00:00:00
#SBATCH --constraint=cal
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out

module unload java
module load matlab/R2015b_jvm
#module load matlab/R2017b

#rm -rf evaluation_results/eval2
cd CAFA2/matlab
matlab < ./manage_validation.m
