# author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module contains functions to generate different feature function templates for the CRF model. These will be written in form of sequences in a file. 
#              The CRF trainer module will read this file and generate feature functions by appending indicator functions fot the output tokens. 

# number of pauses
# arguments = sequence dataframe
no_of_pauses = function(seq, position, labels, options = NULL) {
  if ("lat" %in% colnames(seq) & "lon" %in% colnames(seq)) {
    seq_matrix = as.matrix(seq[c("lat", "lon")])

    lat0 = "NULL"
    lon0 = "NULL"
    lat1 = "NULL"
    lon1 = "NULL"
    lat_threshold = 0.01
    lon_threshold = 0.01
    pauses = 0
    for (i in seq(1:nrow(seq_matrix))) {
    	lat0  = lat1
    	lon0 = lon1
    	lat1 = seq_matrix[i,1]
    	lon1 = seq_matrix[i,2]
        if (lat0 == "NULL" & lon0 == "NULL" ) {
    		next
    	}
    	if(abs(lat1 - lat0) < lat_threshold & abs(lon1 - lon0) < lon_threshold)  {
    		pauses = pauses + 1
    	}
    }
    return(pauses)
  }
  return(0)
}

# add functions that simply return value of the interested attribute without any processing, can read from a list
plain_features = function(seq, position, labels, options = NULL) {
    plain_features_file = options[['plain_features_list']]
    if(plain_features_file == "NULL") {
        cat("Did not find plain features file\n")
        return("")
    }
    #print(plain_features_file)
    conn = file(plain_features_file, open = 'r')
    plain_features = readLines(conn) 
    feature_value = ""
    for(plain_feature in plain_features) {
        # ignore comments and blank lines in the plain feature list file
        if (startsWith(plain_feature, '#', trim=TRUE) | trim(plain_feature) == '')
            next

        if(!(plain_feature %in% names(seq))) {
            cat("Did not find feature: ", plain_feature,"\n")
            stop("Did not find feature: ", plain_feature,"\nPlease check the input file")
        }

        if(feature_value == ""){
            feature_value = seq[position,plain_feature]
        } else {
            feature_value = paste0(feature_value, "\t", seq[position,plain_feature])
        }
    }
    close(conn)
    return (feature_value)
}

# observation difference features

difference_features = function(seq, position, labels, options = NULL) {
    difference_features_file = options[['difference_features_list']]
    if(difference_features_file == "NULL") {
        cat("Did not find plain features file\n")
        stop("Did not find plain features file\n")
    }

    no_of_steps = options[['no_of_steps']]
    if(no_of_steps == "NULL") {
        stop("No of steps for difference features not specified\n")
    }
    #print(plain_features_file)
    conn = file(difference_features_file, open = 'r')
    diff_features = readLines(conn) 
    feature_value = ""
    for(feature in diff_features) {
        # ignore comments and blank lines in the plain feature list file
        if (startsWith(feature, '#', trim=TRUE) | trim(feature) == '')
            next

        if(!(feature %in% names(seq))) {
            cat("Did not find feature: ", feature,"\n")
            stop("Did not find feature: ", feature,"\nPlease check the input file")
        }
        for(i in 1:no_of_steps) {

            if(feature_value == ""){            
                if( (position - i) <= 0) {
                    feature_value = "0"
                } else { 
                    diff = seq[position,feature] - seq[position - i,feature]
                   feature_value = diff
                }
            } else {
                if( (position - i) <= 0) {
                    feature_value = paste0(feature_value, "\t", "0")
                } else {               
                    diff =   seq[position,feature] - seq[position - i,feature]
                    feature_value = paste0(feature_value, "\t", diff)
                }
            }
        }
    }
    close(conn)
    return (feature_value)
}