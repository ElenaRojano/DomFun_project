dir_ontology = '../ontology3'
dir_groundtruth = '../benchmark3/groundtruth'
go_base_file = fullfile(dir_ontology, 'go_cafa3.obo')

onts = pfp_ontbuild(go_base_file)
ont_names = {'BPO', 'CCO', 'MFO'}
oa_names = {'bpoa', 'ccoa', 'mfoa'}
for ont = 1:length(onts)
	cur_ont = onts{ont}
	ont_name = ont_names{ont}
	annotation = strcat('leafonly_', ont_name)
	oa = pfp_oabuild(cur_ont, fullfile(dir_groundtruth, strcat(annotation, '.txt')))
	eia = pfp_eia(oa.ontology.DAG, oa.annotation);
	assignin('base', ont_name, cur_ont)
	save(fullfile(dir_ontology, ont_name), ont_name)
	save(fullfile(dir_groundtruth, oa_names{ont}), 'oa', 'eia')
end
exit
