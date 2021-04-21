#! /usr/bin/env bash

#Tool to analyze datasets and calculate information loss

source ~soft_bio_267/initializes/init_ruby
PATH="/mnt/home/users/bio_267_uma/elenarojano/dev_gem/DomFun/bin":$PATH
export PATH

dictionary=/mnt/home/users/bio_267_uma/elenarojano/projects/domfun_experiments/revision/cafa_challenge_files/cafa2/processed_files/accesion_geneid_dictionary.map

#metrics_report.rb -i stats_input_file.txt -d $dictionary
metrics_report.rb -i stats_input_file_cafa3_cur_cath.txt -d $dictionary -F cafa3_cur_cath_stats.html
exit




# #PATH TO FILES
# current_path=`pwd`
# training_proteins=../cafa_challenge_files/cafa3/processed_files/training_proteins.txt

# mkdir -p tests

# files_path="/mnt/home/users/bio_267_uma/elenarojano/projects/domfun_experiments/revision/cafa_challenge_files"
# original_targets_files_path=$files_path"/cafa3/Mapping_files"
# testing_proteins=$files_path"/cafa3/processed_files/testing_proteins.txt"
# cath_path="$SCRATCH/DomFun/CATH/cath_funfams_full.tsv"
# #species=( 'ARATH' 'BACSU' 'DANRE' 'DICDI' 'ECOLI' 'HELPY' 'HUMAN' 'METJA' 'MOUSE' 'MYCGE' 'PSEPK' 'PSESM' 'RAT' 'SALCH' 'SALTY' 'SCHPO' 'STR' )
# training_proteins_path=$files_path"/cafa3/processed_files/training_proteins.txt"
# cut -f 1 $training_proteins_path | sort -u > $current_path"/temp_files/list_of_training_proteins.txt"
# training_proteins=$current_path"/temp_files/list_of_training_proteins.txt"
# #cut -f 1,5,6 $cath_path | tail -n +2 | sed 's/"//g' > tests/cath_genes_sf.txt
# #cut -f 1,5,7 $cath_path | tail -n +2 | sed 's/"//g' > tests/cath_genes_ff.txt

# metrics_report.rb -a $cath_path -b $testing_proteins -c $training_proteins -o tests/output_superfamily_stats.txt
# metrics_report.rb -a $cath_path -b $testing_proteins -c $training_proteins -d funfamID -o tests/output_funfams_stats.txt
# exit



#rm tests/report.txt

#Get protein ids from testing_geneIDs using CATH info (to translate):
#grep -w -F -f $testing_proteins $cath_path | cut -f 1 | sort -u | sed 's/"//g' > tests/list_of_proteins.txt

#Get protein ids excluded (not found in CATH):
#grep -w -F -f $testing_proteins $cath_path | cut -f 5 | sort -u | sed 's/"//g' > tests/list_of_geneIDs.txt
#grep -w -v -F -f tests/list_of_geneIDs.txt $testing_proteins | sort -u | > tests/targets_geneIDs_not_found.txt


# target_proteins=`wc -l $testing_proteins`
# cafa3_targets_with_sf=`grep -w -F -f $testing_proteins tests/cath_genes_sf.txt | sort -u`

# touch tests/report.txt

# target_with_domains=`wc -l tests/list_of_proteins.txt`
# targets_not_found_CATH=`wc -l tests/targets_geneIDs_not_found.txt`

# x=`echo "12+5" | bc`


# echo "Target proteins: "$target_proteins >> tests/report.txt
# echo "Target proteins with domains in CATH: "$target_with_domains >> tests/report.txt
# echo "Target identifiers not found: "$targets_not_found_CATH >> tests/report.txt
# echo "-----------------------" >> tests/report.txt
# echo "Analysis by species" >> tests/report.txt
# echo "-----------------------" >> tests/report.txt

# for specie in "${species[@]}"	
# do
# 	total_proteins=`grep $specie $original_targets_files_path/* | wc -l`
# 	proteins_found=`grep $specie tests/list_of_geneIDs.txt | wc -l`
# 	proteins_lost=`grep $specie tests/targets_geneIDs_not_found.txt | wc -l`
# 	echo "Total proteins for $specie in CAFA 3 targets:" $total_proteins >> tests/report.txt
# 	echo "Proteins found for $specie in CATH:" $proteins_found >> tests/report.txt
# 	echo "Proteins not found for $specie in CATH:" $proteins_lost >> tests/report.txt
# 	echo "#-------" >> tests/report.txt
# 	grep $specie tests/targets_geneIDs_not_found.txt > "tests/proteins_lost/"$specie"_proteins_lost.txt"

# done
