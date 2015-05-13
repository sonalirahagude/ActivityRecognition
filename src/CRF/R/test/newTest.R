print(getwd())
source('~/git/ActivityRecognition/src/CRF/R/setup.R')
#get_feature_inclusion_list('../feature_list_all')

#get_training_data('../../../preprocessing/R/test/crf_feature_SDU078_cut','../feature_list_all')

#options = c('no_of_epochs' = 100, 'learning_rate' = 1, 'gibbs_sampling_rounds' = 5, training_method="contrasive_divergence", overlap_window_length = 5, crf_sequence_length=10)

labels = c("StandingMoving", "StandingStill","Sedentary","Walking","Biking","Vehicle")


   options = c('no_of_epochs' = 10, 'learning_rate' = 1, 'gibbs_sampling_rounds' = 10, training_method="contrasive_divergence", excluded_participant = "SDU118", overlap_window_length = 0, crf_sequence_length=15)


  crf_train(crf_input_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap',feature_list_file='../feature_list_all_diff_included',
     labels=labels,crf_model_file = 'results/crf_all_model_cd_10epochs_1LR_10gibbs_15_len_0_overlap_SDU118_excluded_diff_included', options)
   


  crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_SDU118', crf_model_file='results/crf_all_model_cd_10epochs_1LR_10gibbs_15_len_0_overlap_SDU118_excluded_diff_included', 
       feature_list_file ='../feature_list_all_diff_included', output_prediction_file='results/result_all_train_SDU118_test_15_len_0_overlap_diff_included', options) 


  options = c('no_of_epochs' = 10, 'learning_rate' = 1, 'gibbs_sampling_rounds' = 10, training_method="contrasive_divergence", 
    excluded_participant = "SDU092", overlap_window_length = 0, crf_sequence_length=15)


  crf_train(crf_input_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap',feature_list_file='../feature_list_all_diff_included',
     labels=labels,crf_model_file = 'results/crf_all_model_cd_10epochs_1LR_10gibbs_15_len_0_overlap_SDU092_excluded_diff_included', options)
   


  crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_SDU092', crf_model_file='results/crf_all_model_cd_10epochs_1LR_10gibbs_15_len_0_overlap_SDU092_excluded_diff_included', 
      feature_list_file ='../feature_list_all_diff_included', output_prediction_file='results/result_all_train_SDU092_test_15_len_0_overlap_diff_included', options) 

  options = c('no_of_epochs' = 10, 'learning_rate' = 1, 'gibbs_sampling_rounds' = 10, training_method="contrasive_divergence", 
    excluded_participant = "SDU103", overlap_window_length = 0, crf_sequence_length=15)


  crf_train(crf_input_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap',feature_list_file='../feature_list_all_diff_included',
     labels=labels,crf_model_file = 'results/crf_all_model_cd_10epochs_1LR_10gibbs_15_len_0_overlap_SDU103_excluded_diff_included', options)
   


  crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_SDU103', crf_model_file='results/crf_all_model_cd_10epochs_1LR_10gibbs_15_len_0_overlap_SDU103_excluded_diff_included', 
      feature_list_file ='../feature_list_all_diff_included', output_prediction_file='results/result_all_train_SDU103_test_15_len_0_overlap_diff_included', options) 

  options = c('no_of_epochs' = 10, 'learning_rate' = 1, 'gibbs_sampling_rounds' = 10, training_method="contrasive_divergence", 
    excluded_participant = "SDU091", overlap_window_length = 0, crf_sequence_length=15)


  crf_train(crf_input_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap',feature_list_file='../feature_list_all_diff_included',
     labels=labels,crf_model_file = 'results/crf_all_model_cd_10epochs_1LR_10gibbs_15_len_0_overlap_SDU091_excluded_diff_included', options)
   


  crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_SDU091', crf_model_file='results/crf_all_model_cd_10epochs_1LR_10gibbs_15_len_0_overlap_SDU091_excluded_diff_included', 
      feature_list_file ='../feature_list_all_diff_included', output_prediction_file='results/result_all_train_SDU091_test_15_len_0_overlap_diff_included', options) 
