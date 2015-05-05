# set the working directory to the directory of this folder
print("test")
print(getwd())
source('../setup.R')


#train on all
generate_sequences_from_raw_data( c("../data/TREC_ML_Features_15","../data/GT3X+Raw_Features_15"), "../data/AnnotatedFilesNew/",
	"../feature_list", "../plain_features_list", "results/crf_feature_all", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15 )

# test on SDU078
#generate_sequences_from_raw_data( c("../data/GPSTest","../data/AccTest"), "../data/AnnotatedFilesNewTest","../feature_list", "../plain_features_list", "results/crf_feature_SDU078", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15 )

## plain_features_file: contains list of names of raw observations to be directly included as a feature function
options = list(plain_features_list = "../plain_features_list", difference_features_list = '../diff_features_list', no_of_steps = 2 )	

# generate_sequences_from_raw_data( c("../data/GPS/GPS_SDU079.csv","../data/AccTest"), "../data/AnnotatedFilesNewTest","../feature_list", 
# 	 "results/crf_feature_SDU079_custom_features_only", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15, options )

# generate_sequences_from_raw_data( c("../data/GPS/GPS_SDU079.csv","../data/AccTest"), "../data/AnnotatedFilesNewTest","../feature_list", 
# 	 "results/crf_feature_SDU079", crf_sequence_length= 10, overlap_window_length = 2, window_size = 15, options )


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
