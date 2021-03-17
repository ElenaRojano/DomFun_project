#! /usr/bin/env bash

mkdir processed_files
ln -s ../Supplementary_data/data/ontology/go_20130615-termdb.obo processed_files/go.obo
tail -n +2 cf2_uniprot_data.txt | cut -f 2,3 > processed_files/accesion_geneid_dictionary.map
find Supplementary_data/data/*-t0 -iname "*MFO" -exec cat {} \; | sort -u | awk '{print $1 "\t" $2 "\tF"}' > processed_files/training_proteins.txt
find Supplementary_data/data/*-t0 -iname "*BPO" -exec cat {} \; | sort -u | awk '{print $1 "\t" $2 "\tP"}' >> processed_files/training_proteins.txt
find Supplementary_data/data/*-t0 -iname "*CCO" -exec cat {} \; | sort -u | awk '{print $1 "\t" $2 "\tC"}' >> processed_files/training_proteins.txt

grep '_HUMAN$' processed_files/accesion_geneid_dictionary.map | cut -f 1 > processed_files/human_ids
grep -w -F -f processed_files/human_ids processed_files/training_proteins.txt > processed_files/training_proteins_human.txt

cat Supplementary_data/data/benchmark/lists/*txt | sort -u > processed_files/all_bench_targets
grep -h '>' Supplementary_data/data/CAFA2-targets/*/*.tfa | tr -d '>' > processed_files/tgID_geID
grep -F -f processed_files/all_bench_targets processed_files/tgID_geID | cut -f 2 -d ' ' > processed_files/testing_proteins.txt
mkdir processed_files/CAFA_mapping
cd processed_files/CAFA_mapping
find ../../Supplementary_data/data/CAFA2-targets/ -iname *.tfa -exec sh -c 'grep ">" {} | tr -d ">" | tr " " "\t" > `basename {}`.map' \;
