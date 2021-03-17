cafa_system_dir = '~/projects/CAFA_validation/CAFA2_validation/CAFA2'
dir_validation = '../../eval2'
dir_consolidated = fullfile(dir_validation, 'consolidated')
dir_filtered = fullfile(dir_validation, 'filtered')
dir_prediction = fullfile(dir_validation, 'prediction')
filter_list_file = '../benchmark/lists/hpo_HUMAN_NK.txt'
config_file = '../../config2.job'
register_file = '../../register.tab'
eval_path = '../../eval2/evaluation/mfo_all_type1_mode1/hpo_HUMAN_type1_mode2/'
sample_asignation = '~/projects/CAFA_validation/CAFA2_validation/files_to_cafa2'

cafa_setup(cafa_system_dir, dir_validation)
name_asignation = table2array(readtable(sample_asignation, 'Delimiter','\t', 'ReadVariableNames',false))
for sample = 1:length(name_asignation)
	pred_file = fullfile(dir_consolidated, name_asignation{sample, 2})
	orig_file = name_asignation{sample, 1}
	cmd = sprintf('ln -s %s %s', orig_file, pred_file)
	system(cmd)
end
cafa_driver_filter(dir_consolidated, dir_filtered, filter_list_file)
load '../ontology/HPO.mat'
cafa_driver_import(dir_filtered, ...
	fullfile(dir_prediction, 'hpo'), ...
	HPO)
cafa_driver_preeval(config_file)
cafa_driver_eval(config_file)
cafa_driver_result(eval_path, register_file, 'BN4H', 'BB4H', 'all')
exit
