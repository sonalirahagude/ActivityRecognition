# author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module contains functions to generate different feature functions for the CRF model

# number of pauses
# arguments = sequence dataframe
no_of_pauses = function(seq, position, labels, options = NULL) {
  if ("lat" %in% colnames(seq) & "lon" %in% colnames(seq)) {
    # 	 (seq[c("lat", "lon")])
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
    feature_tuple = paste0("no_of_pauses:",pauses)
    return(feature_tuple)
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
    feature_tuple = ""
    for(plain_feature in plain_features) {
        if(!(plain_feature %in% names(seq))) {
            cat("Did not find feature: ", plain_feature,"\nSkipping...")
            next
        }
        if(feature_tuple == ""){
            feature_tuple = paste0(plain_feature,":", seq[position,plain_feature])
        } else {
            feature_tuple = paste0(feature_tuple, "\t ", plain_feature,":", seq[position,plain_feature])
        }
    }
    close(conn)
    return (feature_tuple)
}

# add functions that are indicator functions for the labels passed
# these will be templates
# they need to be aware of the label set of the application
