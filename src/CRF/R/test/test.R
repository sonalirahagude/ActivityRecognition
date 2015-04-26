print("test")
print(getwd())
source('~/git/ActivityRecognition/src/CRF/R/setup.R')
#get_feature_inclusion_list('../feature_list_all')

#get_training_data('../../../preprocessing/R/test/crf_feature_SDU078_cut','../feature_list_all')

options = c('no_of_epochs' = 100, 'learning_rate' = 1)
labels = c("Sedentary","StandingStill","StandingMoving","Walking","Biking","Vehicle")

#crf_train(crf_input_file='../../../preprocessing/R/test/crf_feature_SDU078_cut',feature_inclusion_file='../feature_list_all',labels=labels,crf_model_file = 'crf_SDU078_cut_model', options)
#crf_test(crt_test_file='../../../preprocessing/R/test/crf_feature_SDU078_cut', crf_model_file='crf_SDU078_cut_model', feature_inclusion_file ='../feature_list_all', output_prediction_file='crf_SDU078_cut_result', NULL) 


crf_train(crf_input_file='../../../preprocessing/R/test/crf_feature_SDU078',feature_inclusion_file='../feature_list_all',labels=labels,crf_model_file = 'crf_SDU078_model', options)
crf_test(crt_test_file='../../../preprocessing/R/test/crf_feature_SDU078', crf_model_file='crf_SDU078_model', feature_inclusion_file ='../feature_list_all', output_prediction_file='result_SDU078_train_SDU078_test', NULL) 
