# Author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module contains functions to scale the crf input files created by the feature generator


# scales the generated crf input files
do_min_max_scaling = function(crf_sequence_length, sliding_window_length, interval_length_in_sec) {
    input_crf_dir = get_crf_dir_name(crf_sequence_length, sliding_window_length, interval_length_in_sec) 
	input_crf_dir = paste0(input_crf_dir, '_minmax_singleCRF')
    input_crf_file_all = paste0 (input_crf_dir, '/all')

    # set global option for digits to 4. (Will print only upto 3 decimal places)
	options(digits=5)
    feats = read.csv(input_crf_file_all, header=TRUE, sep = "\t", stringsAsFactors=FALSE, check.names=FALSE, strip.white=TRUE, comment.char='#', na.strings="NA")
    feats[is.na(feats)]=0

    headers = colnames(feats)
	excluded_headers = c("label","participant","timestamp")
	included_headers = headers[!headers %in% excluded_headers]
 	
    min_max = array(0.0, dim = c(2,length(included_headers)), dimnames=list( c('min','max'),included_headers ))

    for (feature_name in included_headers) {
    	min_max['min',feature_name] = as.numeric(min(feats[,feature_name]))
    	min_max['max',feature_name] = as.numeric(max(feats[,feature_name]))
    }
    print(min_max)
    input_file_names = list.files(input_crf_dir)
	print(input_file_names)

    for (input_file_name in input_file_names) {
    	cat('Scaling features for file: ',input_file_name,'\n')

    	input_file = file.path(input_crf_dir, input_file_name)
    	scaled_input_file = paste0(input_crf_dir, '/', 'scaled_', input_file_name)
		if(file.exists(scaled_input_file)) {
    		file.remove(scaled_input_file)
    	}

    	conn = file(input_file,open = 'r')
		lines = readLines(conn)	
		feats = array(0.0, dim = c(1,length(headers)), dimnames=list( c('val'),headers ))
		for(line in lines) {
			if (startsWith(line, '#START', trim=TRUE) | startsWith(line, '#END', trim=TRUE) | startsWith(line, 'label', trim=TRUE) ) {
				write(line, file = scaled_input_file, append=TRUE)
				next
			}
			feats['val',] = strsplit(line, '\t')[[1]]

		    for (feature_name in included_headers) {	    	
		    	denom = min_max['max', feature_name] - min_max['min', feature_name]
		    	if (denom == 0) {
		    		feats['val',feature_name] = 0
		    	}
		    	else {
		    		if(is.na(as.numeric(feats['val',feature_name]))) {
		    			print('found NA')
		    			feats['val',feature_name] = 0
		    		} else {
		    			feats['val',feature_name] = (as.numeric(feats['val',feature_name]) - min_max['min',feature_name]) / denom
		    		}
		    	}	    	
		    }

			cat(feats, '\n', file = scaled_input_file, sep= "\t",append=TRUE)
		}	   	
    }
}



do_R_scaling = function(crf_sequence_length, sliding_window_length, interval_length_in_sec) {
    input_crf_dir = get_crf_dir_name(crf_sequence_length, sliding_window_length, interval_length_in_sec) 
    input_crf_file_all = paste0 (input_crf_dir, '/all')

    # set global option for digits to 4. (Will print only upto 3 decimal places)
	options(digits=5)
    training_data = read.csv(input_crf_file_all, header=TRUE, sep = "\t", stringsAsFactors=FALSE, check.names=FALSE, strip.white=TRUE, comment.char='#', na.strings="NA")
    training_data[is.na(training_data)]=0
    headers = colnames(training_data)
	excluded_headers = c("label","participant","timestamp")
	feature_headers = headers[!headers %in% excluded_headers]
 	
 	feats_only = training_data[feature_headers]
 	print(typeof(feats_only))

	preProcValues = preProcess(feats_only, method = c("center","scale"))
	  
	#feats = predict(preProcValues, feats)
	input_file_names = list.files(input_crf_dir)

    for (input_file_name in input_file_names) {
    	cat('Scaling features for file: ',input_file_name,'\n')

    	input_file = file.path(input_crf_dir, input_file_name)
    	# if (endsWith(	input_file_name)
    	scaled_input_file = paste0(input_crf_dir, '/', 'scaled_', input_file_name)
		if(file.exists(scaled_input_file)) {
    		file.remove(scaled_input_file)
    	}

    	# -------------------------------------------------
      	# conn = file(input_file,open = 'r')
		# lines = readLines(conn, n = 1)
		# write(lines[[1]], file = scaled_input_file, append=TRUE)	
		# -------------------------------------------------
		skip_length = 0

		lines = read.table(input_file,  header=FALSE, sep = "", stringsAsFactors=FALSE, 
				check.names=FALSE, strip.white=TRUE, na.strings="NA", nrows=1,skip = skip_length)
		skip_length = 1
		# write the header as is
		write.table(lines, file = scaled_input_file, sep= "\t",append=TRUE, col.names=FALSE ,row.names=FALSE)
		
		while(1) {
			# lines = readLines(conn, n = 1)	
			# write(lines[[1]], file = scaled_input_file, append=TRUE)
			
			# write the start and also extract the sequence length
			lines = read.table(input_file,  header=FALSE, sep = "", stringsAsFactors=FALSE, 
				check.names=FALSE, strip.white=TRUE, na.strings="NA", nrows=1,skip = skip_length, comment.char = '$')
			
			if(length(lines) == 0)
				break
			
			write.table(lines, file = scaled_input_file, sep= "\t",append=TRUE, col.names=FALSE ,row.names=FALSE)
			
			skip_length = skip_length + 1
			actual_seq_length = as.numeric (lines[[2]])
			
			#seek(conn, where=actual_seq_length)
			training_data = read.csv(input_file, header=TRUE, sep = "\t", stringsAsFactors=FALSE, 
					check.names=FALSE, strip.white=TRUE, comment.char='#', na.strings="NA", nrows=actual_seq_length,skip = skip_length)
			colnames(training_data) = headers

			skip_length = skip_length + actual_seq_length
			#print(training_data)
			feats_only = training_data[feature_headers]
			feats_only = predict(preProcValues, feats_only)
			training_data[feature_headers] =feats_only
			write.table(training_data, file = scaled_input_file, sep= "\t",append=TRUE, col.names=FALSE,row.names=FALSE)	
			
			# now read end of the file
			
			# lines = readLines(conn, n = 1)	
			# write(lines[[1]], file = scaled_input_file, append=TRUE)
			lines = read.table(input_file,  header=FALSE, sep = ":", stringsAsFactors=FALSE, 
				check.names=FALSE, strip.white=TRUE, na.strings="NA", nrows=1,skip = skip_length, comment.char = "$")
			skip_length = skip_length + 1
			# print(lines)					
			write.table(lines, file = scaled_input_file, sep= "\t",append=TRUE, col.names=FALSE ,row.names=FALSE)
			# stop()
		}
	}
}



get_feature_header_index = function(headers, feature_headers) {
	feature_header_index = c()
	for(i in 1:length(headers)) {
		if(headers[i] %in% feature_headers ) {
			feature_header_index = c(feature_header_index,i)
		}
	}
	return (feature_header_index)
}

do_R_scaling_simple = function(crf_sequence_length, sliding_window_length, interval_length_in_sec) {
    input_crf_dir = get_crf_dir_name(crf_sequence_length, sliding_window_length, interval_length_in_sec) 
    input_crf_file_all = paste0 (input_crf_dir, '/all')

    # set global option for digits to 4. (Will print only upto 3 decimal places)
	options(digits=5)
    training_data = read.csv(input_crf_file_all, header=TRUE, sep = "\t", stringsAsFactors=FALSE, check.names=FALSE, strip.white=TRUE, comment.char='#', na.strings="NA")
    training_data[is.na(training_data)]=0
    headers = colnames(training_data)
	excluded_headers = c("label","participant","timestamp")
	feature_headers = headers[!headers %in% excluded_headers]
 	feature_header_index = get_feature_header_index(headers, feature_headers)
 	feats_only = training_data[feature_headers]
	print(feats_only[1:10,])

	preProcValues = preProcess(feats_only, method = c("center","scale"))
	print(preProcValues['mean'])
	print(preProcValues['std'])
	print(typeof(feats_only))
	feats_only = predict(preProcValues, feats_only)
	print(typeof(feats_only))
	input_file_names = list.files(input_crf_dir)
	
	training_data = array(0.0, dim = c(1,length(headers)), dimnames=list( c(1),headers ))
	feats_only = array(0.0, dim = c(1,length(feature_headers)), dimnames=list( c(1),feature_headers ))
	feats_only = as.data.frame(feats_only)
	training_data = as.data.frame(training_data)
    for (input_file_name in input_file_names) {
    	cat('Scaling features for file: ',input_file_name,'\n')

    	input_file = file.path(input_crf_dir, input_file_name)
    	scaled_input_file = paste0(input_crf_dir, '/', 'scaled_', input_file_name)
		if(file.exists(scaled_input_file)) {
    		file.remove(scaled_input_file)
    	}
    	# -------------------------------------------------
      	conn = file(input_file,open = 'r')
		lines = readLines(conn)
		# write(lines[[1]], file = scaled_input_file, append=TRUE)	
		# -------------------------------------------------
		for (line in lines) {
			if (startsWith(line, '#START', trim=TRUE) ) {
				write(line, file = scaled_input_file, append=TRUE)
				actual_seq_length = as.numeric (str_trim(strsplit(line,':')[[1]][2]))	
				next			
			}	
			if(startsWith(line, '#END', trim=TRUE) | startsWith(line, 'label', trim=TRUE) ) {
				write(line, file = scaled_input_file, append=TRUE)
				next
			}			
			l = unlist(strsplit(line, '\t'))
			feats_only[1,] = as.numeric(l[feature_header_index])
			#training_data[1,] = l
			#training_data[1,feature_headers] = feats
			#feats = training_data[1,feature_headers] 		
			feats_only = predict(preProcValues, feats_only)
			l[feature_header_index] = feats_only
			#write(l, file = scaled_input_file, append=TRUE,sep="\t")
			write.table(l, file = scaled_input_file, sep= "\t",append=TRUE, col.names=FALSE,row.names=FALSE)	
			# #cat('\n', file = scaled_input_file, sep= "\t",append=TRUE)
		}	      		
    }
}