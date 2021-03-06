
## Usage
# Rscript run.R <train participant> <test participant> <epoch_no> <learning_rate> <training_method> <tag_only> <gibbs_sampling_rounds> <exclude_test>
# Rscript run.R SDU082 SDU082 20 1 contrasive_divergence FALSE 10 TRUE

args = commandArgs(trailingOnly=TRUE)
if(length(args) < 9) {
	stop("Insufficient arguments. Usage: Rscript run.R <train participant> <test participant> <epoch_no> <learning_rate> <training_method>")
}

train_participant = args[1]
test_participant = args[2]
no_of_epochs = as.numeric(args[3])
learning_rate = as.numeric(args[4])
training_method = args[5]
tag_only = as.logical(args[6])
gibbs_sampling_rounds = as.numeric(args[7])
reg_method = args[8]
reg_constant = as.numeric(args[9])
exclude_test = as.logical(args[10])

# train_participant = "all"
# test_participant = "SDU114"
# no_of_epochs = 1
# learning_rate = 1
# training_method = "contrasive_divergence"
# tag_only = FALSE
# gibbs_sampling_rounds = 10

setwd('~/git/ActivityRecognition/src/CRF/R/test')
print(getwd())
source('~/git/ActivityRecognition/src/CRF/R/setup.R')
source('~/git/ActivityRecognition/src/CRF/R/test/find_accuracy.R')

avg_acc_file = 'loo_results_2'
#cat("participant,epochs,lr,reg_method,reg_constant,avg_acc\n",file=avg_acc_file,append=TRUE)

#options = c('no_of_epochs' = no_of_epochs, 'learning_rate' = learning_rate, 'gibbs_sampling_rounds' = gibbs_sampling_rounds, 'training_method'=training_method)
options = c('no_of_epochs' = no_of_epochs, 'learning_rate' = learning_rate, 'gibbs_sampling_rounds' = gibbs_sampling_rounds, training_method=training_method, overlap_window_length = 0, crf_sequence_length=15,
          regularization_constant = reg_constant , regularization_method = reg_method)
labels = c("StandingMoving", "StandingStill","Sedentary","Walking","Biking","Vehicle")

crf_input_file_name = paste0('../../../preprocessing/R/test/results/crf_feature_',train_participant)
crf_input_file_name = paste0 (crf_input_file_name, '_15_seqLength_0_overlap')
crf_model_file_name = paste0('results/crf_',train_participant,'_model_',training_method,'_',no_of_epochs,'_epochs_',learning_rate,'_LR_',reg_method, '_reg_method_', reg_constant, '_reg_constant')


if(gibbs_sampling_rounds != "NULL") {
	crf_model_file_name = paste0(crf_model_file_name,'_',gibbs_sampling_rounds,"rounds")
}

if(train_participant == "all" && exclude_test) {
	options$excluded_participant = test_participant
	crf_model_file_name = paste0(crf_model_file_name,'_',test_participant,"excluded")
} 
crf_model_file_name = paste0 (crf_model_file_name, '_15_seqLength_0_overlap')


#crf_test_file_name = paste0('../../../preprocessing/R/test/results/crf_feature_',test_participant)
crf_test_file_name = paste0 ('../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_',test_participant)

output_prediction_file_name = paste0('results/',train_participant,'_train_',test_participant,'_test_',training_method,'_',no_of_epochs,'epochs_',learning_rate,'LR_',reg_method, '_reg_method_', reg_constant, '_reg_constant')
if(gibbs_sampling_rounds != "NULL") {
	output_prediction_file_name = paste0(output_prediction_file_name,'_',gibbs_sampling_rounds,"rounds")
}
output_prediction_file_name = paste0 (output_prediction_file_name, '_15_seqLength_0_overlap')


test_list = NULL
if(!tag_only) { 
	test_list = crf_train(crf_input_file=crf_input_file_name,feature_list_file='../feature_list_all_no_custom', labels=labels,crf_model_file =crf_model_file_name, options)
}
options$crf_sequence_length = 10
options$overlap_window_length = 5
crf_tag(crf_test_file_name, crf_model_file=crf_model_file_name, feature_list_file ='../feature_list_all_no_custom', output_prediction_file=output_prediction_file_name, options, test_list) 
accuracy = find_accuracy(output_prediction_file_name)
cat(test_participant,",", no_of_epochs,",",learning_rate,",",reg_method,",",reg_constant,",",accuracy,"\n",file=avg_acc_file,append=TRUE)

