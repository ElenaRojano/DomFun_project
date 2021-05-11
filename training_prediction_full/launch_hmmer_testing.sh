#! /usr/bin/env bash
#SBATCH --cpus=4
#SBATCH --mem=20gb
#SBATCH --time=7-00:00:00
#SBATCH --constraint=cal
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out

#module load hmmer/3.1b2
export PATH=~pedro/software/hmmer-3.3.2/installation/bin:$PATH
#path_to_files=~pedro/proyectos/domfun/hmm/testing/results_processed
#wget 'ftp://orengoftp.biochem.ucl.ac.uk/cath/releases/latest-release/sequence-data/funfam-hmm3.lib.gz'
#tar -xvzf funfam-hmm3.lib.gz
#hmmsearch -o results.txt --noali --notextw --cpu 4 --tblout domains_sequence ../funfams-4.3-seeds_wdoms.hmm /mnt/home/users/bio_267_uma/elenarojano/projects/domfun_experiments/revision/cafa_challenge_files/cafa3/Target_files/CAFA3_testing.fasta
#grep -v '#' domains_sequence | sed 's/ \+ /\t/g' > results_processed
dictionary='/mnt/home/users/bio_267_uma/elenarojano/projects/domfun_experiments/revision/cafa_challenge_files/cafa3/processed_files/accesion_geneid_dictionary.map'
results_processed='/mnt/home/users/pab_001_uma/pedro/proyectos/domfun/hmm/results_processed_nt'
#results_processed='/mnt/home/users/pab_001_uma/pedro/proyectos/domfun/hmm/testing/results_processed'
hmmer2cath.rb -m $results_processed -d $dictionary -r -e '1e-40' > cath_format_training
#hmmer2cath.rb -m $results_processed -d $dictionary -e '1e-4' > cath_format_testing
