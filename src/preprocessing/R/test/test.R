# set the working directory to the directory of this folder
print("test")

setwd('.')
print(getwd())
source('../setup.R')

# no_of_steps is specific to diff features
#options = list(plain_features_list = "../plain_features_list", difference_features_list = '../diff_features_list', no_of_steps = 4, no_of_steps_backward = 3, no_of_steps_forward = 3 )	
#train on all
 # generate_sequences_from_raw_data( c("../data/GPSTest/SDU113.csv","../data/AccTest/"), "../data/AnnotatedFilesNewTest/",
 #  	"../feature_list", "results/test_dummy", crf_sequence_length= 15, overlap_window_length = 2, window_size = 15, options )

# generate_sequences_from_raw_data( c("../data/TREC_ML.csv","../data/GT3X+Raw_Features_15"), "../data/AnnotatedFilesNew/",
# 	 "../feature_list", "results/crf_feature_all_15_seqLength_0_overlap", crf_sequence_length= 15, overlap_window_length = 0, window_size = 15, options)


options = list(plain_features_list = "../plain_features_list", difference_features_list = '../diff_features_list', no_of_steps = 4, no_of_steps_backward = 3, no_of_steps_forward = 3 )	
#train on all
 # generate_sequences_from_raw_data( c("../data/GPSTest/SDU113.csv","../data/AccTest/"), "../data/AnnotatedFilesNewTest/",
 #  	"../feature_list", "results/test_dummy", crf_sequence_length= 15, overlap_window_length = 2, window_size = 15, options )

generate_sequences_from_raw_data( c("../data/TREC_ML.csv","../data/GT3X+Raw_Features_60"), "../data/AnnotatedFilesNew/",
 	"../feature_list", "results/1_min/crf_feature_all_15_seqLength_0_overlap", crf_sequence_length= 15, overlap_window_length = 0, window_size = 60, options)



# test on SDU078

## plain_features_file: contains list of names of raw observations to be directly included as a feature function

# generate_sequences_from_raw_data( c("../data/GPS/GPS_SDU078.csv","../data/AccTest"), "../data/AnnotatedFilesNewTest","../feature_list", 
# 	 "results/crf_feature_SDU078", crf_sequence_length= 15, overlap_window_length = 0, window_size = 15, options )


