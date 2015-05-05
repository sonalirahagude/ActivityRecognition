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
	training_method = options["training_method"]

	#--------------------------------------------------
	train_list = get_training_data(crf_input_file, feature_inclusion_list)

	#save(train_list,file='training_list_all')

	#train_list = list()
	#load('training_list_all')
	#--------------------------------------------------

	x_list = train_list[[1]]
	pre_proc_values = get_pre_proc_values(x_list)
	x_list = get_scaled_training_data(x_list, pre_proc_values)
	
	y_list = train_list[[2]]
	# get the template features. These will be combined with indicator functions I(y[i-1]='label1') * I(y[i]='label2') 
	features = colnames(x_list[[1]])

	# Append START and STOP to the list of labels
	labels = append(labels, c("START","STOP"))
	# Weights is a 3 dimensional matrix, 
	weights_new = array(0,dim=c(length(labels), length(labels), length(features)),dimnames=(list(labels, labels, features)))
	start_time = Sys.time()
	print("Starting CRF training")
	for (i in 1: as.numeric(options["no_of_epochs"])) {
        cat("Running epoch: ",i,"\n")
        weights_old = weights_new
        for(j in 1:length(x_list)) {
        	# TODO: CAN TRY TAKING THIS OUT OF THE LOOP        	
        	#cat("Processing training sequence: ",j,"\n")
            x = x_list[[j]]                    
            y = y_list[[j]]
            if (length(y) != nrow(x)) {
                cat('Error with Preprocessing, lengths x and y dont match\n');          
                return
            }
            #if(j==50) {stop("")}

            #Calculate Viterbi Path and y_hat            
            G = compute_g_matrices(x, weights_new, labels)                      
            #G = compute_g_matrices_train(x, y, weights_new, labels)                                         
            # print(G)
            learning_rate = as.numeric(options["learning_rate"])
            #collins perceptron
            if (training_method == "collins_perceptron")  {
                yHat = viterbi(G, x, labels)
            	weights_new = update_features(x,y, yHat,weights_new,learning_rate,labels)            	
            }
            else if(training_method == "contrasive_divergence") {           
            	gibbs_sampling_rounds = as.numeric(options["gibbs_sampling_rounds"])
            	yHat = contrasive_divergence(G, y, labels, gibbs_sampling_rounds)
            	weights_new = update_features(x, y, yHat, weights_new,learning_rate,labels)
            	#weights_new = update_features(x,yHat,weights_new,-1*learning_rate,labels)            
            }
            else if(training_method == "forward_backward") {
            	alpha_beta = compute_forward_backword_vectors(G,x,y, labels)
            	alpha = alpha_beta[[1]]
            	beta = alpha_beta[[2]]
        	    weights_new = update_features_expectation(G, x, y, weights_new, learning_rate, labels, alpha, beta) 
            }
            else {
            	stop("incorrect training method: ", training_method)
            }
            #print(yHat)
            
            
            # We need to compute the sum of feature functions twice, first for y and then for yHat
            # normalize weights so that Gibbs sampling does not have overflow
            # weights_new = normalize(weights_new)       
            #break            
        }
        # write the weights after every epoch
        intermediate_file = paste0(crf_model_file, i)
    	model = list()
   		model$weights = weights_new
    	model$pre_proc_values = pre_proc_values
        #save(model,file = intermediate_file)         
        #check for convergence 
        if (max(weights_old - weights_new) < 1) {
     		print("coverged at: " , i)
        	break
        }
    }    
    print(weights_old - weights_new)
    # save the trained feature function weights to a file
    model = list()
    model$weights = weights_new
    model$pre_proc_values = pre_proc_values
    save(model,file=crf_model_file)
    end_time = Sys.time()
    cat("Training time: " , end_time - start_time, "\n")
    #save(weights_new,file=crf_model_file)
}


get_pre_proc_values = function (x_list) {
	single_df = do.call("rbind",x_list)
	pre_proc_values = preProcess(single_df, method = c('center','scale'),verbose=TRUE)
	return (pre_proc_values)
}

get_scaled_training_data = function (x_list, pre_proc_values) {
	for(i in 1:length(x_list)) {
		x_list[[i]] = predict(pre_proc_values,x_list[[i]])
		na_indices = is.na(x_list[[i]])
		x_list[[i]][na_indices] = 0.0	
	}
	return(x_list)
}

get_rescaled_training_data = function(x_list) {
	single_df = do.call("rbind",x_list)
	#scaleingle_df = scale
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
	count = 1
	#x = data.frame(matrix(ncol = length(filtered_indices), nrow = 0))
	#print(typeof(x))
	x = array(0, dim = c(0,length(filtered_indices)))
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
			#x = scale(x,center=FALSE,scale=TRUE)
			#print(typeof(x))
			# scale will return NaNs for columns with no variance, set those values to 0
			#x = replace(x,is.na(x),0.0)
			# do not use append here, it does some funny business while appending the dataframe 
			all_x[[count]] = x
			all_y[[count]] = y
			count = count + 1
			#x = data.frame(matrix(ncol = length(filtered_indices), nrow = 0))
			x = array(0, dim = c(0,length(filtered_indices)))
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


