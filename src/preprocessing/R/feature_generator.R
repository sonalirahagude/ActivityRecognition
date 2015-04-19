# author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module contains functions to generate the CRF feature file to be directly used by CRFSuite

# feature generator for the CRF. 
# every line in the output file consists of features for a particular time step in the CRF sequence and every sequence is contained with a START-END pair
generate_features= function( feature_list_file, output_file, sequence, labels) {
	feature_functions = read.csv(file.path(feature_list_file), stringsAsFactors=FALSE)	
	output_file  = file.path(output_file)
	# mark start of a new sequence in the output file
	cat('START\n', file=output_file, append=TRUE)
	for(i in 1:nrow(sequence)) {
		for(feature_function in feature_functions) {
			feature_value = do.call(feature_function, list(sequence, i))
			# write the returned feature value to output file
			
			label = labels[i]
			cat(feature_value, label, sep=",", file=output_file, append=TRUE)
			
			#cat(label,  sep=",", file=output_file, append=TRUE)    	
		}
		cat('\n', file=output_file, append=TRUE)	
	}
	# mark end of a new sequence in the output file
	cat('END\n', file=output_file, append=TRUE)
	
}

# generate a matrix for the sequence
# arguments
# feature_file: contains the original features at window_size rate <feature1, feature2,...featuren, label>
# feature_list_file: contains list of names of feature functions to be used to generate features
# output_feature_file: file to write the CRF compliant features to
# sequence_length: length of a CRF sequence
# overlap_window_length: if using sliding window to generate sequences, tells how many time steps to overlap between two consecutive windows
generate_sequences_from_raw_data = function( feature_dir, label_dir, feature_list_file, output_feature_file, sequence_length = 10, overlap_window_length = 0, window_size =15 ) {
	
	if (file.exists( file.path(output_feature_file) )) {
      file.remove(output_feature_file)
    }
	
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

	# discard training points for whom labels are unavailable
	labels = labels$behavior
	print(labels)
	print ("aaaaaa")
	print(typeof(labels))
	plain_features = plain_features[labels!="NULL", ]
	labels = labels[labels!="NULL"]

	# sequence_length - overlap_window_length will take care of sliding window
	for (i in seq(1, nrow(plain_features), sequence_length - overlap_window_length)) {
		seq_end = i + sequence_length - 1
		if (i + sequence_length -1 > nrow(plain_features)) {
			seq_end = nrow(plain_features)
		}
		sequence = generate_features(feature_list_file, output_feature_file, plain_features[i:seq_end,], as.vector(labels[i:seq_end]) )
	}
}

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