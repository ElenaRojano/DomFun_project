#! /usr/bin/env bash

PATH=~elenarojano/dev_gem/DomFun/bin:$PATH
export PATH

rm temp/filenames
rm temp/predictionNames
#rm -rf prediction_values

domains_classes=( 'funfam' 'superfamily' )
association_methods=( 'hypergeometric' 'pcc' 'jaccard' 'simpson' )
counter=1

if [ "$1" == "1" ]; then # ORIGINAL PAPER
	mkdir prediction_values
	cafa_data="/mnt/home/users/bio_267_uma/elenarojano/projects/domfun_experiments/old_experiment/gold_standard/CAFA_GO_UNIPROT_ACC.txt"
	#cafa_data="/mnt/home/users/bio_267_uma/elenarojano/projects/CAFA_validation/gold_standard/CAFA_GO_UNIPROT_ACC.txt"
	predictions_path="/mnt/home/users/bio_267_uma/elenarojano/projects/domfun_experiments/original_paper/CAFA2/DomFunPredictions"
	#predictions_path="/mnt/home/users/bio_267_uma/elenarojano/projects/TripartiteCAFA2/DomFunPredictions"
	predictions_folder="domains_to_function_predictor.rb_0000/results"
	
	for domains_class in "${domains_classes[@]}"
	do 
		for association_method in "${association_methods[@]}"
		do 
			if [ "$association_method" == "hypergeometric" ]; then
				combination_methods=( 'fisher' )
				
				for combination_method in "${combination_methods[@]}"
				do
					predictions=$predictions_path"/go*_"$domains_class"_"$association_method"_"$combination_method"/"$predictions_folder"/normalized_predictions.txt"
					generate_CAFA2_dataset.rb \
					-a "$predictions" \
					-c $cafa_data \
					-o prediction_values/"GOALL_"$domains_class"_"$association_method"_"$combination_method"_M00"$counter 
					
					counter=$((counter+1))
					wait
				done
			else
				combination_methods=( 'stouffer' ) 
				for combination_method in "${combination_methods[@]}"
				do
					predictions=$predictions_path"/go*_"$domains_class"_"$association_method"_"$combination_method"/"$predictions_folder"/normalized_predictions.txt"
					#predictions=$predictions_path"/"$annotation_name"_"$domains_class"_"$association_method"_"$combination_method"/"$predictions_folder"/prediction_results.txt"
					generate_CAFA2_dataset.rb \
					-a "$predictions" \
					-c $cafa_data \
					-o prediction_values/"GOALL_"$domains_class"_"$association_method"_"$combination_method"_M00"$counter
					
					counter=$((counter+1))
					wait
				done
			fi
			#cat `echo -e prediction_values/$annotation_name"_"$domains_class"_"$association_method"_"$combination_method"_M00"$counter ' \t ' "M00"$counter` >> evaluation_configs/files_register.txt
		done
	done

	fullpath=`realpath prediction_values/`

	find prediction_values/ -type f -printf "%f\n" | while read FILE
	do
	    # modify line below to do what you need, then remove leading "echo" 
	    echo -e $fullpath"/"$FILE >> temp/filenames
	    echo ${FILE:(-4)} >> temp/predictionNames
	done

	paste temp/filenames temp/predictionNames > evaluation_configs/files_to_cafa

	cafa_system='/mnt/home/users/bio_267_uma/elenarojano/projects/domfun_experiments/revision/CAFA_matlab_validation'
	cafa_path=$cafa_system/CAFA2
	config_path=$cafa_system/evaluation_configs
	assessment_dir=$cafa_system/evaluation_results/eval_CAFA2
	mkdir $assessment_dir
	create_CAFA_config_file.rb -a $assessment_dir -c $cafa_path -g mfo,bpo,cco -o $config_path/config2_ -s files_to_cafa -f ontology -B benchmark -b 2 -e 2 -t HUMAN

fi

if [ "$1" == "2" ]; then #REWORK
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
fi


