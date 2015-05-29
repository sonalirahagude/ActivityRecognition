setwd('~/git/ActivityRecognition/src/CRF/R/test')
print(getwd())
source('~/git/ActivityRecognition/src/CRF/R/setup.R')
source('find_accuracy.R')

labels = c("StandingMoving", "StandingStill","Sedentary","Walking","Biking","Vehicle")
crf_input_file_name = '../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap'


no_of_epochs = 50
lr = 1
gibbs_sampling_rounds = 10
reg_method = "l1"

# options = c('no_of_epochs' = no_of_epochs, 'learning_rate' = 1, 'gibbs_sampling_rounds' = gibbs_sampling_rounds, training_method="contrasive_divergence", 
#   excluded_participant = "SDU118", overlap_window_length = 0, crf_sequence_length=15, regularization_constant = 10)

 options = c('no_of_epochs' = no_of_epochs, 'learning_rate' = lr, 'gibbs_sampling_rounds' = 10, training_method="contrasive_divergence", overlap_window_length = 0, crf_sequence_length=15,
  regularization_constant = 2 , regularization_method = reg_method)

test_participant_list=c("SDU087","SDU090","SDU102","SDU118")
learning_rates = c(1)

regularization_constants = c(275, 500, 750,1000)

#test_participant_list=c("SDU087")

accuracy_matrix = array(0,dim=c(length(learning_rates), length(regularization_constants), length(test_participant_list)), 
	dimnames = list(learning_rates,regularization_constants,test_participant_list))

for (learning_rate in learning_rates) {
	options$learning_rate = learning_rate
	for(regularization_constant in regularization_constants) {
		options$regularization_constant = regularization_constant
		for(test_participant in test_participant_list) {
			options$excluded_participant = test_participant
			crf_model_file_name = paste0('results/grid_search/crf_all_model_CD_',no_of_epochs,'epochs_',
			learning_rate,'LR_', gibbs_sampling_rounds,'rounds_', test_participant,'_excluded')


			crf_test_file_name = paste0 ('../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_',test_participant)

			output_prediction_file_name = paste0('results/grid_search/all_train_',test_participant,'_test_contrasive_divergence_',
				no_of_epochs,'epochs_',learning_rate,'LR_',gibbs_sampling_rounds,"rounds_",regularization_constant,"_regularizor")

			crf_train(crf_input_file=crf_input_file_name,feature_list_file='../feature_list_all', labels=labels,crf_model_file =crf_model_file_name, options)

			crf_tag(crf_test_file_name, crf_model_file=crf_model_file_name, feature_list_file ='../feature_list_all', output_prediction_file=output_prediction_file_name, options, NULL) 

			#accuracy_matrix[learning_rate,regularization_constant, test_participant] = find_accuracy(output_prediction_file_name)
		}
		#cat("learning_rate: ", learning_rate, ", regularization_constant: ", regularization_constant, " avg accuracy: ", mean(accuracy_matrix[learning_rate,regularization_constant,]), "\n")
	}	
}
save('results/grid_search/accuracy_matrix', accuracy_matrix)
