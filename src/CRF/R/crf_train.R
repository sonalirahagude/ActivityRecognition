# author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module implements the training algorithm for CRF. It expects the tokenized input file, a feature inclusion list, list of labels and 
#				training parameters like learning rate, no of epochs etc. 

# Get the list of features (raw/calculated) to be included as feature function templates in the CRF
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

# Train the weights for the defined feature functions
# Arguments:
## crf_input_file: file containing the crf sequences along with the labels. Each line is of the form <label, feature1, feature2,...featuren>
##                 each sequence is enclosed between tags #START and #END
## feature_list_file: contains list of names of feature functions to be used to generate features
## labels: list of possible labels for the domain
## crf_model_file: filename to save the model
## options: A dictionary contains values for learning parameters like no_of_epochs, learning_rate etc.
crf_train = function(crf_input_file, feature_list_file, labels, crf_model_file, options) {
	feature_inclusion_list = get_feature_inclusion_list(feature_list_file)
	# read training data from file
	train_list = get_training_data(crf_input_file, feature_inclusion_list)
	x_list = train_list[[1]]
	y_list = train_list[[2]]

	# get the template features. These will be combined with indicator functions I(y[i-1]='label1') * I(y[i]='label2') 
	features = colnames(x_list[[1]])
	
	# Append START and STOP to the list of labels
	labels = append(labels, c("START","STOP"))
	# Weights is a 3 dimensional matrix, 
	weights_new = array(0,dim=c(length(labels), length(labels), length(features)),dimnames=(list(labels, labels, features)))
	print("Starting CRF training")
	for (i in 1:options["no_of_epochs"]) {
        print(i)
        for(j in 1:length(x_list)) {
        	# TODO: CAN TRY TAKING THIS OUT OF THE LOOP
            weights_old = weights_new
            x = x_list[[j]]
            y = y_list[[j]]
            if (length(y) != nrow(x)) {
                cat('Error with Preprocessing, lengths x and y dont match\n');          
                return
            }
            #Calculate Viterbi Path and y_hat
            G = compute_g_matrices(x, weights_old, labels)                      
            
            #If training method == 1 then do Collins Perceptron
            #if trainingMethod == 1
            #    yHat = Viterbi(G,sampleSize, tagSize);
            #Else if its 2 do Contrasive divergence
            #elseif trainingMethod == 2
            yHat = contrasive_divergence(G, y, labels)
            #else
            #    fprintf('Training Method not specified.\n');
            
            #Colins Perceptron training
            learning_rate = options["learning_rate"]
            # We need to compute the sum of feature functions twice, first for y and then for yHat
            weights_new = update_features(x,y,weights_old,learning_rate,labels)
            weights_new = update_features(x,yHat,weights_old,-1*learning_rate,labels)
            # normalize weights so that Gibbs sampling does not have overflow
            # weights_new = normalize(weights_new)                   
        }
    }    
    print(weights_old - weights_new)
    # save the trained feature function weights to a file
    save(weights_new,file=crf_model_file)
}

# Reads the training data from the file and returns a list of dataframes, each corresponding to one CRF sequence x. Also, returns a parallel list of label sequences.
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
			x = scale(x,center=FALSE)
			# scale will return NaNs for columns with no variance, set those values to 0
			x = replace(x,is.na(x),0.0)
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
	close(conn)
	return (list(all_x,all_y))
}


