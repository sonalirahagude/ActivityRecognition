# Author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module contains functions to scale the crf input files created by the feature generator


# scales the generated crf input files
do_min_max_scaling = function(crf_sequence_length, sliding_window_length, interval_length_in_sec) {
    input_crf_dir = get_crf_dir_name(crf_sequence_length, sliding_window_length, interval_length_in_sec) 
    input_crf_file_all = paste0 (input_crf_dir, '/all')

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
    for (input_file_name in input_file_names) {
    	cat('Scaling features for file: ',input_file_name,'\n')

    	input_file = file.path(input_crf_dir, input_file_name)
    	scaled_input_file = paste0(input_crf_dir, '/', 'scaled_', input_file_name)

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
		    		feats['val',feature_name] = (as.numeric(feats['val',feature_name]) - min_max['min',feature_name]) / denom
		    	}	    	
		    }
			cat(feats, '\n', file = scaled_input_file, sep= "\t",append=TRUE)
		}	   	
    }
}


