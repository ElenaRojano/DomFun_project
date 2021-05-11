#! /usr/bin/env bash
#SBATCH --cpus=1
#SBATCH --mem=4gb
#SBATCH --time=1-00:00:00
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out

source ~soft_bio_267/initializes/init_R
source ~soft_bio_267/initializes/init_autoflow

PATH="/mnt/home/users/bio_267_uma/elenarojano/dev_gem/DomFun/bin":$PATH
export PATH

#current_path=`pwd`

output_folder=$SCRATCH/DomFun/PPP/PPP_all_curC_results

cath_path=$SCRATCH/DomFun/CATH
cath_data_file=$cath_path/cath_funfams_full.tsv

domfun_path='/mnt/scratch/users/bio_267_uma/elenarojano/DomFun'
cath_data_file=$domfun_path'/CATH/cath_funfams_full.tsv' 
protein_annotations_file=$domfun_path'/PPP/data/uniprot_data/all_uniprot_data.tab'

active_annotations='kegg,reactome,gomf,gobp,gocc'
ppp_networks=$output_folder'/networks'
ppp_protein_annotations=$output_folder'/protein_annotations'
kegg_pathways_organisms=$output_folder'/kegg_files'

mkdir -p $ppp_networks
mkdir -p $ppp_protein_annotations
mkdir -p $kegg_pathways_organisms

if [ "$1" == "1" ]; then
	
	#echo 'Downloading data for curation'
	#wget 'http://current.geneontology.org/annotations/goa_uniprot_all.gaf.gz' -O $ppp_protein_annotations/goa_all.gaf.gz
	#zgrep -v $'\tIEA\t' $ppp_protein_annotations/goa_all.gaf.gz | grep -v '!' | cut -f 2,5 > $ppp_protein_annotations/curated_goa_all.gaf
	#echo 'Find curated proteins in UniProt data'
	#grep -w -F -f $ppp_protein_annotations/curated_goa_all.gaf $protein_annotations_file > $ppp_protein_annotations/curated_protein_data
	#find_curated_proteins.rb -a $protein_annotations_file -c $ppp_protein_annotations/curated_goa_all.gaf -o $ppp_protein_annotations/curated_proteins_annotations.txt 
	#cut -f 2 curated_proteins_annotations.txt | cut -d ':' -f 1 | sort -u | tail -n +2 > $kegg_pathways_organisms/kegg_organism_identifiers.txt
	#touch $kegg_pathways_organisms/kegg_ids_processed
	#echo 'Find KEGG ids by specie'
	# comm -13 $kegg_pathways_organisms/kegg_ids_processed $kegg_pathways_organisms/kegg_organism_identifiers.txt | while read -r kegg_id; do
	#   get_kegg_pathways.R $kegg_id $kegg_pathways_organisms"/"$kegg_id"_kegg_pathways.txt"
	#   if [ $? -ne 0 ]
	#   then
	#    echo "job $kegg_id failed"
	#    rm $kegg_pathways_organisms"/"$kegg_id"_kegg_pathways.txt"
	#    continue
	#   fi
	#   echo $kegg_id >> $kegg_pathways_organisms/kegg_ids_processed
	#   sleep 10
	# done

	#cat $kegg_pathways_organisms/*.txt > $kegg_pathways_organisms/all_kegg_ids.txt
	#parse_kegg_identifiers.rb -a $kegg_pathways_organisms/all_kegg_ids.txt -o $kegg_pathways_organisms/all_translated_kegg_ids.txt
	#rm goa_all.gaf.gz
	echo '1. Generating FunFam networks'

	add_protein_functional_families.rb \
	 	-a $ppp_protein_annotations/curated_proteins_annotations.txt \
	 	-d $cath_data_file \
	 	-s cath_funfam_stats.txt \
	 	-p $active_annotations \
	 	-n $ppp_networks\
	 	-o $output_folder'/cath_funfam_stats.txt'
		#--translate2gene

	translate_kegg_genes2pathways.rb \
	 	-k $kegg_pathways_organisms/all_translated_kegg_ids.txt \
	 	-n $ppp_networks/funfam_networks/network_kegg \
	 	-o $ppp_networks/funfam_networks/network_kegg_pathways	
	mv $ppp_networks/funfam_networks/network_kegg_pathways $ppp_networks/funfam_networks/network_kegg

	echo '2. Superfamily networks'
	
	add_protein_functional_families.rb \
		-a $ppp_protein_annotations/curated_proteins_annotations.txt \
		-d $cath_data_file \
		-s cath_superfamily_stats.txt \
		-n $ppp_networks\
		-p $active_annotations \
		-t 'superfamilyID' \
		-o $output_folder'/cath_superfamily_stats.txt'

	translate_kegg_genes2pathways.rb \
		-k $kegg_pathways_organisms/all_translated_kegg_ids.txt \
		-n $ppp_networks/superfamily_networks/network_kegg \
		-o $ppp_networks/superfamily_networks/network_kegg_pathways
	mv $ppp_networks/superfamily_networks/network_kegg_pathways $ppp_networks/superfamily_networks/network_kegg
fi

if [ "$1" == "2" ]; then

	mkdir -p $output_folder/associations
	validation_methods=( "kcross" )
	#validation_methods=( "no_kcross" )
	domain_types=( "funfamID" "superfamilyID" )
	#annotation_types=( "reactome" "kegg" )
	annotation_types=( "gomf" "gobp" "gocc" "kegg" "reactome" )

	for validation_method in "${validation_methods[@]}"
	do
		
		if [ $validation_methods == "kcross" ]
		then
			cuts='1-10'
			build_whole_network=false
		else
			cuts='1'
			build_whole_network=true
		fi

		for domain_class in "${domain_types[@]}"
		do

			if [ $domain_class == "funfamID" ]
			then
				domain_regex='ff'
				path_to_network=$ppp_networks'/funfam_networks'
			else
				domain_regex='[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*'
				path_to_network=$ppp_networks'/superfamily_networks'
			fi

			for annotation_type in "${annotation_types[@]}"
			do

				if [ $annotation_type == "gomf" ] || [ $annotation_type == "gobp" ] || [ $annotation_type == "gocc" ] ;
				then
					ontology_mark='GO:'
				elif [ $annotation_type == "kegg" ];
				then
					ontology_mark='path:'
				elif [ $annotation_type == "reactome" ];
				then
					ontology_mark='R-'
				fi

				execution_name=$annotation_type'_'$domain_class'_'$validation_method'_associations'
				NUMBER="[$cuts]"
				network=$path_to_network'/network_'$annotation_type
				regex=$ontology_mark
				domain_regex=$domain_regex
				build_whole_network=$build_whole_network
				annotation_name=$annotation_type
				mkdir associations
				var_info=`echo -e "\\$conn_filter=1,
					\\$network_path=$network,
					\\$regex=$regex,
					\\$methods=[jaccard;pcc;hypergeometric;simpson],
					\\$build_whole_network=$build_whole_network,
					\\$domain_regex=$domain_regex,
					\\$annotation_name=$annotation_name, 
					\\$folds=$NUMBER" |  tr -d '[:space:]' `
				AutoFlow -w templates/ppp_network_template.txt -t '7-00:00:00' -m '20gb' -c 8 -o $output_folder'/associations/'$execution_name -n 'cal' -V $var_info $2  #-u 1
			done
		done
	done
fi

if [ "$1" == "3" ]; then
	
	mkdir -p PPP_results/DomFunPredictions
	mkdir -p PPP_results/tmp

	domain_types=( "funfamID" "superfamilyID" )
	annotation_types=( "gomf" "gobp" "gocc" "kegg" "reactome" )
	association_methods=( 'hypergeometric' 'simpson' 'pcc' 'jaccard' )
	meth_roc='prec_rec'

	for domain_type in "${domain_types[@]}"
	do 
		for annotation_type in "${annotation_types[@]}"
		do 
			for association_method in "${association_methods[@]}"
			do 
				common_path="/mnt/scratch/users/bio_267_uma/elenarojano/DomFun/PPP/PPP_all_curC_results/associations"
				control_proteins=$common_path/$annotation_type"_"$domain_type"_no_kcross_associations/merge_pairs.rb_0000/"$annotation_type"_control.txt" #/merge_pairs.rb_0000/"$annotation_name"_control.txt"
				association_path=$common_path/$annotation_type"_"$domain_type"_no_kcross_associations/NetAnalyzer.rb_000*/raw/"$association_method"_values.txt"
				cat $common_path/$annotation_type"_"$domain_type"_kcross_associations/lines.R_"*"/best_thresolds.txt" > $output_folder/tmp/best_thresolds.txt
				best_threshold=`grep -w $association_method $output_folder/tmp/best_thresolds.txt | cut -f 2`
				
				if [ "$association_method" == "pcc" ]; then
					best_threshold=-1
				else
					best_threshold=0
				fi

				if [ "$association_method" == "hypergeometric" ]; then
					integration_method='fisher'
					cutoff_threshold=1
					invert_flag='true:false'
				else
					integration_method='stouffer'
					cutoff_threshold=-10000
					invert_flag='false:true'
				fi

				folder_name=$annotation_type"_"$domain_type"_"$association_method"_"$integration_method
				var_info=`echo -e "\\$association_path=$association_path,
					\\$control_proteins=$control_proteins,
					\\$domains_class=$domain_type,
					\\$best_threshold=$best_threshold,
					\\$cutoff_threshold=$cutoff_threshold,
					\\$association_method=$association_method,
					\\$integration_method=$integration_method,
					\\$meth_roc=$meth_roc,
					\\$invert_flag=$invert_flag,
					\\$path_to_cath=$cath_data_file" |  tr -d '[:space:]' `
				AutoFlow -w templates/ppp_predictor_template.txt -t '7-00:00:00' -m '2gb' -c 1 -o $output_folder'/DomFunPredictions/'$folder_name -V $var_info -n 'cal' $2 #-u 1
			done
		done
	done
fi


if [ "$1" == "4" ]; then
	echo 'Make final PPP plots to compare methods'
	mkdir -p $output_folder"/final_plots"
	#associations=( 'gobp' 'gomf' 'kegg' 'reactome' )
	#methods=( 'pcc' 'jaccard' 'simpson' )
	#domains=( 'superfamily' )
	#domain_types=( "funfamID" "superfamilyID" )
	domain_types=( "funfamID" )
	annotation_types=( "gomf" "gobp" "gocc" "kegg" "reactome" )
	association_methods=( 'simpson' 'pcc' 'jaccard' ) #hypergeometric must be treated apart
	common_path=/mnt/scratch/users/bio_267_uma/elenarojano/DomFun/CAFA3/analysis/PPP_results/DomFunPredictions

	for domain in "${domain_types[@]}"
	do 
		for method in "${association_methods[@]}"
		do 
			
			path_to_file='_'$domain'_'$method'_stouffer/domains_to_function_predictor.rb_0000/results/'$method'_pr_table.txt'
			gomf=$common_path'/gomf'$path_to_file
			gocc=$common_path'/gocc'$path_to_file
			gobp=$common_path'/gobp'$path_to_file
			kegg=$common_path'/kegg'$path_to_file
			reactome=$common_path'/reactome'$path_to_file
			#ROCanalysis.R -i $go,$gobp,$kegg,$reactome -s 'scorePred,scorePred,scorePred,scorePred' -t 'controlLabel,controlLabel,controlLabel,controlLabel' -m prec_rec -S 'gomf,gobp,kegg,reactome' -o final_plots/$domain'_'$method

			ROCanalysis.R \
			-i $gomf:$gobp:$gocc:$kegg:$reactome \
			-s 'scorePred:scorePred:scorePred:scorePred:scorePred' \
			-t 'controlLabel:controlLabel:controlLabel:controlLabel:controlLabel' \
			-S 'GOMF:GOBP:GOCC:KEGG:Reactome' \
			-m prec_rec \
			-e \
			-f png \
			-o $output_folder"/final_plots/$domain"_"$method" \
			--legendposition topright		
		done
	done

	association_methods=( 'hypergeometric' ) #hypergeometric must be treated apart

	for domain in "${domain_types[@]}"
	do 
		for method in "${association_methods[@]}"
		do 
			
			path_to_file='_'$domain'_'$method'_fisher/domains_to_function_predictor.rb_0000/results/'$method'_pr_table.txt'
			gomf=$common_path'/gomf'$path_to_file
			gocc=$common_path'/gocc'$path_to_file
			gobp=$common_path'/gobp'$path_to_file
			kegg=$common_path'/kegg'$path_to_file
			reactome=$common_path'/reactome'$path_to_file
			#ROCanalysis.R -i $go,$gobp,$kegg,$reactome -s 'scorePred,scorePred,scorePred,scorePred' -t 'controlLabel,controlLabel,controlLabel,controlLabel' -m prec_rec -S 'gomf,gobp,kegg,reactome' -o final_plots/$domain'_'$method

			ROCanalysis.R \
			-i $gomf:$gobp:$gocc:$kegg:$reactome \
			-s 'scorePred:scorePred:scorePred:scorePred:scorePred' \
			-t 'controlLabel:controlLabel:controlLabel:controlLabel:controlLabel' \
			-S 'GOMF:GOBP:GOCC:KEGG:Reactome' \
			-m prec_rec \
			-e \
			-f png \
			-o $output_folder"/final_plots/$domain"_"$method" \
			--legendposition topright		
		done
	done
fi