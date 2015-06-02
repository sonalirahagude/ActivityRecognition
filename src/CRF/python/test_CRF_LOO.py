
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
#reg_constants = [0.5,0.3,0.25,0.2,0.1,0.05,0.001]
#periods = [5,20]
#periods = [5,10,20]

#reg_constants = [0.3,0.35,0.25]
#reg_constants = [0.001,0.003,0.2]
#reg_constants = [0.025,0.0075,0.01]
reg_constants = [0.0001]
periods = [5]

participant_list=["SDU078","SDU079","SDU080","SDU082","SDU085","SDU086","SDU087","SDU089","SDU090","SDU091","SDU092","SDU093","SDU094","SDU096","SDU097","SDU098","SDU099","SDU100","SDU102","SDU103","SDU109","SDU111","SDU113","SDU114","SDU115","SDU116","SDU117","SDU118","SDU119","SDU120","SDU121","SDU122","SDU123","SDU124"]

#test_participant_list=["SDU078","SDU087","SDU090","SDU097","SDU100","SDU113","SDU122"]
test_participant_list=["SDU079","SDU080","SDU082","SDU085","SDU086","SDU089","SDU091","SDU092","SDU093","SDU094","SDU096","SDU098","SDU099","SDU102","SDU103","SDU109","SDU111","SDU114","SDU115","SDU116","SDU117","SDU118","SDU119","SDU120","SDU121","SDU123","SDU124"]

options_dict = {'reg_constants': reg_constants, 'periods': periods}

crf_train_new.leave_one_out(train_file,feature_file,participant_list, test_participant_list, options_dict)