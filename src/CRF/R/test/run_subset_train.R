
## Usage
# Rscript run.R <train participant> <test participant> <epoch_no> <learning_rate> <training_method> <tag_only> <gibbs_sampling_rounds> <exclude_test>
# Rscript run.R SDU082 SDU082 20 1 contrasive_divergence FALSE 10 TRUE

# args = commandArgs(trailingOnly=TRUE)
# if(length(args) < 6) {
# 	stop("Insufficient arguments. Usage: Rscript run.R <train participant> <test participant> <epoch_no> <learning_rate> <training_method>")
# }

# train_participant = args[1]
# test_participant = args[2]
# no_of_epochs = as.numeric(args[3])
# learning_rate = as.numeric(args[4])
# training_method = args[5]
# tag_only = as.logical(args[6])
# gibbs_sampling_rounds = as.numeric(args[7])
# exclude_test = as.logical(args[8])

# train_participant = "all"
# test_participant = "SDU114"
no_of_epochs = 10
learning_rate = 1
training_method = "contrasive_divergence"
tag_only = FALSE
gibbs_sampling_rounds = 10

setwd('~/git/ActivityRecognition/src/CRF/R/test')
print(getwd())
source('~/git/ActivityRecognition/src/CRF/R/setup.R')

options = c('no_of_epochs' = no_of_epochs, 'learning_rate' = learning_rate, 'gibbs_sampling_rounds' = gibbs_sampling_rounds, 'training_method'=training_method)

labels = c("StandingMoving", "StandingStill","Sedentary","Walking","Biking","Vehicle")


exclude_test = TRUE

#training_participant_list=c("SDU087","SDU090", "SDU092","SDU097","SDU100","SDU102","SDU113","SDU116","SDU118")
training_participant_list=c("SDU087","SDU090", "SDU092","SDU097","SDU100","SDU102","SDU113","SDU116","SDU118","SDU086","SDU122")
for (participant in training_participant_list) {
	crf_input_file_names = c()
	excluded_participant = participant
	new_participant_list = training_participant_list[training_participant_list != excluded_participant]
	for (train_participant in new_participant_list) {
		crf_input_file_name = paste0('../../../preprocessing/R/test/results/crf_feature_','all')
		crf_input_file_name = paste0 (crf_input_file_name, '_15_seqLength_0_overlap_',train_participant)
		crf_input_file_names = append(crf_input_file_names,crf_input_file_name)
	}
	crf_model_file_name = paste0('results/crf_','subset','_model_',training_method,'_',no_of_epochs,'epochs_',learning_rate,'LR')


	if(gibbs_sampling_rounds != "NULL") {
		crf_model_file_name = paste0(crf_model_file_name,'_',gibbs_sampling_rounds,"rounds")
	}

	if(exclude_test) {
		options$excluded_participant = excluded_participant
		crf_model_file_name = paste0(crf_model_file_name,'_',excluded_participant,"excluded")
	} 
	crf_model_file_name = paste0 (crf_model_file_name, '_15_seqLength_0_overlap')


	#crf_test_file_name = paste0('../../../preprocessing/R/test/results/crf_feature_',test_participant)
	crf_test_file_name = paste0 ('../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_',excluded_participant)

	output_prediction_file_name = paste0('results/','subset','_train_',excluded_participant,'_test_',training_method,'_',no_of_epochs,'epochs_',learning_rate,'LR')
	if(gibbs_sampling_rounds != "NULL") {
		output_prediction_file_name = paste0(output_prediction_file_name,'_',gibbs_sampling_rounds,"rounds")
	}
	output_prediction_file_name = paste0 (output_prediction_file_name, '_15_seqLength_0_overlap')


	test_list = NULL
	if(!tag_only) { 
		test_list = crf_train(crf_input_file=crf_input_file_names,feature_list_file='../feature_list_all', labels=labels,crf_model_file =crf_model_file_name, options)
	}
	options$crf_sequence_length = 10
	options$overlap_window_length = 5
	crf_tag(crf_test_file_name, crf_model_file=crf_model_file_name, feature_list_file ='../feature_list_all', output_prediction_file=output_prediction_file_name, options) 


}