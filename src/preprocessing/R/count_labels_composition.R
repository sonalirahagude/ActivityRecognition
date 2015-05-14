count_labels = function(label_dir, output_file, labels, names = NULL) {
	
	if (file.exists( file.path(output_file) )) {
      file.remove(output_file)
    }

	if (is.null(names)) {
		names = list.files(label_dir)
	}
	if (length(names) == 0) {
		cat("Could not find files in label_directory: " , label_dir,". Either the label_directory is empty or it does not exist.\n")
		return(NULL)
	}
	all_labels = data.frame()
	cat('participant',',' ,file=output_file, append=TRUE)

	for (label in labels) {
		cat(label,',' ,file=output_file, append=TRUE)
	}
	cat('\n', file=output_file, append=TRUE)

	for (i in 1:length(names)) {
		days = list.files(file.path(label_dir, names[i]))
    	# if the participant label_directory is empty, skip this
    	if (length(days) == 0) {
    		next
    	}
    	for (k in 1:length(days)) {
    		file = file.path(label_dir, names[i], days[k])
    		# Set check.names=FALSE, else strings starting with numbers in the header will be read as 25thp -- X25thp
    		day_labels = read.csv(file, header=TRUE, stringsAsFactors=TRUE, check.names=FALSE)
    		all_labels = rbind(all_labels, day_labels)    		

    	}
    	
    	label_values = all_labels$behavior
		labels_table = table(label_values)
		missing_labels = setdiff(labels, names(labels_table))
		labels_table[missing_labels] = 0
		print(names[i])
		cat(names[i],',', file=output_file, append = TRUE) 
		for (label in labels) {
			if (label %in% missing_labels) {
				cat(0,',',file=output_file, append = TRUE)
			} else {
				cat(labels_table[label], ',',file=output_file, append=TRUE)
			}
		}
		cat('\n', file=output_file, append=TRUE)
		all_labels = data.frame()

	}
	return(all_labels)
}
