
import crf_train
import crf_tag
import find_accuracy


#split_rule = '70-30'
split_rule = '80-20'
reg_constant = 0.1
period = 5
feature_file = 'feature_list_all_sequence_wide_only'

options_dict = {'reg_constant': str(reg_constant), 'period': str(period)}

misc = 'seqlen_15_l2_'+ split_rule + '_' + str(reg_constant) + '_lbfgs_period_'+ str(period) +'_sequence_wide_only'
#misc = ""
train_file = '../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap'

avg_acc = 0.0
participant_list=["SDU078","SDU079","SDU080","SDU082","SDU085","SDU086","SDU087","SDU089","SDU090","SDU091","SDU092","SDU093","SDU094","SDU096","SDU097","SDU098",
"SDU099","SDU100","SDU102","SDU122","SDU123","SDU124"]
#-------------------------------------------------------------------
model_file = 'test/results/crf_all_model' + misc
#-------------------------------------------------------------------
# 70-30 split
#excluded_participant_list = ["SDU103","SDU109","SDU111","SDU113","SDU114","SDU115","SDU116","SDU117","SDU118","SDU119","SDU120","SDU121"] 

# 80-20 split
#excluded_participant_list = ["SDU078","SDU079","SDU080","SDU082","SDU085","SDU086","SDU087","SDU089"]
excluded_participant_list = ["SDU109","SDU111","SDU113","SDU114","SDU115","SDU116","SDU117"] 

crf_train.crf_train(train_file,feature_file,model_file, excluded_participant_list,options_dict)


for excluded_participant in excluded_participant_list:
	participant_file='../../preprocessing/R/test/results/exhaustive_15_seqLength_0_overlap/crf_feature_all_15_seqLength_0_overlap_' + excluded_participant
	output_prediction_file='test/results/results_AllTrain_subset_'+ excluded_participant + 'Test' + misc
	
	crf_tag.crf_tag(model_file, participant_file, feature_file, output_prediction_file)
	
	acc  = find_accuracy.find_accuracy (output_prediction_file)
	print excluded_participant + ": " + str(acc)
	avg_acc = avg_acc + acc


avg_acc = avg_acc/len(excluded_participant_list)
output = open('split_outputfile', 'a')
print "avg_acc: " +  str(avg_acc)
output.write( 'sequence_wide_only, ' + split_rule + ', ' + str(reg_constant) + ', ' + str(period) + ', ' + str(avg_acc) +"\n")