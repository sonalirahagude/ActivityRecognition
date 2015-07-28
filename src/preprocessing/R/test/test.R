# set the working directory to the directory of this folder
print("test")

setwd('.')
print(getwd())
source('../setup.R')

## plain_features_file: contains list of names of raw observations to be directly included as a feature function
## no_of_steps is specific to diff features
options = list(plain_features_list = "../plain_features_list", difference_features_list = '../diff_features_list', 
	no_of_steps = 4, no_of_steps_backward = 3, no_of_steps_forward = 3, gap_threshold_for_seq_cutoff = 60 )	

crf_sequence_length_val = 15
sliding_window_length_val = 0
interval_length_in_sec_val = 15
accelerometer_dir = paste0('../data/GT3X+Raw_Features_', interval_length_in_sec_val)
print(accelerometer_dir)

# generate_sequences_from_raw_data( c("../data/TREC_ML.csv", accelerometer_dir), "../data/AnnotatedFilesNew/",
#  	"../feature_list", crf_sequence_length= crf_sequence_length_val, sliding_window_length = sliding_window_length_val, 
#  	interval_length_in_sec = interval_length_in_sec_val, options)

do_min_max_scaling (crf_sequence_length = crf_sequence_length_val, sliding_window_length = sliding_window_length_val ,
	 interval_length_in_sec = interval_length_in_sec_val)

# do_R_scaling (crf_sequence_length = crf_sequence_length_val, sliding_window_length = sliding_window_length_val ,
# 	 interval_length_in_sec = interval_length_in_sec_val)

# do_R_scaling_simple (crf_sequence_length = crf_sequence_length_val, sliding_window_length = sliding_window_length_val ,
# 	 interval_length_in_sec = interval_length_in_sec_val)
