#! /usr/bin/env bash

PATH=~elenarojano/dev_gem/DomFun/bin:$PATH
export PATH

rm temp/filenames
rm temp/predictionNames
#rm -rf prediction_values

domains_classes=( 'funfam' 'superfamily' )
association_methods=( 'hypergeometric' 'pcc' 'jaccard' 'simpson' )
counter=1

pred_folder=prediction_values_CAFA3_human
mkdir $pred_folder
#cafa_results=$SCRATCH/DomFun/cafa/CAFA3_all_curC_results
#cafa_results=$SCRATCH/DomFun/cafa/CAFA3_human_oldC_results

cafa_results=$SCRATCH/DomFun/cafa/CAFA3_all_curC_results
#cafa_results=$SCRATCH/DomFun/cafa/CAFA3_human_curC_results
## CHANGE BELOW assessment_dir=$cafa_system/evaluation_results/eval_CAFA2_human
#cafa_results=$SCRATCH/DomFun/cafa/CAFA2_all_curC_results
#cafa_results=$SCRATCH/DomFun/CAFA3/analysis/CAFA3_results
#organism='all'
organism='all'
temp_files=$cafa_results/temp_files
accesion_geneid_dictionary=$temp_files/accesion_geneid_dictionary.map
targetID_geneid_dictionary=$temp_files/targetID_geneid_dictionary.map
predictions_path=$cafa_results/DomFunPredictions
predictions_folder="normalize_combined_scores.rb_0000"

for domains_class in "${domains_classes[@]}"
do 
	for association_method in "${association_methods[@]}"
	do 
		if [ "$association_method" == "hypergeometric" ]; then
			combination_methods=( 'fisher' )
			
			for combination_method in "${combination_methods[@]}"
			do
				predictions=$predictions_path"/GO*_"$association_method"_"$domains_class"ID_predictions/"$predictions_folder"/normalized_predictions.txt"
				#echo $predictions
				generate_CAFA2_dataset.rb \
				-a "$predictions" \
				-m "CAFA3" \
				-g $accesion_geneid_dictionary\
				-t $targetID_geneid_dictionary\
				-o $pred_folder"/GOALL_"$domains_class"_"$association_method"_"$combination_method"_M00"$counter 
				
				counter=$((counter+1))
				wait
			done
		else
			combination_methods=( 'stouffer' ) 
			for combination_method in "${combination_methods[@]}"
			do
				predictions=$predictions_path"/GO*_"$association_method"_"$domains_class"ID_predictions/"$predictions_folder"/normalized_predictions.txt"
				#echo $predictions
				generate_CAFA2_dataset.rb \
				-a "$predictions" \
				-m "CAFA3" \
				-g $accesion_geneid_dictionary\
				-t $targetID_geneid_dictionary\
				-o $pred_folder"/GOALL_"$domains_class"_"$association_method"_"$combination_method"_M00"$counter 
				
				counter=$((counter+1))
				wait
			done
		fi
	done
done

fullpath=`realpath $pred_folder/`

find $pred_folder/ -type f -printf "%f\n" | while read FILE
do
    # modify line below to do what you need, then remove leading "echo" 
    echo -e $fullpath"/"$FILE >> temp/filenames
    echo ${FILE:(-4)} >> temp/predictionNames
done

paste temp/filenames temp/predictionNames > evaluation_configs/files_to_cafa
cafa_system='/mnt/home/users/bio_267_uma/elenarojano/projects/domfun_experiments/revision/CAFA_matlab_validation'
cafa_path=$cafa_system/CAFA2 #evaluation path (do not change!)
config_path=$cafa_system/evaluation_configs
#assessment_dir=$cafa_system/evaluation_results/eval_curCAFA3_all
assessment_dir=$cafa_system/evaluation_results/eval_curCAFA3_all
mkdir $assessment_dir
create_CAFA_config_file.rb -a $assessment_dir -c $cafa_path -g mfo,bpo,cco -o $config_path/config2_ -s files_to_cafa -f ontology3 -B benchmark3 -b 1 -e 1 -t $organism