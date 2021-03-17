%cafa_system_dir = '/mnt/home/users/bio_267_uma/elenarojano/projects/CAFA_validation/CAFA2_validation/CAFA2'
%dir_validation = '/mnt/home/users/bio_267_uma/elenarojano/projects/CAFA_validation/CAFA2_validation/evaluation_results/eval_CAFA2'
%ontology_folder = '/mnt/home/users/bio_267_uma/elenarojano/projects/CAFA_validation/CAFA2_validation/CAFA2/ontology'
%dir_evaluation_configs = '/mnt/home/users/bio_267_uma/elenarojano/projects/CAFA_validation/CAFA2_validation/evaluation_configs'
%register_file = 'register.tab'
%sample_asignation = 'files_to_cafa'

%cafa_system_dir = '~/projects/CAFA_validation/CAFA2_validation/CAFA2'
%dir_validation = '../../evaluation_results/eval2'
%ontology_folder = '../ontology'
%dir_evaluation_configs = '../../evaluation_configs'
%% dir_prediction = fullfile(dir_validation, 'prediction', 'mfo') %config.pred_dir
%% filter_list_file = '../benchmark/lists/mfo_HUMAN_LK.txt' %config.benchmark
%% eval_path = fullfile(dir_validation, 'evaluation/mfo_all_type1_mode1/mfo_HUMAN_type2_mode2/') %config.eval_dir

settings = fileread('./general_variables.txt')
eval(settings)
%register_file = fullfile(dir_evaluation_configs, 'register.tab')
register_file = fullfile(dir_evaluation_configs, register_file)
%sample_asignation = fullfile(dir_evaluation_configs, 'files_to_cafa2')
sample_asignation = fullfile(dir_evaluation_configs, sample_asignation)
dir_consolidated = fullfile(dir_validation, 'consolidated')
dir_filtered = fullfile(dir_validation, 'filtered')


cafa_setup(cafa_system_dir, dir_validation)
name_asignation = table2array(readtable(sample_asignation, 'Delimiter','\t', 'ReadVariableNames',false))
for sample = 1:length(name_asignation)
	pred_file = fullfile(dir_consolidated, name_asignation{sample, 2})
	orig_file = name_asignation{sample, 1}
	cmd = sprintf('ln -s %s %s', orig_file, pred_file)
	system(cmd)
end

ontologies = strsplit(ontologies, ',')
config_files = strsplit(config_files, ',')
%% LOOP
for ind = 1:length(ontologies)
	ontology = ontologies{ind}
	config_file = config_files{ind}
	config_file = fullfile(dir_evaluation_configs, config_file)
	config = cafa_parse_config(config_file)
	cafa_driver_filter(dir_consolidated, dir_filtered, config.bm)
	ont = load(fullfile(ontology_folder, strcat(ontology, '.mat')))
	cafa_driver_import(dir_filtered, config.pred_dir, ont.(ontology))
	cafa_driver_preeval(config_file) % Can process the config object but changes its behaviour (only parse baseline models when struct is used)
	cafa_driver_eval(config_file)
	cafa_driver_result(config.eval_dir, register_file, 'BN4S', 'BB4S', 'all')
end
exit
