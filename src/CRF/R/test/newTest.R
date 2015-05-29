print(getwd())
source('~/git/ActivityRecognition/src/CRF/R/setup.R')
source('~/git/ActivityRecognition/src/CRF/R/test/find_accuracy.R')
labels = c("Sedentary", "StandingStill","StandingMoving", "Walking","Biking","Vehicle")

avg_acc_file = "fb_acc_file"
cat("epochs,lr,reg_method,reg_constant,avg_acc\n",file=avg_acc_file,append=TRUE)

reg_constants  = c(1000)
reg_methods = c("l1")
lrs = c(0.1)
range_epochs = c(50)

for(lr in lrs) {
  for(reg_method in reg_methods) {
    for(reg_constant in reg_constants) {
      for(epochs in range_epochs) {
        options = c('no_of_epochs' = epochs, 'learning_rate' = lr, 'gibbs_sampling_rounds' = 10, training_method="forward_backward", overlap_window_length = 0, 
          crf_sequence_length=15, regularization_constant = reg_constant , regularization_method = reg_method)

        crf_model_file_name = paste0('results/crf_all_model_cd_',epochs, 'epochs_',lr,'_LR_10gibbs_15_len_0_overlap_', reg_constant , '_' ,  reg_method , '_reg')
        crf_train(crf_input_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap',feature_list_file='../feature_list_all',
           labels=labels,crf_model_file = crf_model_file_name, options)        
  
        # epochs = 50
        # lr = 0.001        
        # crf_model_file_name = 'results/crf_all_model_contrasive_divergence_50_epochs_0.001_LR_l1_reg_method_1000_reg_constant_10rounds_SDU113excluded_15_seqLength_0_overlap'      
  
        avg_acc = 0.0
  
        test_participant_list=c("SDU079","SDU080","SDU082","SDU085","SDU086","SDU087","SDU089","SDU090","SDU091","SDU092","SDU093","SDU094","SDU096",
          "SDU097","SDU098", "SDU099", "SDU102","SDU103","SDU109","SDU111","SDU113","SDU114","SDU115","SDU116","SDU117","SDU118","SDU119","SDU120","SDU121","SDU122","SDU123","SDU124")

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
