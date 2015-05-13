# set the working directory to the directory of this folder
print("test")
print(getwd())
source('../setup.R')


# no_of_steps is specific to diff features
options = list(plain_features_list = "../plain_features_list", difference_features_list = '../diff_features_list', no_of_steps = 2 )	
#train on all
# generate_sequences_from_raw_data( c("../data/TREC_ML.csv","../data/GT3X+Raw_Features_15"), "../data/AnnotatedFilesNew/",
#  	"../feature_list", "results/crf_feature_all_10_seqLength_2_overlap", crf_sequence_length= 10, overlap_window_length = 2, window_size = 15, options )


generate_sequences_from_raw_data( c("../data/TREC_ML.csv","../data/GT3X+Raw_Features_15"), "../data/AnnotatedFilesNew/",
 	"../feature_list", "results/crf_feature_all_20_seqLength_5_overlap_1_min_seq_threshold_dummy", crf_sequence_length= 20, overlap_window_length = 5, window_size = 15, options )



# generate_sequences_from_raw_data( c("../data/TREC_ML.csv","../data/AccTest"), "../data/AnnotatedFilesNew/",
# 	"../feature_list", "results/crf_feature_all", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15, options )

# generate_sequences_from_raw_data( c("../data/TREC_ML.csv"), "../data/AnnotatedFilesNew/",
# 	"../feature_list", "results/crf_feature_all", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15, options )


# test on SDU078
#generate_sequences_from_raw_data( c("../data/GPSTest","../data/AccTest"), "../data/AnnotatedFilesNewTest","../feature_list", "../plain_features_list", "results/crf_feature_SDU078", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15 )

## plain_features_file: contains list of names of raw observations to be directly included as a feature function

# generate_sequences_from_raw_data( c("../data/GPS/GPS_SDU092.csv","../data/AccTest"), "../data/AnnotatedFilesNewTest","../feature_list", 
# 	 "results/crf_feature_SDU092_dummy", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15, options )


# generate_sequences_from_raw_data( c("../data/GPS/GPS_SDU099.csv","../data/AccTest"), "../data/AnnotatedFilesNewTest","../feature_list", 
# 	 "results/crf_feature_SDU099", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15, options )

# generate_sequences_from_raw_data( c("../data/GPS/GPS_SDU109.csv","../data/AccTest"), "../data/AnnotatedFilesNewTest","../feature_list", 
# 	 "results/crf_feature_SDU109", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15, options )


# generate_sequences_from_raw_data( c("../data/GPS/GPS_SDU111.csv","../data/AccTest"), "../data/AnnotatedFilesNewTest","../feature_list", 
# 	 "results/crf_feature_SDU111", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15, options )

# generate_sequences_from_raw_data( c("../data/GPS/GPS_SDU122.csv","../data/AccTest"), "../data/AnnotatedFilesNewTest","../feature_list", 
# 	 "results/crf_feature_SDU122", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15, options )


# generate_sequences_from_raw_data( c("../data/GPS/GPS_SDU082.csv","../data/AccTest"), "../data/AnnotatedFilesNewTest","../feature_list", 
# 	 "results/crf_feature_SDU082", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15, options )


# generate_sequences_from_raw_data( c("../data/GPS/GPS_SDU080.csv","../data/AccTest"), "../data/AnnotatedFilesNewTest","../feature_list", 
# 	 "results/crf_feature_SDU080", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15, options )


# generate_sequences_from_raw_data( c("../data/GPS/GPS_SDU098.csv","../data/AccTest"), "../data/AnnotatedFilesNewTest","../feature_list", 
# 	 "results/crf_feature_SDU098", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15, options )


# generate_sequences_from_raw_data( c("../data/GPS/GPS_SDU115.csv","../data/AccTest"), "../data/AnnotatedFilesNewTest","../feature_list", 
# 	 "results/crf_feature_SDU115", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15, options )

# generate_sequences_from_raw_data( c("../data/GPS/GPS_SDU085.csv","../data/AccTest"), "../data/AnnotatedFilesNewTest","../feature_list", 
# 	 "results/crf_feature_SDU085", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15, options )

# generate_sequences_from_raw_data( c("../data/GPS/GPS_SDU086.csv","../data/AccTest"), "../data/AnnotatedFilesNewTest","../feature_list", 
# 	 "results/crf_feature_SDU086", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15, options )
