# author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module contains functions to generate different feature functions for the CRF model

# number of pauses
# arguments = sequence dataframe
no_of_pauses = function(seq, position) {
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
    return(pauses)
  }
  return(0)
}



# add functions that are indicator functions for the labels passed

# add functions that simply return value of the interested attribute without any processing