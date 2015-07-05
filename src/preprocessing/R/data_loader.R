# Author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module contains functions to load the sensor data and merge it with the ground truth annotations(labels)

load_sensor_data = function (sensor_data_dirs, interval_length_in_sec) {
	all_sensor_data = data.frame()
	for(sensor_dir in sensor_data_dirs) { 
		if(file.info(sensor_dir)$isdir) {
			cat("Exracting sensor_data from directory: " , sensor_dir, "\n")
			sensor_data = read_from_dir(sensor_dir)
		}
		else {
			cat("Exracting sensor_data from file: " , sensor_dir, "\n")
			sensor_data = read_from_file(sensor_dir,interval_length_in_sec)
		}
		if(nrow(all_sensor_data) == 0) {
			all_sensor_data = sensor_data
		}
		else {
			# make the date formate same 
			#print(t(all_sensor_data[1, ]$timestamp))	
			date_format = get_date_format(toString(all_sensor_data[1, ]$timestamp))
			all_sensor_data$timestamp = strptime(all_sensor_data$timestamp, date_format)
			sensor_data$timestamp = strptime(sensor_data$timestamp, date_format)

			if("participant" %in% colnames(all_sensor_data) & "participant" %in% colnames(sensor_data) ) {
				all_sensor_data = merge (all_sensor_data, sensor_data,  by.x=c("participant","timestamp"), by.y=c("participant","timestamp"), all=FALSE, sort=FALSE)
			}
			else {
				all_sensor_data = merge (all_sensor_data, sensor_data,  by.x=c("timestamp"), by.y=c("timestamp"), all=FALSE, sort=FALSE)	
			}
		}		
	}
	if(nrow(all_sensor_data) == 0) {
		stop("Feature merge failed. Please check the feature directories.", sensor_data_dirs)
	}
	return (all_sensor_data)
}

load_labels = function(label_dir, interval_length_in_sec) {
 	if(file.info(label_dir)$isdir) {
		aligned_labels_dir = paste0(label_dir, "_",interval_length_in_sec,"_aligned")
		print(aligned_labels_dir)
		if (!file.exists(aligned_labels_dir)) {
			align_labels(label_dir, aligned_labels_dir, interval_length_in_sec)
		}
		labels = read_from_dir(aligned_labels_dir)
	}
	else {
		labels = read_from_file(label_dir, interval_length_in_sec)
	}
 }

 merge_data_and_labels = function (all_sensor_data, labels) {
 	# make the date formate same 
	date_format = get_date_format(toString(all_sensor_data[1, ]$timestamp))
	# first format the labels timestamp in the same format as features so that we can merge on the timestamp
	labels$timestamp = strptime(labels$timestamp, date_format)

	#---------------------
	#all_sensor_data$dateTime = strptime(all_sensor_data$dateTime, date_format)
	#all_sensor_data = merge (all_sensor_data, labels,  by.x=c("participant","dateTime"), by.y=c("participant","timestamp"), all=FALSE, sort=FALSE)
	
	all_sensor_data$timestamp = strptime(all_sensor_data$timestamp, date_format)
	if("participant" %in% colnames(all_sensor_data) & "participant" %in% colnames(labels) ) {
		all_sensor_data = merge (all_sensor_data, labels,  by.x=c("participant","timestamp"), by.y=c("participant","timestamp"), all=FALSE, sort=FALSE)
	}
	else {
		all_sensor_data = merge (all_sensor_data, labels,  by.x=c("timestamp"), by.y=c("timestamp"), all=FALSE, sort=FALSE)	
	}
	# discard training points for whom the corresponding labels are unavailable
	all_sensor_data = all_sensor_data[all_sensor_data$behavior!="NULL", ]
	return(all_sensor_data)	
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
    		feats = read.csv(file, header=TRUE,sep = ",", stringsAsFactors=FALSE, check.names=FALSE, strip.white=TRUE)
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


read_from_file = function (file, interval_length_in_sec=15) {
	feats = read.csv(file, header=TRUE,sep = ",", stringsAsFactors=FALSE, check.names=FALSE, strip.white=TRUE)
	t1 = strptime(feats[1, c("dateTime")], "%Y-%m-%d %H:%M:%S")
    t2 = strptime(feats[2, c("dateTime")], "%Y-%m-%d %H:%M:%S")
    
    sample_rate = as.numeric(t2 - t1)
    ws = interval_length_in_sec / sample_rate
    if (ws != 1) {
    	feats = aggregate_features(feats,ws, interval_length_in_sec)
    }

	if("identifier" %in% colnames(feats)) {
		feats = rename(feats,c("identifier"="participant"))
	}
	if("dateTime" %in% colnames(feats)) {
		feats = rename(feats,c("dateTime"="timestamp"))
	}
	return (feats)
}


# right now it is hardcoded to aggregate GPS features only
aggregate_features = function(feats, ws, interval_length_in_sec) { 	
	headers = colnames(feats)
	
	excluded_features_to_aggregate = c("identifier","dateTime","fixType")
	feats_to_aggregate = headers[!headers %in% excluded_features_to_aggregate]
 	
 	aggregate_file_name =  paste0("Aggregate_GPS_", toString(interval_length_in_sec))
 	aggregate_file = file.path(aggregate_file_name)
 	if (file.exists( aggregate_file )) {
	    feats_new = read.csv(aggregate_file, header=TRUE,sep = ",", stringsAsFactors=FALSE, check.names=FALSE, strip.white=TRUE)
    	return(feats_new)
    }

    cat("Aggregating gps features to a window size: " , interval_length_in_sec, "\n")
    cat(headers,"\n", file=aggregate_file, sep=",", append=TRUE)
    
    r = 1
    single_aggregate = array(0, dim = c(1,length(headers)))
    colnames(single_aggregate) = headers

 	# align to the windowsize
 	st = strptime(feats[r, c("dateTime")], "%Y-%m-%d %H:%M:%S")
    new_start = align_start(interval_length_in_sec, st)

    while (new_start > st) {
      r = r + 1
      st = strptime(feats[r, c("dateTime")], "%Y-%m-%d %H:%M:%S")
      print(st)
    }
    last_participant = feats[1,c("identifier")]
    while ((r + ws - 1) <= nrow(feats)) {

    	single_aggregate[1,feats_to_aggregate] = colMeans(feats[r:(r + ws - 1),feats_to_aggregate])
 
    	for (feature in excluded_features_to_aggregate) {
    		single_aggregate[1,feature] = feats[r,feature]
    	}
    	cat(single_aggregate, file=aggregate_file, sep=",", append=TRUE)
      	cat('\n', file=aggregate_file, append=TRUE)
      	r = r + ws
      	if (last_participant != feats[r,c("identifier")]) {
      		print('new participant')
      		print(feats[r,c("identifier")])
  		 	st = strptime(feats[r, c("dateTime")], "%Y-%m-%d %H:%M:%S")
		    new_start = align_start(interval_length_in_sec, st)
		    while (new_start > st) {
		      r = r + 1
		      st = strptime(feats[r, c("dateTime")], "%Y-%m-%d %H:%M:%S")
		    }
		    last_participant = feats[r,c("identifier")]
      	}
    }
    feats_new = read.csv(aggregate_file, header=TRUE,sep = ",", stringsAsFactors=FALSE, check.names=FALSE, strip.white=TRUE)
    return(feats_new)
}
