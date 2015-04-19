# set the working directory to the directory of this folder
print("test")
print(getwd())
source('../setup.R')
generate_sequences_from_raw_data( "sample_gps", "sample_label","../feature_list", "../plain_features_list", "crf_feature", crf_sequence_length= 5, overlap_window_length = 1, window_size = 15 )
#generate_sequences_from_raw_data( "sample_gps", "sample_label","../feature_list", "../plain_features_list", "crf_feature_no_overlap", crf_sequence_length= 5, overlap_window_length = 0, window_size = 15 )

# test sequence cut-off logic for non contiguous sample points
generate_sequences_from_raw_data( "sample_gps_disjoint", "sample_label_disjoint","../feature_list", "../plain_features_list", "crf_feature_disjoint", crf_sequence_length= 6, overlap_window_length = 2, window_size = 15 )