# Author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module contains functions to generate the CRF feature file to be directly used by CRFSuite

# feature generator for the CRF. 
# every line in the output file consists of features for a particular token in the CRF sequence and every sequence is contained with a START-END pair
# <token label> \t <token attribute1 name: tokan attribute1 value> \t <token attribute2 name: tokan attribute2 value> ....
generate_features= function( feature_list_file, output_file_name, options, sequence, participant_file_list) {
	conn = file(feature_list_file,open = 'r')
	feature_functions = readLines(conn)	
	
	output_file  = file.path(output_file_name)
	labels = as.vector(sequence$behavior)

	# start writing to the individual participant file simultaneously
	participants = as.vector(sequence$participant)
	first_participant = participants[1]
	participant_output_file_name = paste0(output_file_name,"_", first_participant)
	participant_output_file = file.path(participant_output_file_name)
	if(participant_output_file_name %in% participant_file_list) {		
	} else {
		participant_file_list = append(participant_file_list, participant_output_file_name)
		generate_header(feature_list_file, participant_output_file_name, options)
	}
	
	# mark start of a new sequence in the output file
	cat('#START\n', file=output_file, append=TRUE)
	cat('#START\n', file=participant_output_file, append=TRUE)
	for(i in 1:nrow(sequence)) {
		label = labels[i]
		participant = participants[i]
		if(participant != first_participant ) {
			cat('#END\n', file=participant_output_file, append=TRUE)
			participant_output_file_name = paste0(output_file_name,"_", participant)
			first_participant = participant
			participant_output_file = file.path(participant_output_file_name)
			if(participant_output_file_name %in% participant_file_list) {		
			} else {
				participant_file_list = append(participant_file_list, participant_output_file_name)
				generate_header(feature_list_file, participant_output_file_name, options)
			}
			cat('#START\n', file=participant_output_file, append=TRUE)	
		}
		
		cat(label,'\t', sep="", file=output_file, append=TRUE)	
		cat(label,'\t', sep="", file=participant_output_file, append=TRUE)	
		
		cat(participant,'\t', sep="", file=output_file, append=TRUE)	
		cat(participant,'\t', sep="", file=participant_output_file, append=TRUE)				

		for(feature_function in feature_functions) {
			# ignore comments in the feature list file
			if (startsWith(feature_function, '#', trim=TRUE) | trim(feature_function) == '')
				next
			#cat("Calling " , feature_function,"\n")
			feature_value = do.call(feature_function, list(sequence, i, labels, options))
			# write the returned feature value to output file			
			cat(feature_value, "\t", sep="", file=output_file, append=TRUE)		
			cat(feature_value, "\t", sep="", file=participant_output_file, append=TRUE)		

		}
		cat('\n', file=output_file, append=TRUE)			
		cat('\n', file=participant_output_file, append=TRUE)			

	}
	# mark end of a new sequence in the output file
	cat('#END\n', file=output_file, append=TRUE)
	cat('#END\n', file=participant_output_file, append=TRUE)
	close(conn)	
	return (participant_file_list)
}

# Generates and writes CRF compliant features to a file
# Arguments:
## feature_dirs: list of directories that contain the original/raw observation files at desired window_size rate 
## feature_list_file: contains list of names of feature functions to be used to generate features
## output_feature_file: file to write the CRF compliant features to, will contain the original features at window_size rate <label, feature1, feature2,...featuren>
## crf_sequence_length: length of a CRF sequence
## overlap_window_length: if using sliding window to generate sequences, tells how many time steps to overlap between two consecutive windows
generate_sequences_from_raw_data = function( feature_dirs, label_dir, feature_list_file, output_feature_file, crf_sequence_length = 10, overlap_window_length = 0, window_size =15, options ) {
	for(feature_dir in feature_dirs) {
		if(!file.exists(feature_dir)) {
			stop("Feature directory not found: " , feature_dir)
		}
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
	generate_header(feature_list_file, output_feature_file, options) 

	plain_features = data.frame()
	for(feature_dir in feature_dirs) { 
		cat("Exracting features from: " , feature_dir, "\n")
		if(file.info(feature_dir)$isdir) {			
			features = read_from_dir(feature_dir)
		}
		else {
			features = read_from_file(feature_dir)
		}
		if(nrow(plain_features) == 0) {
			plain_features = features
		}
		else {
			# make the date formate same 
			#print(t(plain_features[1, ]$timestamp))	
			date_format = get_date_format(toString(plain_features[1, ]$timestamp))
			plain_features$timestamp = strptime(plain_features$timestamp, date_format)
			features$timestamp = strptime(features$timestamp, date_format)

			if("participant" %in% colnames(plain_features) & "participant" %in% colnames(features) ) {
				plain_features = merge (plain_features, features,  by.x=c("participant","timestamp"), by.y=c("participant","timestamp"), all=FALSE, sort=FALSE)
			}
			else {
				plain_features = merge (plain_features, features,  by.x=c("timestamp"), by.y=c("timestamp"), all=FALSE, sort=FALSE)	
			}
		}		
	}
	if(nrow(plain_features) == 0) {
		stop("Feature merge failed. Please check the feature directories.", feature_dirs)
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
	# make the date formate same 
	date_format = get_date_format(toString(plain_features[1, ]$timestamp))
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
	participant_file_list = list()
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
		participant_file_list = generate_features(feature_list_file, output_feature_file, options, plain_features[i:seq_end,] , participant_file_list)
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
    		# Set check.names=FALSE, else strings starting with numbers in the header will be read as 25thp -- X25thp
    		feats = read.csv(file, header=TRUE, stringsAsFactors=TRUE, check.names=FALSE)
    		# add the participant name so that it can be used during merging
    		feats[,'participant'] = rep(names[i], times = nrow(feats))    		
    		if("dateTime" %in% colnames(feats)) {
				feats = rename(feats,c("dateTime"="timestamp"))
			}		
			all_feats = rbind(all_feats, feats)    		
    	}
	}
	return(all_feats)
}

read_from_file = function (file) {
	feats = read.csv(file, header=TRUE, stringsAsFactors=TRUE, check.names=FALSE)
	if("identifier" %in% colnames(feats)) {
		feats = rename(feats,c("identifier"="participant"))
	}
	if("dateTime" %in% colnames(feats)) {
		feats = rename(feats,c("dateTime"="timestamp"))
	}
	return (feats)
}

# Checks if two data points contiguous in the input file are contiguous in time too
is_immediate_data_point = function (prev_timestamp, cur_timestamp, date_format, window_size) {
	if(as.numeric(difftime(cur_timestamp, prev_timestamp, units="secs") )== window_size) {
		return(TRUE)
	} 
	return(FALSE)
}