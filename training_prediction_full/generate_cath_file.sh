#! /usr/bin/env bash

#path_to_CATH="/mnt/home/users/bio_267_uma/jperkins/software/cath-human-funfam-mda/funfams_cath_v4_3_0"
path_to_CATH="/mnt/home/users/bio_267_uma/elenarojano/projects/domfun_experiments/original_paper/ppp/networks/domains_data"
path_to_results="/mnt/scratch/users/bio_267_uma/elenarojano/DomFun/CATH"

#FULL - 43
#head -n 1 $path_to_CATH"/cath_funfams_9606.tsv" > $path_to_results"/cath_funfams_full.tsv"
#tail -n +2 $path_to_CATH/* -q | sed '/^[[:space:]]*$/d' | sed 's/""/"/g' >> $path_to_results"/cath_funfams_full.tsv"

#HUMAN - 42
sed '/^[[:space:]]*$/d' $path_to_CATH/cath_v4_2_0-human-funfam-mda.tsv | sed 's/""/"/g' > $path_to_results"/cath_42_human.tsv"