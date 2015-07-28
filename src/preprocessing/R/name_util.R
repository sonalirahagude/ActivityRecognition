# Author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module contains functions to generate the CRF input directory according to the arguments passed to the feature generator

create_crf_dir = function(feature_list_file_path, crf_sequence_length, sliding_window_length, interval_length_in_sec, options) {
	
	output_crf_dir = get_crf_dir_name(crf_sequence_length, sliding_window_length, interval_length_in_sec) 

	# if (file.exists(file.path(output_crf_dir) )) {
 #      delete_dir(output_crf_dir)
 #    }
    dir.create(output_crf_dir)
    output_crf_file = paste0 (output_crf_dir, '/all')
	generate_header(feature_list_file_path, output_crf_file, options) 
	return (output_crf_file)
}

get_crf_dir_name = function(crf_sequence_length, sliding_window_length, interval_length_in_sec) {	
	output_crf_dir = paste0('results/', crf_sequence_length, '_seqLength_',
			  sliding_window_length, '_overlap_', interval_length_in_sec, '_sec_interval')
}


delete_dir = function (dir_name) {
	files = list.files(dir_name)
	for (file in files) {
		cat("removing file: ", file, "\n")
		file.remove(file)
	}
	file.remove(dir_name)
}

get_trip_point = function(fix_type) {
	fix_type_tokens = unlist(strsplit(fix_type,'+',fixed=TRUE))
	trip_points = c('stationary', 'startpoint', 'pausepoint', 'midpoint', 'endpoint')

	if(length(fix_type_tokens) < 2) {
		print("no trip_point. Substituting with stationary")
		trip_point = 'stationary'			
	}
	else {
		trip_point = str_trim(fix_type_tokens[2])
		if (!(trip_point %in% trip_points)) {
			if (length(fix_type_tokens) > 3) {
				trip_point = str_trim(unlist(strsplit(fix_type,'+',fixed=TRUE))[3])
				print (trip_point)
				if (!(trip_point %in% trip_points)) {
					cat("unknown trip_point: ", trip_point, ". Substituting with stationary\n")
					trip_point = 'stationary'
				}
			}
			else {
				trip_point = 'stationary'
			}
		}			
	}
	return (trip_point)
}