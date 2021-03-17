#! /usr/bin/env bash
#SBATCH --cpus=1
#SBATCH --mem=8gb
#SBATCH --time=7-00:00:00
#SBATCH --constraint=cal
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out

module load blast_plus/2.2.29+
module unload java
module load matlab/R2017b

rm -rf eval2
cd CAFA2/matlab
matlab < ./manage_baseline_models.m
