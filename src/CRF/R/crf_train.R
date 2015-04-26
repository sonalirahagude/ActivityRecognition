# author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module contains functions to generate different feature functions for the CRF model



# tested
get_feature_inclusion_list = function(file) {
    conn = file(file, open = 'r')
    feature_inclusion_list = list()
    for (line in readLines(conn)) { 
    	# ignore headers and new lines
    	if(startsWith(trim(line), "#") || trim(line) == "")
    		next
        feature_inclusion_list = append(feature_inclusion_list,trim(line))
    }
    close(conn)
    return(feature_inclusion_list)
}



crf_train = function(crf_input_file, feature_inclusion_file, labels, crf_model_file, options) {
	feature_inclusion_list = get_feature_inclusion_list(feature_inclusion_file)
	# read training data from file
	train_list = get_training_data(crf_input_file, feature_inclusion_list)
	x_list = train_list[[1]]
	y_list = train_list[[2]]


	# get the template features. These will be combined with indicator functions I(y[i-1]='label1') * I(y[i]='label2') 
	features = colnames(x_list[[1]])
	weights_new = numeric(0)
	# Append START and STOP to the list of labels
	labels = append(labels, c("START","STOP"))
	# Weights is a 3 dimensional matrix, 
	weights_new = array(0,dim=c(length(labels), length(labels), length(features)),dimnames=(list(labels, labels, features)))
	print("Starting CRF training")
	for (i in 1:options["no_of_epochs"]) {
        #%randOrder = randperm(size(trainingLabels,1));
        #numYhatMatches =0;
        print(i)
        for(j in 1:length(x_list)) {
        	# TODO: CAN TRY TAKING THIS OUT OF THE LOOP
            weights_old = weights_new
            x = x_list[[j]]
            y = y_list[[j]]
            #print (x)
            #print (y)
            if (length(y) != nrow(x)) {
                cat('Error with Preprocessing, lengths x and y dont match\n');          
                return
            }

            #Calculate Viterbi Path and y_hat, uses anotherCOMPUTEG           
            # print(x)
            # print(weights_old)
            # print(labels)
            G = compute_g_matrices(x, weights_old, labels)                      
            #If training method == 1 then do Collins Perceptron
            #if trainingMethod == 1
            #    yHat = Viterbi(G,sampleSize, tagSize);
            #Else if its 2 do Contrasive divergence
            #elseif trainingMethod == 2
            yHat = contrasive_divergence(G, y, labels)
            #print(yHat)
            #else
            #    fprintf('Training Method not specified.\n');
            
            #Colins Perceptron training
            #Do two feature function add
            learning_rate = options["learning_rate"]
            weights_new = update_features(x,y,weights_old,learning_rate,labels)
            weights_new = update_features(x,yHat,weights_old,-1*learning_rate,labels)
            # normalize weights so that Gibbs sampling does not have overflow
            weights_new = normalize(weights_new)

            #print(weights_new)
            #stop("")          
            
            #if isequal(yHat, y_mapped)
            #    numYhatMatches = numYhatMatches + 1;
            #end
        
        }
    }
    save(weights_new,file=crf_model_file)
}



get_training_data = function(crf_input_file, feature_inclusion_list) {
	conn = file(crf_input_file, open = 'r')
	# Read the headers and filter features
	headers = readLines(conn, n= 1, warn = FALSE)
	index = 1
	filtered_headers = character()
	filtered_indices = numeric()
	# check the features to be included
	for(feature_name in unlist(strsplit(headers,"\t"))) {
		# ignore headers and new lines
    	if(startsWith(trim(feature_name), "#") || trim(feature_name) == "")
    		next
		if(feature_name %in% feature_inclusion_list) {
			filtered_headers = append(filtered_headers,feature_name)
			filtered_indices = append(filtered_indices,index)
		}
		index = index + 1
	}

	# Start reading the data and create dataframes for each sequence. Final output will be list of dataframes and list of output label vectors
	all_x = list()
	all_y = list()
	x = data.frame(matrix(ncol = length(filtered_indices), nrow = 0))
	y = character()
	line=""
	colnames(x) = filtered_headers
	
	line = readLines(conn, n= 1, warn = FALSE)
	while (length(line) > 0) {
		if(startsWith(line, "#START", trim=TRUE, ignore.case=FALSE)) {	
		}
		else if(startsWith(line, "#END", trim=TRUE, ignore.case=FALSE)) {	
			# create a new data frame
			colnames(x) = filtered_headers
			#print(x)
			#print(y)
			all_x = append(all_x, list(x))
			all_y = append(all_y, list(y))
			x = data.frame(matrix(ncol = length(filtered_indices), nrow = 0))
			y = character()
		}
		else {
			feature_values = unlist(strsplit(trim(line), "\t"))
			feature_values_filtered = feature_values[filtered_indices]			
			x = rbind(x,as.numeric(feature_values_filtered))
			y = append(y,feature_values[1])
		}
		
		line = readLines(conn, n= 1, warn = FALSE)
	}
	 for (i in 1:length(all_x)) {
	 	#print (all_x[[i]])
	 	#print (all_y[[i]])
	 }
	close(conn)
	return (list(all_x,all_y))
}


