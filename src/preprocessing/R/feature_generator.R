# Author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module contains functions to generate the CRF feature file to be directly used by CRFSuite

# feature generator for the CRF. 
# every line in the output file consists of features for a particular token in the CRF sequence and every sequence is contained with a START-END pair
# <token label> \t <token attribute1 name: tokan attribute1 value> \t <token attribute2 name: tokan attribute2 value> ....
generate_features= function( feature_list_file, output_file, options, sequence, labels) {
	#feature_functions = read.csv(file.path(feature_list_file), stringsAsFactors=FALSE)	
	conn = file(feature_list_file,open = 'r')
	feature_functions = readLines(conn)	
	output_file  = file.path(output_file)
	# mark start of a new sequence in the output file
	cat('START\n', file=output_file, append=TRUE)
	for(i in 1:nrow(sequence)) {
		label = labels[i]
		cat(label,'\t', sep="", file=output_file, append=TRUE)	
		for(feature_function in feature_functions) {
			feature_value = do.call(feature_function, list(sequence, i, labels, options))
			# write the returned feature value to output file			
			cat(feature_value, "\t", sep="", file=output_file, append=TRUE)		
		}
		cat('\n', file=output_file, append=TRUE)			
	}
	# mark end of a new sequence in the output file
	cat('END\n', file=output_file, append=TRUE)
	close(conn)
	
}

# Generates and writes CRF compliant features to a file
# Arguments:
## @feature_file: contains the original features at window_size rate <feature1, feature2,...featuren, label>
## feature_list_file: contains list of names of feature functions to be used to generate features
## plain_features_file: contains list of names of features to be directly included as a feature function
## output_feature_file: file to write the CRF compliant features to
## crf_sequence_length: length of a CRF sequence
## overlap_window_length: if using sliding window to generate sequences, tells how many time steps to overlap between two consecutive windows
generate_sequences_from_raw_data = function( feature_dir, label_dir, feature_list_file, plain_features_file, output_feature_file, crf_sequence_length = 10, overlap_window_length = 0, window_size =15 ) {
	if(!file.exists(feature_dir)) {
		stop("Feature directory not found")
	}

	if(!file.exists(label_dir)) {
		stop("Labels directory not found")
	}
	if(!file.exists(feature_list_file)) {
		stop("Feature functions list not found")
	}

	if (file.exists( file.path(output_feature_file) )) {
      file.remove(output_feature_file)
    }

	options = list(plain_features_list = plain_features_file)	
	if(file.info(feature_dir)$isdir) {
		plain_features = read_from_dir(feature_dir)
	}
	else {
		plain_features = read_from_file(feature_dir)
	}
	
	if(file.info(label_dir)$isdir) {
		aligned_labels_dir = paste0(label_dir, "_aligned")
		if (!file.exists(aligned_labels_dir)) {
			align_labels(label_dir, aligned_labels_dir, window_size)
		}
		labels = read_from_dir(aligned_labels_dir)
	}
	else {
		labels = read_from_file(label_dir)
	}

	# discard training points for whom the corresponding labels are unavailable
	labels = labels$behavior
	plain_features = plain_features[labels!="NULL", ]
	labels = labels[labels!="NULL"]

	# The below logic detects if 2 consecutive data points are non contiguous in time,
	# if so, it starts a new CRF sequence for the later data point, with no overlap.
	i = 1
	date_format = get_date_format(plain_features[1, ]$dateTime)
	while(i <= nrow(plain_features) ) {
		max_seq_end = i + crf_sequence_length - 1
		if(max_seq_end > nrow(plain_features)) {
			max_seq_end = nrow(plain_features)
		}

		seq_end = i
		while(seq_end < max_seq_end) {
			if(is_immediate_data_point(plain_features[seq_end, ]$dateTime, plain_features[seq_end + 1, ]$dateTime, date_format, window_size) )  {
				seq_end = seq_end + 1
			} else {
				break
			}
		}
		sequence = generate_features(feature_list_file, output_feature_file, options, plain_features[i:seq_end,], as.vector(labels[i:seq_end]) )
		# While incrementing i, if there was no cut off, then we can overlap the next sequence with tokens from the previous sequence,
		# else we have to start a fresh new sequence with no overlap
		if( seq_end == max_seq_end) {			
			i = i + crf_sequence_length - overlap_window_length
		}
		else {
			i = seq_end + 1
		}
	}
}

# Reads the features into a single dataframe
# assumes that the directory structure is: dir -> participant_dir -> date-file
read_from_dir = function(dir, names = NULL) {
	if (is.null(names)) {
		names = list.files(dir)
	}

	if (length(names) == 0) {
		return(NULL)
	}
	all_feats = data.frame()
	for (i in 1:length(names)) {
		days = list.files(file.path(dir, names[i]))
    	# if the participant directory is empty, skip this
    	if (length(days) == 0) {
    		next
    	}
    	for (k in 1:length(days)) {
    		file = file.path(dir, names[i], days[k])
    		feats = read.csv(file, header=TRUE, stringsAsFactors=TRUE)
    		all_feats = rbind(all_feats, feats)
    	}
	}
return(all_feats)
}

read_from_file = function (file) {
	feats = read.csv(file, header=TRUE, stringsAsFactors=TRUE)
	return (feats)
}

# Checks if two data points contiguous in the input file are contiguous in time too
is_immediate_data_point = function (time_string_1, time_string_2, date_format, window_size) {
	prev_timestamp = strptime(str_trim(time_string_1), date_format)
	cur_timestamp = strptime(str_trim(time_string_2), date_format)
	if(as.numeric(difftime(cur_timestamp, prev_timestamp, units="secs")) == window_size) {
		return(TRUE)
	} 
	return(FALSE)
}