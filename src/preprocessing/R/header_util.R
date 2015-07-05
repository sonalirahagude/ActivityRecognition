# Author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module contains functions to generate headers for different feature templates 

generate_header = function(feature_list_file, output_feature_file, options) {
	conn = file(feature_list_file,open = 'r')
	feature_functions = readLines(conn)	
	output_file = file.path(output_feature_file)
	if (file.exists( output_file )) {
      file.remove(output_file)
    }

	token_count = 0
	cat("label", sep="", file=output_feature_file, append=TRUE)		
	cat('\t', "participant", sep="", file=output_feature_file, append=TRUE)		

	for (feature_function in feature_functions) {		
		# ignore comments in the feature list file
		if (startsWith(feature_function, '#', trim=TRUE) | trim(feature_function) == '')
			next
		else if(feature_function == "plain_features") {
			plain_features_list = get_plain_features_header(options)
			cat('\t', plain_features_list, sep="", file=output_file, append=TRUE)		
			token_count = token_count + length(plain_features_list)
		}
		else if(feature_function == "difference_features") {
			diff_features_list = get_diff_features_header(options)
			cat('\t', diff_features_list, sep="", file=output_file, append=TRUE)		
			token_count = token_count + length(diff_features_list)
		}
		else {
			cat('\t', feature_function, sep="", file=output_file, append=TRUE)	
			token_count = token_count + 1
		}
	}
	cat('\n', file=output_file, append=TRUE)	
	return (token_count)
}

get_plain_features_header  = function(options) {
	plain_features_file = options[['plain_features_list']]
	conn = file(plain_features_file, open = 'r')
    plain_features = readLines(conn) 
   	plain_features_list = ""
   	is_first = TRUE
    for (plain_feature in plain_features) {
    	# ignore comments in the feature list file
		if (startsWith(plain_feature, '#', trim=TRUE) | trim(plain_feature) == '')
			next
		if (plain_features_list == "") {
			plain_features_list = paste0(plain_features_list,plain_feature)
		}
		else {
    		plain_features_list = paste0(plain_features_list, "\t", plain_feature)
    	}
	}
	return (plain_features_list)
}

get_diff_features_header  = function(options) {
    difference_features_file = options[['difference_features_list']]
    no_of_steps = options[['no_of_steps']]

    if(no_of_steps < 1) {
    	stop("no of steps is specified as 1. Something is wrong")
    }
	conn = file(difference_features_file, open = 'r')
    diff_features = readLines(conn) 
   	diff_features_list = ""
    for (diff_feature in diff_features) {
    	# ignore comments in the feature list file
		if (startsWith(diff_feature, '#', trim=TRUE) | trim(diff_feature) == '')
			next
		for (i in 1:no_of_steps) {
			feature_name  = paste0(diff_feature,'_',i)
			if (diff_features_list == "") {
				diff_features_list = paste0(diff_features_list,feature_name)
			}
			else {
				diff_features_list = paste0(diff_features_list, "\t", feature_name)
			}
		}
	}
	return (diff_features_list)
}
