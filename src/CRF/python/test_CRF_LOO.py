
import crf_train
import crf_tag
import find_accuracy



misc = 'l2_0.4_lbfgs_seqlen_15_period_5_plain_vanilla_features'
#misc = ""
train_file = '../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap'
feature_file = 'feature_list_all'

avg_acc = 0.0
participant_list=["SDU078","SDU079","SDU080","SDU082","SDU085","SDU086","SDU087","SDU089","SDU090","SDU091","SDU092","SDU093","SDU094","SDU096","SDU097","SDU098","SDU099","SDU100","SDU102","SDU103","SDU109","SDU111","SDU113","SDU114","SDU115","SDU116","SDU117","SDU118","SDU119","SDU120","SDU121","SDU122","SDU123","SDU124"]
#participant_list = ["SDU078"]
#-------------------------------------------------------------------
# model_file = 'test/results/crf_all_model' + misc
# crf_train.crf_train(train_file,feature_file,model_file, "")
#-------------------------------------------------------------------


for excluded_participant in participant_list:
	excluded_participant_list = [excluded_participant]
	model_file = 'test/results/crf_all_model_' + excluded_participant + '_excluded' + misc
	crf_train.crf_train(train_file,feature_file,model_file, excluded_participant_list)
	
for excluded_participant in participant_list:
	model_file = 'test/results/crf_all_model_' + excluded_participant + '_excluded' + misc
	participant_file='../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_' + excluded_participant 
	output_prediction_file='test/results/results_AllTrain'+ excluded_participant + 'Test' + misc
	
	#-------------------------------------------------------------------
	# participant_file='../../preprocessing/R/test/results/exhaustive_15_seqLength_0_overlap/crf_feature_all_15_seqLength_0_overlap_' + excluded_participant
	# output_prediction_file='test/results/results_AllTrain_no_exclusion_'+ excluded_participant + 'Test' + misc
	#-------------------------------------------------------------------		
	
	crf_tag.crf_tag(model_file, participant_file, feature_file, output_prediction_file)
	
	acc  = find_accuracy.find_accuracy (output_prediction_file)
	print excluded_participant + ": " + str(acc)
	avg_acc = avg_acc + acc



print "avg_acc: " +  str(avg_acc/len(participant_list))