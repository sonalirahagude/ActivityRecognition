# set the working directory to the directory of this folder
print("test")

setwd('.')
print(getwd())
source('../setup.R')

## plain_features_file: contains list of names of raw observations to be directly included as a feature function
## no_of_steps is specific to diff features

options = list(plain_features_list = "../plain_features_list", difference_features_list = '../diff_features_list', 
	no_of_steps = 4, no_of_steps_backward = 3, no_of_steps_forward = 3, gap_threshold_for_seq_cutoff = 60 )	

# generate_sequences_from_raw_data( c("../data/TREC_ML.csv","../data/GT3X+Raw_Features_60"), "../data/AnnotatedFilesNew/",
#  	"../feature_list", crf_sequence_length= 15, sliding_window_length = 0, interval_length_in_sec = 60, options)

do_min_max_scaling (crf_sequence_length = 15, sliding_window_length = 0 , interval_length_in_sec = 60)
