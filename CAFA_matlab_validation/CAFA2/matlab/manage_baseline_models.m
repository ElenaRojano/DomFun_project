dir_baselines = '../baselines3'
% target_fasta = fullfile(dir_baselines, 'selected_targets.fasta')
target_fasta = fullfile(dir_baselines, 'targets.fasta')
training_fasta = fullfile(dir_baselines, 'uniprot_sprot_exp.fasta')
out_blast = fullfile(dir_baselines, 'blastp.out_rep_rep')
dir_groundtruth = '../benchmark3/groundtruth'

cmd = {'blastp -query', target_fasta, '-subject', training_fasta, '-outfmt "6 qseqid sseqid evalue length pident nident" -out', out_blast}
system(strjoin(cmd, ' ')) %the file must be edited with sh in baselines3 folder 

B = pfp_importblastp(out_blast)

oa_names = {'bpoa', 'ccoa', 'mfoa'}
ont_names = {'bpo', 'cco', 'mfo'}
for ont = 1:length(oa_names)
	folder_path = fullfile(dir_baselines, ont_names{ont})
	if ~exist(folder_path, 'dir')
		mkdir(folder_path)
	end
	load(fullfile(dir_groundtruth, strcat(oa_names{ont}, '.mat')))
	pred = pfp_blast(B.qseqid, B, oa);
	save(fullfile(folder_path, 'BB4S'), 'pred')
	pred = pfp_naive(B.qseqid, oa)
	save(fullfile(folder_path, 'BN4S'), 'pred')
end

exit
