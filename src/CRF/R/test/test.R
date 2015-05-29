print(getwd())
source('~/git/ActivityRecognition/src/CRF/R/setup.R')
source('~/git/ActivityRecognition/src/CRF/R/test/find_accuracy.R')
#get_feature_inclusion_list('../feature_list_all')

#get_training_data('../../../preprocessing/R/test/crf_feature_SDU078_cut','../feature_list_all')

#options = c('no_of_epochs' = 1000, 'learning_rate' = 1, 'gibbs_sampling_rounds' = 5, training_method="contrasive_divergence", overlap_window_length = 5, crf_sequence_length=10)

labels = c("Sedentary", "StandingStill","StandingMoving", "Walking","Biking","Vehicle")

# reg_constant = 25
# reg_method = "l2"
# lr = 0.01
# epochs =  50


avg_acc_file = "shorter_feat_avg_accuracy_file"
#cat("epochs,lr,reg_method,reg_constant,avg_acc\n",file=avg_acc_file,append=TRUE)

reg_constants  = c(5,10,25,50)
reg_methods = c("l2")
lrs = c(0.001,0.005,0.01,0.05)
range_epochs = c(10)#,20,50)

for(lr in lrs) {
  for(reg_method in reg_methods) {
    for(reg_constant in reg_constants) {
      for(epochs in range_epochs) {
        if(epochs == 10 && lr== 0.005) 
          next
        
        options = c('no_of_epochs' = epochs, 'learning_rate' = lr, 'gibbs_sampling_rounds' = 10, training_method="contrasive_divergence", overlap_window_length = 0, crf_sequence_length=15,
          regularization_constant = reg_constant , regularization_method = reg_method)

        crf_model_file_name = paste0('results/crf_all_model_cd_',epochs, 'epochs_',lr,'_LR_10gibbs_15_len_0_overlap_', reg_constant , '_' ,  reg_method , '_reg')
        crf_train(crf_input_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap',feature_list_file='../feature_list_all',
           labels=labels,crf_model_file = crf_model_file_name, options)        
        # crf_model_file_name = 'results/crf_all_model_cd_50epochs_1LR_10gibbs_15_len_0_overlap_1000_l1_reg
        
        avg_acc = 0.0
        test_participant_list=c("SDU079","SDU080","SDU082","SDU085","SDU086","SDU087","SDU089","SDU090","SDU091","SDU092","SDU093","SDU094","SDU096",
          "SDU097","SDU098","SDU099","SDU100", "SDU102","SDU103","SDU109","SDU111","SDU113","SDU114","SDU115","SDU116","SDU117","SDU118","SDU119","SDU120","SDU121","SDU122","SDU123","SDU124")

        for (test_participant in test_participant_list){
          output_prediction_file_name = paste0('results/result_all_train_' , test_participant , '_test_', epochs , '_epochs_',lr,'_LR_15_len_0_overlap_' , reg_constant , '_' ,  reg_method , '_reg')
          crf_tag(crf_test_file=paste0('../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_',test_participant),
           crf_model_file=crf_model_file_name, 
               feature_list_file ='../feature_list_all', output_prediction_file=output_prediction_file_name, options) 
          accuracy = find_accuracy(output_prediction_file_name)
          cat("Accuracy for ",test_participant , ": ", accuracy,"\n")
          avg_acc = avg_acc + accuracy
          
        }
        avg_acc = avg_acc/length(test_participant_list)

        cat("avg_acc: ",avg_acc,"\n")
        cat(epochs,",",lr,",",reg_method,",",reg_constant,",",avg_acc,"\n",file=avg_acc_file,append=TRUE)
      }
    }
  }
}

# output_prediction_file_name = paste0('results/result_all_train_SDU090_test_', epochs , '_epochs_',lr,'_LR_15_len_0_overlap_' , reg_constant , '_' ,  reg_method , '_reg')
# crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_SDU090',
#  crf_model_file=crf_model_file_name, 
#      feature_list_file ='../feature_list_all', output_prediction_file=output_prediction_file_name, options) 
# accuracy = find_accuracy(output_prediction_file_name)
# cat("Accuracy for SDU090: ", accuracy,"\n")
# avg_acc = avg_acc + accuracy

# output_prediction_file_name = paste0('results/result_all_train_SDU102_test_', epochs , '_epochs_',lr,'_LR_15_len_0_overlap_', reg_constant , '_' ,  reg_method , '_reg')
# crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_SDU102',
#  crf_model_file=crf_model_file_name, 
#      feature_list_file ='../feature_list_all', output_prediction_file=output_prediction_file_name, options) 
# accuracy = find_accuracy(output_prediction_file_name)
# cat("Accuracy for SDU102: ", accuracy,"\n")
# avg_acc = avg_acc + accuracy

# output_prediction_file_name = paste0('results/result_all_train_SDU103_test_', epochs , '_epochs_',lr,'_LR_15_len_0_overlap_', reg_constant , '_' ,  reg_method , '_reg')
# crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_SDU103',
#  crf_model_file=crf_model_file_name, 
#      feature_list_file ='../feature_list_all', output_prediction_file=output_prediction_file_name, options) 
# accuracy = find_accuracy(output_prediction_file_name)
# cat("Accuracy for SDU103: ", accuracy,"\n")
# avg_acc = avg_acc + accuracy

# output_prediction_file_name = paste0('results/result_all_train_SDU109_test_', epochs , '_epochs_',lr,'_LR_15_len_0_overlap_' , reg_constant , '_' ,  reg_method , '_reg')
# crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_SDU109',
#  crf_model_file=crf_model_file_name, 
#      feature_list_file ='../feature_list_all', output_prediction_file=output_prediction_file_name, options) 
# accuracy = find_accuracy(output_prediction_file_name)
# cat("Accuracy for SDU109: ", accuracy,"\n")
# avg_acc = avg_acc + accuracy

# output_prediction_file_name = paste0('results/result_all_train_SDU111_test_', epochs , '_epochs_',lr,'_LR_15_len_0_overlap_', reg_constant , '_' ,  reg_method , '_reg')
# crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_SDU111',
#  crf_model_file=crf_model_file_name, 
#      feature_list_file ='../feature_list_all', output_prediction_file=output_prediction_file_name, options) 
# accuracy = find_accuracy(output_prediction_file_name)
# cat("Accuracy for SDU111: ", accuracy,"\n")
# avg_acc = avg_acc + accuracy

# output_prediction_file_name = paste0('results/result_all_train_SDU122_test_', epochs , '_epochs_',lr,'_LR_15_len_0_overlap_', reg_constant , '_' ,  reg_method , '_reg')
# crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_SDU122',
#  crf_model_file=crf_model_file_name, 
#      feature_list_file ='../feature_list_all', output_prediction_file=output_prediction_file_name, options) 
# accuracy = find_accuracy(output_prediction_file_name)
# cat("Accuracy for SDU122: ", accuracy,"\n")
# avg_acc = avg_acc + accuracy


# output_prediction_file_name = paste0('results/result_all_train_SDU118_test_', epochs , '_epochs_',lr,'_LR_15_len_0_overlap_', reg_constant , '_' ,  reg_method , '_reg')
# crf_tag(crf_test_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_SDU118',
#  crf_model_file=crf_model_file_name, 
#      feature_list_file ='../feature_list_all', output_prediction_file=output_prediction_file_name, options) 
# accuracy = find_accuracy(output_prediction_file_name)
# cat("Accuracy for SDU118: ", accuracy,"\n")
# avg_acc = avg_acc + accuracy


# avg_acc = avg_acc/8


# cat("avg_acc: ",avg_acc,"\n")

