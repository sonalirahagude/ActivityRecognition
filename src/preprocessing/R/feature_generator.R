# Author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module contains functions to generate the CRF feature file to be directly used by CRFSuite

# feature generator for the CRF. 
# every line in the output file consists of features for a particular token in the CRF sequence and every sequence is contained with a START-END pair
# <token label> \t <token attribute1 name: tokan attribute1 value> \t <token attribute2 name: tokan attribute2 value> ....
generate_features= function( feature_list_file, output_file, options, sequence) {
	#feature_functions = read.csv(file.path(feature_list_file), stringsAsFactors=FALSE)	
	conn = file(feature_list_file,open = 'r')
	feature_functions = readLines(conn)	
	output_file  = file.path(output_file)
	labels = as.vector(sequence$behavior)
	# mark start of a new sequence in the output file
	cat('#START\n', file=output_file, append=TRUE)
	for(i in 1:nrow(sequence)) {
		label = labels[i]
		cat(label,'\t', sep="", file=output_file, append=TRUE)	
		for(feature_function in feature_functions) {
			# ignore comments in the feature list file
			if (startsWith(feature_function, '#', trim=TRUE) | trim(feature_function) == '')
				next
			#cat("Calling " , feature_function,"\n")
			feature_value = do.call(feature_function, list(sequence, i, labels, options))
			# write the returned feature value to output file			
			cat(feature_value, "\t", sep="", file=output_file, append=TRUE)		
		}
		cat('\n', file=output_file, append=TRUE)			
	}
	# mark end of a new sequence in the output file
	cat('#END\n', file=output_file, append=TRUE)
	close(conn)	
}

generate_header = function(plain_features_file, feature_list_file, output_feature_file) {
	conn = file(feature_list_file,open = 'r')
	feature_functions = readLines(conn)	
	print(output_feature_file)
	output_file = file.path(output_feature_file)
	cat("label", "\t", sep="", file=output_feature_file, append=TRUE)		
	for (feature_function in feature_functions) {
		# ignore comments in the feature list file
		if (startsWith(feature_function, '#', trim=TRUE) | trim(feature_function) == '')
			next
		if(feature_function == "plain_features") {
			plain_features_list = get_plain_features(plain_features_file)
			cat(plain_features_list, sep="", file=output_file, append=TRUE)		
		}
		else {
			cat(feature_function, "\t", sep="", file=output_file, append=TRUE)	
		}
	}
	cat('\n', file=output_file, append=TRUE)	
}

get_plain_features  = function(plain_features_file) {
	conn = file(plain_features_file, open = 'r')
    plain_features = readLines(conn) 
   	plain_features_list = ""
    for (plain_feature in plain_features) {
    	# ignore comments in the feature list file
		if (startsWith(plain_feature, '#', trim=TRUE) | trim(plain_feature) == '')
			next
    	plain_features_list = paste0(plain_features_list,plain_feature,"\t")
	}
	return (plain_features_list)
}

# Generates and writes CRF compliant features to a file
# Arguments:
## @feature_file: contains the original features at window_size rate <feature1, feature2,...featuren, label>
## feature_list_file: contains list of names of feature functions to be used to generate features
## plain_features_file: contains list of names of features to be directly included as a feature function
## output_feature_file: file to write the CRF compliant features to
## crf_sequence_length: length of a CRF sequence
## overlap_window_length: if using sliding window to generate sequences, tells how many time steps to overlap between two consecutive windows
generate_sequences_from_raw_data = function( feature_dirs, label_dir, feature_list_file, plain_features_file, output_feature_file, crf_sequence_length = 10, overlap_window_length = 0, window_size =15 ) {
	if(!file.exists(feature_dirs)) {
		stop("Feature directory not found: " , feature_dirs)
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
	generate_header(plain_features_file, feature_list_file, output_feature_file) 

	options = list(plain_features_list = plain_features_file)	
	if(file.info(feature_dirs)$isdir) {
		plain_features = data.frame()
		for(feature_dir in feature_dirs) { 
			cat("Exracting features from: " , feature_dir, "\n")
			#single_feature =  read_from_dir(feature_dir)
			plain_features = rbind(plain_features, read_from_dir(feature_dir))
		}
	}
	else {
		plain_features = read_from_file(feature_dirs)
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

	#---------------------
	#date_format = get_date_format(plain_features[1, ]$dateTime)
	date_format = get_date_format(plain_features[1, ]$timestamp)
	#---------------------
	# first fomat the labels timestamp in the same format as features so that we can merge on the timestamp
	labels$timestamp = strptime(labels$timestamp, date_format)

	#---------------------
	#plain_features$dateTime = strptime(plain_features$dateTime, date_format)
	#plain_features = merge (plain_features, labels,  by.x=c("participant","dateTime"), by.y=c("participant","timestamp"), all=FALSE, sort=FALSE)
	
	plain_features$timestamp = strptime(plain_features$timestamp, date_format)
	if("participant" %in% colnames(plain_features) & "participant" %in% colnames(labels) ) {
		plain_features = merge (plain_features, labels,  by.x=c("participant","timestamp"), by.y=c("participant","timestamp"), all=FALSE, sort=FALSE)
	}
	else {
		plain_features = merge (plain_features, labels,  by.x=c("timestamp"), by.y=c("timestamp"), all=FALSE, sort=FALSE)	
	}
	#---------------------
	# discard training points for whom the corresponding labels are unavailable
	plain_features = plain_features[plain_features$behavior!="NULL", ]
	
	# The below logic detects if 2 consecutive data points are non contiguous in time,
	# if so, it starts a new CRF sequence for the later data point, with no overlap.
	i = 1
	
	while(i <= nrow(plain_features) ) {
		max_seq_end = i + crf_sequence_length - 1
		if(max_seq_end > nrow(plain_features)) {
			max_seq_end = nrow(plain_features)
		}

		seq_end = i
		while(seq_end < max_seq_end) {
			#---------------------
			#if(is_immediate_data_point(plain_features[seq_end, ]$dateTime, plain_features[seq_end + 1, ]$dateTime, date_format, window_size) )  {
			if(is_immediate_data_point(plain_features[seq_end, ]$timestamp, plain_features[seq_end + 1, ]$timestamp, date_format, window_size) )  {
			#---------------------
				seq_end = seq_end + 1
			} else {
				break
			}
		}
		sequence = generate_features(feature_list_file, output_feature_file, options, plain_features[i:seq_end,] )
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
		cat("Could not find files in directory: " , dir,". Either the directory is empty or it does not exist.\n")
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
    		# add the participant name so that it can be used during merging
    		feats[,'participant'] = rep(names[i], times = nrow(feats))
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
is_immediate_data_point = function (prev_timestamp, cur_timestamp, date_format, window_size) {
	if(as.numeric(difftime(cur_timestamp, prev_timestamp, units="secs") )== window_size) {
		return(TRUE)
	} 
	return(FALSE)
}