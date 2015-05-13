## usage

print(getwd())
source('~/git/ActivityRecognition/src/CRF/R/setup.R')
#get_feature_inclusion_list('../feature_list_all')

#get_training_data('../../../preprocessing/R/test/crf_feature_SDU078_cut','../feature_list_all')

#options = c('no_of_epochs' = 100, 'learning_rate' = 1, 'gibbs_sampling_rounds' = 5, training_method="contrasive_divergence", overlap_window_length = 5, crf_sequence_length=10)

labels = c("StandingMoving", "StandingStill","Sedentary","Walking","Biking","Vehicle")

 # crf_train(crf_input_file='../../../preprocessing/R/test/results/crf_feature_SDU082',feature_list_file='../feature_list_all',
 #   	labels=labels,crf_model_file = 'results/crf_SDU082_model_cd_100epochs_1LR_preprocess_scale_center', options)
 #   crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_SDU082', crf_model_file='results/crf_SDU082_model_cd_100epochs_1LR_preprocess_scale_center', 
 #    	feature_list_file ='../feature_list_all', output_prediction_file='results/result_SDU082_train_SDU082_test_cd_100epochs_1LR_preprocess_scale_center', NULL) 
  
  # crf_train(crf_input_file='../../../preprocessing/R/test/results/crf_feature_SDU082',feature_list_file='../feature_list_all',
  # 	labels=labels,crf_model_file = 'results/crf_SDU082_model_fb_10epochs_1LR_preprocess_scale_center', options)

  # crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_SDU082', crf_model_file='results/crf_SDU082_model_fb_10epochs_1LR_preprocess_scale_center4', 
  #    	feature_list_file ='../feature_list_all', output_prediction_file='results/result_SDU082_train_SDU082_test_fb_10epochs_1LR_preprocess_scale_center4', NULL) 

  #options = c('no_of_epochs' = 20, 'learning_rate' = 0.05, 'gibbs_sampling_rounds' = 5, training_method="collins_perceptron", "overlap_window_length" = 5, "crf_sequence_length"=10)

  # crf_train(crf_input_file='../../../preprocessing/R/test/results/crf_feature_SDU082',feature_list_file='../feature_list_all',
  # 	labels=labels,crf_model_file = 'results/crf_SDU082_model_fb_20epochs_preprocess_scale_only', options)
  #  crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_SDU082', crf_model_file='results/crf_SDU082_model_fb_20epochs_preprocess_scale_only', 
  #   	feature_list_file ='../feature_list_all', output_prediction_file='results/result_SDU082_train_SDU082_test_fb_20epochs_preprocess_scale_only', NULL) 



 # crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_SDU082', crf_model_file='results/crf_SDU082_model_fb_20epochs_preprocess_scale_only2', 
 #   	feature_list_file ='../feature_list_all', output_prediction_file='results/result_SDU082_train_SDU082_fb_test_20epochs_preprocess_scale_only2', NULL) 

# crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_SDU085', crf_model_file='results/crf_all_model_20epochs_preprocess_scale_only2', 
#   	feature_list_file ='../feature_list_all', output_prediction_file='results/result_all_train_SDU085_test_20epochs_preprocess_scale_only2', NULL) 


# crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_SDU082', crf_model_file='results/crf_all_model_collins_20epochs_preprocess_scale_only2', 
#   	feature_list_file ='../feature_list_all', output_prediction_file='results/result_all_train_SDU082_test_collins_20epochs_preprocess_scale_only2', NULL) 

# crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_SDU085', crf_model_file='results/crf_all_model_collins_20epochs_preprocess_scale_only2', 
#   	feature_list_file ='../feature_list_all', output_prediction_file='results/result_all_train_SDU085_test_collins_20epochs_preprocess_scale_only2', NULL) 


# crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_SDU086', crf_model_file='results/crf_all_model_20epochs_preprocess_scale_only2', 
#   	feature_list_file ='../feature_list_all', output_prediction_file='results/result_all_train_SDU086_test_20epochs_preprocess_scale_only2', NULL) 
# options = c('no_of_epochs' = 10, 'learning_rate' = 1, 'gibbs_sampling_rounds' = 10, training_method="contrasive_divergence", excluded_participant = "SDU103", overlap_window_length = 0, crf_sequence_length=15)

# crf_train(crf_input_file='../../../preprocessing/R/test/results/crf_feature_all_20_seqLength_0_overlap',feature_list_file='../feature_list_all',
#    labels=labels,crf_model_file = 'results/crf_all_model_cd_10epochs_1LR_10gibbs_20_len_0_overlap', options)
 


# crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_all_20_seqLength_0_overlap_SDU103', crf_model_file='results/crf_all_model_cd_10epochs_1LR_10gibbs_20_len_0_overlap', 
#   	feature_list_file ='../feature_list_all', output_prediction_file='results/result_all_train_SDU103_test_20_len_0_overlap', options) 
   
# options = c('no_of_epochs' = 10, 'learning_rate' = 1, 'gibbs_sampling_rounds' = 10, training_method="contrasive_divergence", excluded_participant = "SDU087", overlap_window_length = 0, crf_sequence_length=15)

# crf_train(crf_input_file='../../../preprocessing/R/test/results/crf_feature_all_20_seqLength_0_overlap',feature_list_file='../feature_list_all',
#    labels=labels,crf_model_file = 'results/crf_all_model_cd_10epochs_1LR_10gibbs_20_len_0_overlap_SDU087_excluded', options)
 


# crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_all_20_seqLength_0_overlap_SDU087', crf_model_file='results/crf_all_model_cd_10epochs_1LR_10gibbs_20_len_0_overlap_SDU087_excluded', 
#     feature_list_file ='../feature_list_all', output_prediction_file='results/result_all_train_SDU087_test_20_len_0_overlap', options) 

# options = c('no_of_epochs' = 10, 'learning_rate' = 1, 'gibbs_sampling_rounds' = 10, training_method="contrasive_divergence", excluded_participant = "SDU090", overlap_window_length = 0, crf_sequence_length=15)


# crf_train(crf_input_file='../../../preprocessing/R/test/results/crf_feature_all_20_seqLength_0_overlap',feature_list_file='../feature_list_all',
#    labels=labels,crf_model_file = 'results/crf_all_model_cd_10epochs_1LR_10gibbs_20_len_0_overlap_SDU090_excluded', options)
 


# crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_all_20_seqLength_0_overlap_SDU090', crf_model_file='results/crf_all_model_cd_10epochs_1LR_10gibbs_20_len_0_overlap_SDU090_excluded', 
#     feature_list_file ='../feature_list_all', output_prediction_file='results/result_all_train_SDU090_test_20_len_0_overlap', options) 


 options = c('no_of_epochs' = 10, 'learning_rate' = 1, 'gibbs_sampling_rounds' = 10, training_method="contrasive_divergence", excluded_participant = "SDU118", overlap_window_length = 0, crf_sequence_length=15)


crf_train(crf_input_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap',feature_list_file='../feature_list_all',
   labels=labels,crf_model_file = 'results/crf_all_model_cd_10epochs_1LR_10gibbs_15_len_0_overlap_SDU118_excluded_no_snr_ele_dist_spped', options)
 


crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_SDU118', crf_model_file='results/crf_all_model_cd_10epochs_1LR_10gibbs_15_len_0_overlap_SDU118_excluded_no_snr_ele_dist_spped', 
     feature_list_file ='../feature_list_all', output_prediction_file='results/result_all_train_SDU118_test_15_len_0_overlap_no_snr_ele_dist_spped', options) 


options = c('no_of_epochs' = 10, 'learning_rate' = 1, 'gibbs_sampling_rounds' = 10, training_method="contrasive_divergence", 
  excluded_participant = "SDU092", overlap_window_length = 0, crf_sequence_length=15)


crf_train(crf_input_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap',feature_list_file='../feature_list_all',
   labels=labels,crf_model_file = 'results/crf_all_model_cd_10epochs_1LR_10gibbs_15_len_0_overlap_SDU092_excluded_no_snr_ele_dist_speed', options)
 


crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_SDU092', crf_model_file='results/crf_all_model_cd_10epochs_1LR_10gibbs_15_len_0_overlap_SDU092_excluded_no_snr_ele_dist_speed', 
    feature_list_file ='../feature_list_all', output_prediction_file='results/result_all_train_SDU092_test_15_len_0_overlap_no_snr_ele_dist_speed', options) 

options = c('no_of_epochs' = 10, 'learning_rate' = 1, 'gibbs_sampling_rounds' = 10, training_method="contrasive_divergence", 
  excluded_participant = "SDU103", overlap_window_length = 0, crf_sequence_length=15)


crf_train(crf_input_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap',feature_list_file='../feature_list_all',
   labels=labels,crf_model_file = 'results/crf_all_model_cd_10epochs_1LR_10gibbs_15_len_0_overlap_SDU103_excluded_no_snr_ele_dist_speed', options)
 


crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_SDU103', crf_model_file='results/crf_all_model_cd_10epochs_1LR_10gibbs_15_len_0_overlap_SDU103_excluded_no_snr_ele_dist_speed', 
    feature_list_file ='../feature_list_all', output_prediction_file='results/result_all_train_SDU103_test_15_len_0_overlap_no_snr_ele_dist_speed', options) 

options = c('no_of_epochs' = 10, 'learning_rate' = 1, 'gibbs_sampling_rounds' = 10, training_method="contrasive_divergence", 
  excluded_participant = "SDU091", overlap_window_length = 0, crf_sequence_length=15)


crf_train(crf_input_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap',feature_list_file='../feature_list_all',
   labels=labels,crf_model_file = 'results/crf_all_model_cd_10epochs_1LR_10gibbs_15_len_0_overlap_SDU091_excluded_no_snr_ele_dist_speed', options)
 


crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_SDU091', crf_model_file='results/crf_all_model_cd_10epochs_1LR_10gibbs_15_len_0_overlap_SDU091_excluded_no_snr_ele_dist_speed', 
    feature_list_file ='../feature_list_all', output_prediction_file='results/result_all_train_SDU091_test_15_len_0_overlap_no_snr_ele_dist_speed', options) 

