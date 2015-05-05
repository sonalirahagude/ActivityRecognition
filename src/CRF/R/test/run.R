
## Usage
# Rscript run.R <train participant> <test participant> <epoch_no> <learning_rate> <training_method> <tag_only> <gibbs_sampling_rounds>
# Rscript run.R SDU082 SDU082 20 1 contrasive_divergence FALSE 10

args = commandArgs(trailingOnly=TRUE)
if(length(args) < 6) {
	stop("Insufficient arguments. Usage: Rscript run.R <train participant> <test participant> <epoch_no> <learning_rate> <training_method>")
}

train_participant = args[1]
test_participant = args[2]
no_of_epochs = as.numeric(args[3])
learning_rate = as.numeric(args[4])
training_method = args[5]
tag_only = as.logical(args[6])
gibbs_sampling_rounds = as.numeric(args[7])

setwd('~/git/ActivityRecognition/src/CRF/R/test')
print(getwd())
source('~/git/ActivityRecognition/src/CRF/R/setup.R')

options = c('no_of_epochs' = no_of_epochs, 'learning_rate' = learning_rate, 'gibbs_sampling_rounds' = gibbs_sampling_rounds, 'training_method'=training_method)

labels = c("StandingMoving", "StandingStill","Sedentary","Walking","Biking","Vehicle")

crf_input_file_name = paste0('../../../preprocessing/R/test/results/crf_feature_',train_participant)
crf_model_file_name = paste0('results/crf_',train_participant,'_model_',training_method,'_',no_of_epochs,'epochs_',learning_rate,'LR')

if(gibbs_sampling_rounds != "NULL") {
	crf_model_file_name = paste0(crf_model_file_name,'_',gibbs_sampling_rounds,"rounds")
}

crf_test_file_name = paste0('../../../preprocessing/R/test/results/crf_feature_',test_participant)
output_prediction_file_name = paste0('results/',train_participant,'_train_',test_participant,'_test_',training_method,'_',no_of_epochs,'epochs_',learning_rate,'LR')
if(gibbs_sampling_rounds != "NULL") {
	output_prediction_file_name = paste0(output_prediction_file_name,'_',gibbs_sampling_rounds,"rounds")
}

if(!tag_only) { 
	crf_train(crf_input_file=crf_input_file_name,feature_list_file='../feature_list_all', labels=labels,crf_model_file =crf_model_file_name, options)
}
crf_tag(crf_test_file_name, crf_model_file=crf_model_file_name, feature_list_file ='../feature_list_all', output_prediction_file=output_prediction_file_name, NULL) 



