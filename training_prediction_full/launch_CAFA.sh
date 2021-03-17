#! /usr/bin/env bash
#SBATCH --cpus=1
#SBATCH --mem=4gb
#SBATCH --time=1-00:00:00
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out

source ~soft_bio_267/initializes/init_R
source ~soft_bio_267/initializes/init_autoflow

PATH=~elenarojano/dev_gem/DomFun/bin:$PATH
export PATH

current_path=`pwd`

output_folder=$SCRATCH/DomFun/cafa/CAFA3_all_curC_results
#output_folder=$SCRATCH/DomFun/cafa/CAFA3_human_oldC_results
#output_folder=$SCRATCH/DomFun/cafa/CAFA3_human_curC_results
#output_folder=$SCRATCH/DomFun/cafa/CAFA2_all_curC_results
#output_folder=$SCRATCH/DomFun/cafa/CAFA2_human_curC_results # no es current, sino old

cath_path=$SCRATCH/DomFun/CATH
cath_file=$cath_path/cath_funfams_full.tsv
#cath_file=$cath_path/cath_42_human.tsv

#cafa_data_path=~/projects/domfun_experiments/revision/cafa_challenge_files/cafa2/processed_files
cafa_data_path=~/projects/domfun_experiments/revision/cafa_challenge_files/cafa3/processed_files

training_proteins_full_list=$cafa_data_path/training_proteins.txt
#training_proteins_full_list=$cafa_data_path/training_proteins_human.txt

cafa_obo=$cafa_data_path/go.obo
path_to_CAFA_mapping=$cafa_data_path"/CAFA_mapping"
path_to_uniprot_mapping=$cafa_data_path"/accesion_geneid_dictionary.map"

mkdir -p $cafa_data_path"/training_proteins"
awk 'BEGIN {OFS = FS} { if ($3=="C") print $1"\t"$2 }' $training_proteins_full_list > $cafa_data_path"/training_proteins/training_prots_GOCC"
awk 'BEGIN {OFS = FS} { if ($3=="P") print $1"\t"$2 }' $training_proteins_full_list > $cafa_data_path"/training_proteins/training_prots_GOBP"
awk 'BEGIN {OFS = FS} { if ($3=="F") print $1"\t"$2 }' $training_proteins_full_list > $cafa_data_path"/training_proteins/training_prots_GOMF"

mkdir -p $output_folder/networks/CAFA_networks
mkdir -p $output_folder/associations
mkdir -p $output_folder/temp_files
mkdir -p $output_folder/DomFunPredictions

ln -s $path_to_uniprot_mapping $output_folder/temp_files/accesion_geneid_dictionary.map
targetID_geneid_dictionary=$output_folder/temp_files/targetID_geneid_dictionary.map
cat $path_to_CAFA_mapping"/sp_species"*".map" > $targetID_geneid_dictionary


domain_types=( "funfamID" "superfamilyID" )
annotation_types=( "GOCC" "GOMF" "GOBP" )

if [ "$1" == "1" ]; then

	echo 'Preparing CAFA tripartite network'

	for domain_class in "${domain_types[@]}"
	do

		if [ $domain_class == "funfamID" ]
		then
			domain_regex='ff'
		else
			domain_regex='[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*'
		fi

		for annotation_type in "${annotation_types[@]}"
		do
			training_proteins=$cafa_data_path"/training_proteins/training_prots_"$annotation_type
			echo $cath_file
			echo $output_folder/temp_files/$annotation_type'_CATH_proteins_domains.txt'
			cut -f 1 $training_proteins | sort -u > $output_folder/temp_files/$annotation_type'_training_proteins_list.txt'		
			cut -f 1,6,7 $cath_file | grep -w -F -f $output_folder/temp_files/$annotation_type'_training_proteins_list.txt' | sed 's/"//g'> $output_folder/temp_files/$annotation_type'_CATH_proteins_domains.txt'

			generate_CAFA_tripartite_network.rb \
			-a $output_folder/temp_files/$annotation_type'_CATH_proteins_domains.txt' \
			-b $training_proteins \
			-d $domain_class \
			-o $output_folder/networks/CAFA_networks/$domain_class"_"$annotation_type"_tripartite_network.txt"	
			
			execution_name=$annotation_type'_associations_'$domain_class
			regex='GO:'
			domain_regex=$domain_regex
			network=$output_folder/networks/CAFA_networks/$domain_class"_"$annotation_type"_tripartite_network.txt"
			var_info=`echo -e "\\$network_path=$network,
			\\$regex=$regex,
			\\$domain_regex=$domain_regex,
			\\$path_to_cath=$cath_file,
			\\$methods=[jaccard;pcc;hypergeometric;simpson]" |  tr -d '[:space:]' `
			echo $var_info
			AutoFlow -w templates/domains_network_template_for_CAFA.txt -t '7-00:00:00' -m '20gb' -c 2 -o $output_folder"/associations/"$execution_name -n 'cal' -V $var_info $2  #-u 1
		done
	done
fi


if [ "$1" == "2" ]; then

	echo 'DomFun prediction:'

	testing_proteins=$cafa_data_path/testing_proteins.txt #testing corregido: 3089 proteinas

	#testing_proteins=$output_folder/temp_files/testing_proteins.map
	#cut -f 2 $targetID_geneid_dictionary > $testing_proteins #esto es raro, predices para todo el diccionario q tb incluira testing, pero haces preds para el training	
	#association_methods=( 'jaccard' )
	association_methods=( 'hypergeometric' 'pcc' 'jaccard' 'simpson' )
	#domain_types=( "funfamID" )
	domain_types=( "funfamID" "superfamilyID" )
	#annotation_types=( "GOCC" )
	annotation_types=( "GOCC" "GOMF" "GOBP" )
	
	echo 'Preparing files for predicion:'
	common_path=$output_folder/associations
	for annotation_type in "${annotation_types[@]}"
	do
		for domain_type in "${domain_types[@]}"
		do
			for association_method in "${association_methods[@]}"
			do
		        association_path=$common_path"/"$annotation_type"_associations_"$domain_type"/NetAnalyzer.rb_000*/raw/"$association_method"_values.txt"
		        if [ "$association_method" == 'hypergeometric' ]; then
		                integration_method='fisher'
		                #prediction_threshold=1
		        else
		                integration_method='stouffer'
		                #prediction_threshold=-10000
		        fi

		        # if [ "$association_method" == 'PCC' ] ; then
		        #         association_threshold=-1
		        # else
		        #         association_threshold=0
		        # fi

		        execution_name=$annotation_type"_"$association_method"_"$domain_type"_predictions"
		        # \\$association_threshold=$association_threshold,
		        # \\$prediction_threshold=$prediction_threshold,

				var_info=`echo -e "\\$path_to_cath=$cath_file,
				        \\$testing_proteins=$testing_proteins,
						\\$association_path=$association_path,
				        \\$domains_class=$domain_type,
				        \\$annotation_type=$annotation_type,
				        \\$association_method=$association_method,
				        \\$integration_method=$integration_method,
				        \\$accesion_geneid_dictionary=$path_to_uniprot_mapping,
				        \\$targetID_geneid_dictionary=$targetID_geneid_dictionary" |  tr -d '[:space:]' `
				AutoFlow -w templates/predictor_template.txt -t '01:00:00' -m '20gb' -c 8 -e -o $output_folder'/DomFunPredictions/'$execution_name -V $var_info -n 'cal' $2 #-u 1
				#LOGIN
				#AutoFlow -w templates/predictor_template.txt -t '01:00:00' -m '20gb' -c 2 -e -o $output_folder'/DomFunPredictions/'$execution_name -V $var_info -n 'cal' $2 #-u 1
			done
		done
	done	
fi

