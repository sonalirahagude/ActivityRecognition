def get_crf_dir_name(crf_sequence_length, sliding_window_length, interval_length_in_sec) :
	input_crf_dir = '../../preprocessing/R/test/results/' + str(crf_sequence_length) +  '_seqLength_' + str(sliding_window_length) + '_overlap_' +  str(interval_length_in_sec) +  '_sec_interval'
	return input_crf_dir


def get_crf_file_name(crf_sequence_length, sliding_window_length, interval_length_in_sec) :
    input_crf_dir = get_crf_dir_name(crf_sequence_length, sliding_window_length, interval_length_in_sec)
    input_crf_file = input_crf_dir + '/scaled_all'
    return input_crf_file



