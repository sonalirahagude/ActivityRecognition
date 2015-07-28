import crf_train
import crf_tag
import find_accuracy
import util
import os
# reg_constant: The coefficient for L2 regularization.
# period: The duration of iterations to test the stopping criterion. 

#feature_file = 'feature_list_all'
feature_file = 'feature_list_all_shorter_and_sequence_wide_with_diff'

# reg_constants = [0.01,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.6,0.7,0.8,0.9,1,2]

reg_constants = [0.001, 0.025,0.0075, 0.01,0.5, 0.1, 1, 10, 100]
periods = [5]
interval_length_in_sec = 60

sliding_window_lengths = [0,2, 5]
crf_sequence_lengths = [10, 12, 15]

participant_list=["SDU078","SDU079","SDU080","SDU082","SDU085","SDU086","SDU087","SDU089","SDU090","SDU091","SDU092","SDU093","SDU094","SDU096","SDU097","SDU098","SDU099","SDU100","SDU102","SDU103","SDU109","SDU111","SDU113","SDU114","SDU115","SDU116","SDU117","SDU118","SDU119","SDU120","SDU121","SDU122","SDU123","SDU124"]

test_participant_list=["SDU087","SDU090","SDU097","SDU100","SDU113","SDU122"]
#test_participant_list=["SDU115","SDU116","SDU117","SDU118","SDU119","SDU120","SDU121","SDU123","SDU124"]
#test_participant_list = ["SDU122"]

for crf_sequence_length in crf_sequence_lengths:
	for sliding_window_length in sliding_window_lengths:
		options_dict = {'reg_constants': reg_constants, 'periods': periods, 'sliding_window_length':sliding_window_length, 'crf_sequence_length': crf_sequence_length, 'interval_length_in_sec':interval_length_in_sec}

		crf_train_file = util.get_crf_file_name(crf_sequence_length, sliding_window_length, interval_length_in_sec)
		if not os.path.isfile(crf_train_file):
			continue
		crf_train.leave_one_out(crf_train_file, feature_file, participant_list, test_participant_list, options_dict)
		#crf_train.leave_one_out(crf_train_file, feature_file, participant_list, participant_list, options_dict)

