
find_accuracy = function(accuracy_file) {
	conn = file(accuracy_file, open = 'r')
	accuracy = 0
	total = 0

	for (line in readLines(conn)) { 
		tuple = unlist(strsplit(trim(line), ","))
		prediction = tuple[1]
		label = tuple[2]
		if(prediction == 'prediction'){
			next
		}
		if (prediction == label) {
			accuracy = accuracy + 1
		}
		total = total + 1 
	}
	return(accuracy*1.0/total*100.0)
}	
	