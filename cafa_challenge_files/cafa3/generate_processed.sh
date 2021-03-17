#! /usr/bin/env bash

lists_path=CAFA_assessment_tool/precrec/benchmark/CAFA3_benchmarks/lists
targets_path=Mapping_files

mkdir processed_files

ln -s ../CAFA_assessment_tool/ID_conversion/CAFA_mapping processed_files/CAFA_mapping
ln -s ../CAFA_assessment_tool/precrec/go_cafa3.obo processed_files/go.obo
ln -s ../CAFA3_training_data/uniprot_sprot_exp.txt processed_files/training_proteins.txt

grep '_HUMAN$' processed_files/accesion_geneid_dictionary.map | cut -f 1 > processed_files/human_ids
grep -w -F -f processed_files/human_ids processed_files/training_proteins.txt > processed_files/training_proteins_human.txt

cat $lists_path/*.txt | sort -u > processed_files/cafa3_targetsID_file.txt
cat $targets_path/sp_species.*.map > processed_files/cafa3_targetsID_geneIDs_file_all_organisms.txt

grep -w -F -f processed_files/cafa3_targetsID_file.txt processed_files/cafa3_targetsID_geneIDs_file_all_organisms.txt | cut -f 2 > processed_files/testing_proteins.txt

accesion_geneid_dictionary=processed_files/accesion_geneid_dictionary.map
cut -f 1,3 CAFA_assessment_tool/ID_conversion/uniprot_mapping/*map > $accesion_geneid_dictionary
tail -q -n +2 CAFA_assessment_tool/ID_conversion/uniprot_mapping/*tab >> $accesion_geneid_dictionary
