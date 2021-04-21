#! /usr/bin/env bash

#Path to files to process:

#processed_data_path="/mnt/home/users/bio_267_uma/elenarojano/projects/domfun_experiments/revision/cafa_challenge_files/cafa3/processed_files"
#cafa3_training_file=$processed_data_path/training_proteins.txt

source ~soft_bio_267/initializes/init_ruby
PATH="/mnt/home/users/bio_267_uma/elenarojano/dev_gem/DomFun/bin":$PATH
export PATH

metric_report.rb -i stat_files_path.txt 
