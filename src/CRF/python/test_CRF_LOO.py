
#import crf_train
import crf_train_new
import crf_tag
import find_accuracy



train_file = '../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap'
#feature_file = 'feature_list_all'
#feature_file = 'feature_list_all_sequence_wide_only'
#feature_file = 'feature_list_all_shorter_and_sequence_wide'
feature_file = 'feature_list_all_shorter_and_sequence_wide_with_diff'

#reg_constants = [0.01,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.6,0.7,0.8,0.9,1,2]
reg_constants = [0.5,0.3,0.25,0.2,0.1,0.05,0.001]
#periods = [5,20]
#periods = [5,10,20]

#reg_constants = [0.3,0.35,0.25]
#reg_constants = [0.001,0.003,0.2]
#reg_constants = [0.025,0.0075,0.01]

reg_constants = [0.0005,0.00075,0.0002,0.0006]
reg_constants = [0.00005,0.0000]
periods = [5]

participant_list=["SDU078","SDU079","SDU080","SDU082","SDU085","SDU086","SDU087","SDU089","SDU090","SDU091","SDU092","SDU093","SDU094","SDU096","SDU097","SDU098","SDU099","SDU100","SDU102","SDU103","SDU109","SDU111","SDU113","SDU114","SDU115","SDU116","SDU117","SDU118","SDU119","SDU120","SDU121","SDU122","SDU123","SDU124"]

test_participant_list=["SDU078","SDU087","SDU090","SDU097","SDU100","SDU113","SDU122"]
#test_participant_list=["SDU079","SDU080","SDU082","SDU085","SDU086","SDU089","SDU091","SDU092","SDU093","SDU094","SDU096","SDU098","SDU099","SDU102","SDU103","SDU109","SDU111","SDU114","SDU115","SDU116","SDU117","SDU118","SDU119","SDU120","SDU121","SDU123","SDU124"]

options_dict = {'reg_constants': reg_constants, 'periods': periods}

crf_train_new.leave_one_out(train_file,feature_file,participant_list, test_participant_list, options_dict)
#misc = 'seqlen_15_l2_'+ split_rule + '_' + str(reg_constant) + '_lbfgs_period_'+ str(period) +'_sequence_wide_only'

# avg_acc = 0.0
# #participant_list=["SDU078","SDU079","SDU080","SDU082","SDU085","SDU086","SDU087","SDU089","SDU090","SDU091","SDU092","SDU093","SDU094","SDU096","SDU097","SDU098","SDU099","SDU100","SDU102","SDU103","SDU109","SDU111","SDU113","SDU114","SDU115","SDU116","SDU117","SDU118","SDU119","SDU120","SDU121","SDU122","SDU123","SDU124"]
# participant_list = ["SDU078"]
# #-------------------------------------------------------------------
# # model_file = 'test/results/crf_all_model' + misc
# # crf_train.crf_train(train_file,feature_file,model_file, "")
# #-------------------------------------------------------------------


# for excluded_participant in participant_list:
# 	excluded_participant_list = [excluded_participant]
# 	model_file = 'test/results/crf_all_model_' + excluded_participant + '_excluded' + misc
# 	crf_train.crf_train(train_file,feature_file,model_file, excluded_participant_list, options_dict)
	
# for excluded_participant in participant_list:
# 	model_file = 'test/results/crf_all_model_' + excluded_participant + '_excluded' + misc
# 	participant_file='../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_' + excluded_participant 
# 	output_prediction_file='test/results/results_AllTrain'+ excluded_participant + 'Test' + misc
	
# 	#-------------------------------------------------------------------
# 	# participant_file='../../preprocessing/R/test/results/exhaustive_15_seqLength_0_overlap/crf_feature_all_15_seqLength_0_overlap_' + excluded_participant
# 	# output_prediction_file='test/results/results_AllTrain_no_exclusion_'+ excluded_participant + 'Test' + misc
# 	#-------------------------------------------------------------------		
	
# 	crf_tag.crf_tag(model_file, participant_file, feature_file, output_prediction_file)
	
# 	acc  = find_accuracy.find_accuracy (output_prediction_file)
# 	print excluded_participant + ": " + str(acc)
# 	avg_acc = avg_acc + acc



# print "avg_acc: " +  str(avg_acc/len(participant_list))