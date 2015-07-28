# Author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module contains functions to generate the CRF feature file to be directly used by CRFSuite

# feature generator for the CRF. 
# every line in the output file consists of features for a particular token in the CRF sequence and every sequence is contained with a START-END pair
# <token label> \t <token attribute1 name: tokan attribute1 value> \t <token attribute2 name: tokan attribute2 value> ....
generate_features= function( feature_list_file, output_file_name, options, sequence, actual_seq_length, participant_file_list) {
	conn = file(feature_list_file,open = 'r')
	feature_functions = readLines(conn)	
	output_file  = file.path(output_file_name)
	labels = as.vector(sequence$behavior)

	# start writing to the individual participant file simultaneously
	participants = as.vector(sequence$participant)
	first_participant = str_trim(participants[1])
	participant_output_file_name = paste0(output_file_name,"_", first_participant)
	participant_output_file = file.path(participant_output_file_name)
	
	if(participant_output_file_name %in% participant_file_list) {		
	} else {
		participant_file_list = append(participant_file_list, participant_output_file_name)
		generate_header(feature_list_file, participant_output_file_name, options)
	}
	
	# mark start of a new sequence in the output file
	cat('#START:', actual_seq_length, '\n', file=output_file, append=TRUE)
	cat('#START:', actual_seq_length, 	'\n', file=participant_output_file, append=TRUE)
	for(i in 1:nrow(sequence)) {
		label = labels[i]
		participant = participants[i]
		
		cat(label, sep="", file=output_file, append=TRUE)	
		cat(label, sep="", file=participant_output_file, append=TRUE)	
		
		cat('\t', participant, sep="", file=output_file, append=TRUE)	
		cat('\t', participant, sep="", file=participant_output_file, append=TRUE)				

		for(feature_function in feature_functions) {
			# ignore comments in the feature list file
			if (startsWith(feature_function, '#', trim=TRUE) | trim(feature_function) == '')
				next
			feature_value = do.call(feature_function, list(sequence, i, labels, options))

			# write the returned feature value to output file			
			cat('\t', feature_value, sep="", file=output_file, append=TRUE)		
			cat('\t', feature_value, sep="", file=participant_output_file, append=TRUE)		

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
## sensor_data_dirs: list of directories that contain the original/raw observation files at desired interval_length_in_sec rate 
## feature_list_file: contains list of names of feature functions to be used to generate features
## output_crf_file: file to write the CRF compliant features to, will contain the original features at interval_length_in_sec rate <label, feature1, feature2,...featuren>
## crf_sequence_length: length of a CRF sequence
## sliding_window_length: if using sliding window to generate sequences, tells how many time steps to overlap between two consecutive windows
generate_sequences_from_raw_data = function( sensor_data_dirs, label_dir, feature_list_file, crf_sequence_length = 10, 
		sliding_window_length = 0, interval_length_in_sec =15, options ) {
	for(sensor_dir in sensor_data_dirs) {
		if(!file.exists(sensor_dir)) {
			stop("Feature directory not found: " , sensor_dir)
		}
	}
	if(!file.exists(label_dir)) {
		stop("Labels directory not found")
	}
	if(!file.exists(feature_list_file)) {
		stop("Feature functions list not found")
	}

	output_crf_file = create_crf_dir(feature_list_file, crf_sequence_length, sliding_window_length, interval_length_in_sec, options)

	bin_file_name = paste0(get_crf_dir_name(crf_sequence_length, sliding_window_length, interval_length_in_sec), '/all_sensor_data.Rdata')
	if(file.exists(bin_file_name)) {
		load(bin_file_name)
	}
	else {
		all_sensor_data = load_sensor_data(sensor_data_dirs, interval_length_in_sec)

		labels = load_labels(label_dir, interval_length_in_sec)

		all_sensor_data = merge_data_and_labels(all_sensor_data, labels)
		
		save(all_sensor_data, file=bin_file_name)
	}
	#generate_fixed_length_sequences(all_sensor_data,crf_sequence_length, feature_list_file, output_crf_file, options )
	generate_PALMS_sequences(all_sensor_data, feature_list_file, output_crf_file, options )
}

generate_PALMS_sequences = function(all_sensor_data, feature_list_file, output_crf_file, options ) {
	participant_file_list = list()
	# The below logic detects if 2 consecutive data points are non contiguous in time,
	# if so, it starts a new CRF sequence for the later data point, with no overlap.
	i = 1
	seq_start = i
	prev_startpoint = -1
	last_written_index = -1
	cur_participant = 'dummy'
	while(i <= nrow(all_sensor_data) ) {
		participant = toString(all_sensor_data[i, ]$participant)
		if(cur_participant != participant) {
			cur_participant = participant
			# write everything  upto now
			if((i - last_written_index) > 1 && last_written_index!= -1) {
				if(seq_start != last_written_index +1 ) {
					stop("seq_start: ", seq_start ,	" and last_written_index: ", last_written_index, " dont match")
				}
				cat ("incomplete sequence encountered. last_written_index: ", last_written_index,"i: " , i, "\n")
				start = last_written_index + 1
				end = i - 1
				cat("start: " , start, ", end: " , end, "\n")
				participant_file_list = generate_features(feature_list_file, output_crf_file, options, all_sensor_data[start: end,] , 
					i - last_written_index - 1, participant_file_list)
				last_written_index = i-1
			}
		}
		fix_type = toString(all_sensor_data[i, ]$fixType)
		trip_point = get_trip_point(fix_type)
		
		if (trip_point == 'stationary') { 
			stationary_start = i
			# if there was no end point, then write from seq_start until now
			if((i - last_written_index) > 1 && last_written_index!= -1) {
				if(seq_start != last_written_index +1 ) {
					stop("seq_start: ", seq_start ,	" and last_written_index: ", last_written_index, " dont match")
				}
				cat ("incomplete sequence encountered. last_written_index: ", last_written_index,"i: " , i, "\n")
				start = last_written_index + 1
				end = i - 1
				cat("start: " , start, ", end: " , end, "\n")
				participant_file_list = generate_features(feature_list_file, output_crf_file, options, all_sensor_data[start: end,] , 
					i - last_written_index - 1, participant_file_list)
				last_written_index = i-1				
			}
			while (trip_point == 'stationary' && cur_participant == participant) {
				i = i + 1
				fix_type = toString(all_sensor_data[i, ]$fixType)
				participant = toString(all_sensor_data[i, ]$participant)
				trip_point = get_trip_point(fix_type)
			}
			i = i - 1
			participant_file_list = generate_features(feature_list_file, output_crf_file, options, all_sensor_data[stationary_start:i,] , 
					i - stationary_start + 1, participant_file_list)
			last_written_index = i

		}
		else if (trip_point == 'startpoint') {
			# there can be consecutive startpoints in the palms file, in this case, dont change the sequence startpoints
			if(i - prev_startpoint == 1) {
				prev_startpoint = i
			} 
			else {
				# if there was no end point, then write from seq_start until now
				# may happen because we discard some points while merging gps with accelerometer data and label data
				if((i - last_written_index) > 1 && last_written_index!= -1) {
					if(seq_start != last_written_index +1 ) {
						stop("seq_start: ", seq_start ,	" and last_written_index: ", last_written_index, " dont match")
					}
					cat ("incomplete,sequence encountered. last_written_index: ", last_written_index,"i: " , i, "\n")
					start = last_written_index + 1
					end = i - 1
					participant_file_list = generate_features(feature_list_file, output_crf_file, options, all_sensor_data[start: end,] , 
						i - last_written_index - 1, participant_file_list)
					last_written_index = i-1
				}
				cat("Setting seq_start to: " , i, "\n")
				seq_start = i
				prev_startpoint = i
			}
		}
		else if(trip_point == 'pausepoint') {
			# if there was no startpoint, start here
			if(seq_start < last_written_index ) {
				seq_start = i
			}
			pause_start = i
		}
		else if (trip_point == 'midpoint') {
			# if there was startpoint, start here
			if(seq_start < last_written_index ) {
				seq_start = i
			}
		}
		else if (trip_point == 'endpoint') {
			if(last_written_index > seq_start) {
				cat ("endpoint encountered without start. seq_start: ", seq_start,"i: " , i, "\n")
				participant_file_list = generate_features(feature_list_file, output_crf_file, options, all_sensor_data[i,] ,
					 1, participant_file_list)
			
			} 
			else {
				cat ("endpoint encountered. seq_start: ", seq_start,"i: " , i, "\n")
				participant_file_list = generate_features(feature_list_file, output_crf_file, options, all_sensor_data[seq_start:i,] ,
					 i - seq_start + 1, participant_file_list)
			}
			last_written_index = i
		}
		else {
			cat('Found unknown trip point: ' , trip_point, "\n")
		}
		i = i + 1
	}
}




generate_fixed_length_sequences = function(all_sensor_data,crf_sequence_length, feature_list_file, output_crf_file, options ){
	participant_file_list = list()
	# The below logic detects if 2 consecutive data points are non contiguous in time,
	# if so, it starts a new CRF sequence for the later data point, with no overlap.
	i = 1
	participant = toString(all_sensor_data[1, ]$participant)
	gap_threshold_for_seq_cutoff = options[['gap_threshold_for_seq_cutoff']]
	
	while(i <= nrow(all_sensor_data) ) {
		max_seq_end = i + crf_sequence_length - 1
		if(max_seq_end > nrow(all_sensor_data)) {
			max_seq_end = nrow(all_sensor_data)
		}
		participant = toString(all_sensor_data[i, ]$participant)
		seq_end = i
		while(seq_end < max_seq_end) {
			cur_participant = toString(all_sensor_data[seq_end+1, ]$participant)
			if(is_immediate_data_point(all_sensor_data[seq_end, ]$timestamp, all_sensor_data[seq_end + 1, ]$timestamp, date_format, gap_threshold_for_seq_cutoff)  && cur_participant == participant)  {
				seq_end = seq_end + 1
				participant = cur_participant

			} else {
				break
			}
		}
		participant_file_list = generate_features(feature_list_file, output_crf_file, options, all_sensor_data[i:seq_end,] , seq_end - i + 1, participant_file_list)
		# While incrementing i, if there was no cut off, then we can overlap the next sequence with tokens from the previous sequence,
		# else we have to start a fresh new sequence with no overlap
		if( seq_end == max_seq_end) {			
			i = i + crf_sequence_length - sliding_window_length
		}
		else {
			i = seq_end + 1
		}
	}
}

# Checks if two data points contiguous in the input file are contiguous in time too
is_immediate_data_point = function (prev_timestamp, cur_timestamp, date_format, gap_threshold) {
	if(as.numeric(difftime(cur_timestamp, prev_timestamp, units="secs") ) <= gap_threshold) {
		return(TRUE)
	} 
	return(FALSE)
}