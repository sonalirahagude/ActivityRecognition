def get_crf_dir_name(crf_sequence_length, sliding_window_length, interval_length_in_sec) :
	input_crf_dir = '../../preprocessing/R/test/results/' + str(crf_sequence_length) +  '_seqLength_' + str(sliding_window_length) + '_overlap_' +  str(interval_length_in_sec) +  '_sec_interval'
	return input_crf_dir


def get_crf_file_name(crf_sequence_length, sliding_window_length, interval_length_in_sec) :
    input_crf_dir = get_crf_dir_name(crf_sequence_length, sliding_window_length, interval_length_in_sec)
    input_crf_file = input_crf_dir + '/scaled_all'
    # input_crf_file = input_crf_dir + '/all'
    return input_crf_file

def convert_to_python_list(crfsuite_list) :
	python_list = []
	crfsuite_list_itr = crfsuite_list.iterator()
	for word in crfsuite_list_itr:
		python_list.append(word)
	return python_list

'''
def get_similarity (label, label_sequence) :
	sim = 0
	for l in label_sequence:
		if l == label:
			sim = sim + 1
	return sim
'''

def get_similarity (label, label_sequence) :
	sim = 0
	for i in range(0,len(label_sequence)):
		if label_sequence[i] == label:
			# crf tag code gives priority to a greater similarity value. hence the below convoluted logic
			return 1000 - i
	return 1000
