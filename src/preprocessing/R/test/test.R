# set the working directory to the directory of this folder
print("test")
print(getwd())
source('../setup.R')
#generate_sequences_from_raw_data( "sample_gps", "sample_label","../feature_list", "../plain_features_list", "crf_feature", crf_sequence_length= 5, overlap_window_length = 1, window_size = 15 )
#generate_sequences_from_raw_data( "sample_gps", "sample_label","../feature_list", "../plain_features_list", "crf_feature_no_overlap", crf_sequence_length= 5, overlap_window_length = 0, window_size = 15 )

# test sequence cut-off logic for non contiguous sample points
#generate_sequences_from_raw_data( "sample_gps_disjoint", "sample_label_disjoint","../feature_list", "../plain_features_list", "crf_feature_disjoint", crf_sequence_length= 6, overlap_window_length = 2, window_size = 15 )


# generate training crf file
#generate_sequences_from_raw_data( "../data/GPS_SDU079.csv", "../data/AnnotatedFilesNew_aligned/SDU079/2011-07-13.csv","../feature_list", "../plain_features_list", "crf_feature_SDU079", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15 )

# generate test crf file
#generate_sequences_from_raw_data( "../data/GPS_SDU080.csv", "../data/AnnotatedFilesNew_aligned/SDU080/2011-07-14.csv","../feature_list", "../plain_features_list", "crf_feature_SDU080", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15 )

#generate_sequences_from_raw_data( "../data/GPS_SDU082.csv", "../data/AnnotatedFilesNew_aligned/SDU082/2011-07-14.csv","../feature_list", "../plain_features_list", "crf_feature_SDU082", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15 )


generate_sequences_from_raw_data( "../data/GPS_SDU085.csv", "../data/AnnotatedFilesNew_aligned/SDU085/2011-07-09.csv","../feature_list", "../plain_features_list", "crf_feature_SDU085", crf_sequence_length= 10, overlap_window_length = 5, window_size = 15 )
