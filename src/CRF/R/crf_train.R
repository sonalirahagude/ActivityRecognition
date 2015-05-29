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
## crf_input_file: files containing the crf sequences along with the labels. Each line is of the form <label, feature1, feature2,...featuren>
##                 each sequence is enclosed between tags #START and #END
## feature_list_file: contains list of names of feature functions to be used to generate features
## labels: list of possible labels for the domain
## crf_model_file: filename to save the model
## options: A dictionary contains values for learning parameters like no_of_epochs, learning_rate etc.

crf_train = function(crf_input_files, feature_list_file, labels, crf_model_file, options) {
	
	feature_inclusion_list = get_feature_inclusion_list(feature_list_file)
	# read training data from file
	training_method = options["training_method"]
	excluded_participant = options["excluded_participant"]

	#--------------------------------------------------
	train_list = get_training_data(crf_input_files, feature_inclusion_list, excluded_participant)

	#save(train_list,file='training_list_all')

	#train_list = list()
	#load('training_list_all')
	#--------------------------------------------------
	print("got training data")
	x_list = train_list[[1]]
	y_list = train_list[[2]]
	pre_proc_values = get_pre_proc_values(x_list)
	x_list = get_scaled_training_data(x_list, pre_proc_values, excluded_participant)
	print("got scaled training data")
	

	test_x_list = train_list[[3]]
	test_y_list = train_list[[4]]
	# get the template features. These will be combined with indicator functions I(y[i-1]='label1') * I(y[i]='label2') 
	features = colnames(x_list[[1]])

	# Append START and STOP to the list of labels
	labels = append(labels, c("START","STOP"))
	# Weights is a 3 dimensional matrix, 
	total_no_of_weights = length(labels)^2 * length(features)
	# initialize the weight array at random
	#weights_new = array(runif(total_no_of_weights,-10000,10000),dim=c(length(labels), length(labels), length(features)),dimnames=(list(labels, labels, features)))
	weights_new = array(0,dim=c(length(labels), length(labels), length(features)),dimnames=(list(labels, labels, features)))
	start_time = Sys.time()
	print("Starting CRF training")

	old_likehood = -990
	new_likehood =  0
	regularization_constant = as.numeric(options["regularization_constant"])
	regularization_method = options["regularization_method"]
	for (i in 1: as.numeric(options["no_of_epochs"])) {
        cat("Running epoch: ",i,"\n")
        weights_old = weights_new

        #generate permutation 
        permutation = sample(1:length(x_list), length(x_list))
        for(j in permutation) {
            x = x_list[[j]]                    
            y = y_list[[j]]
            if (length(y) != nrow(x)) {
                cat('Error with Preprocessing, lengths x and y dont match\n');          
                return
            }
            
            G = compute_g_matrices(x, weights_old, labels)                      
            #G = compute_g_matrices(x, weights_new, labels)                      
             
             # if(i==2) {
             # 	print(weights_new)
             # 	stop("")
             # }
            learning_rate = as.numeric(options["learning_rate"])

            if (training_method == "collins_perceptron")  {
                yHat = viterbi(G, x, labels)
            	weights_new = update_features(x,y, yHat,weights_new,learning_rate,labels)            	
            }
            else if(training_method == "contrasive_divergence") {           
            	gibbs_sampling_rounds = as.numeric(options["gibbs_sampling_rounds"])
            	yHat = contrasive_divergence(G, y, labels, gibbs_sampling_rounds)
            	# no regularization
            	 weights_new = update_features_fast(x, y, yHat, weights_new,learning_rate,labels)
            	# L1 regularization
            	# weights_new = update_features_fast_with_l1_reguralization(x, y, yHat, weights_new,learning_rate,labels, regularization_constant)
            	# L2 regularization  
            	# weights_new = update_features_fast_with_l2_reguralization(x, y, yHat, weights_new,learning_rate,labels, 1/regularization_constant^2)
            }
            else if(training_method == "forward_backward") {
            	alpha_beta = compute_forward_backword_vectors(G,x,y, labels)
            	alpha = alpha_beta[[1]]
            	beta = alpha_beta[[2]]
        	    weights_new = update_features_expectation_fast(G, x, y, weights_new, learning_rate, labels, alpha, beta) 
            }
            else {
            	stop("incorrect training method: ", training_method)
            }
            #-------------------------------------------------------------------------------
            ## Now compute the likelihood
            # instance_likelihood = compute_per_instance_likelihood(G,x,y, labels)
            # new_likehood = new_likehood + instance_likelihood
            #-------------------------------------------------------------------------------
        }
        # apply regularization
        # L1 regularization
        if(regularization_method == "l1") {
        	weights_new = weights_new - regularization_constant    
        	cat("applying l1 regularization", "\n")
        }
   		# L2 regularization
   		else if(regularization_method == "l2") {
        	weights_new = weights_new - weights_new/(regularization_constant^2)
        	cat("applying l2 regularization", "\n")
   		}
            	
        #-------------------------------------------------------------------------------
        # if(abs(new_likehood - old_likehood) < 0.1 ) {
        # 	cat("coverged at: " , i, "\n")
        # 	break
        # }
        # cat("old_likehood: ", old_likehood,"\n")
        # cat("new_likehood: ", new_likehood,"\n")
        # old_likehood = new_likehood
        # new_likehood = 0
        #-------------------------------------------------------------------------------

        #write the model after every epoch
    	if(i%%10 == 0 ) {
	    	model = list()
	   		model$weights = weights_new
	    	model$pre_proc_values = pre_proc_values
	        intermediate_file = paste0(crf_model_file, i)
	        save(model,file = intermediate_file)         
        }
		# check for weight convergence 
		print(max(weights_old - weights_new) )
		if (max(abs(weights_old - weights_new)) < 0.1) {
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
    
    if(length(test_y_list) > 0) {
    	return (list(test_x_list,test_y_list))
	}
	return (NULL)
}


get_pre_proc_values = function (x_list) {
	single_df = do.call("rbind",x_list)
	pre_proc_values = preProcess(single_df, method = c('range'),verbose=TRUE)
	return (pre_proc_values)
}

get_scaled_training_data = function (x_list, pre_proc_values, excluded_participant= NA) {
	for(i in 1:length(x_list)) {
		x_list[[i]] = predict(pre_proc_values,x_list[[i]])
		na_indices = is.na(x_list[[i]])
		x_list[[i]][na_indices] = 0.0
	}
	return(x_list)
}

# Reads the training data from the file and returns a list of dataframes, each corresponding to one CRF sequence x. Also, returns a parallel list of label sequences.
get_training_data = function(crf_input_files, feature_inclusion_list, excluded_participant = NA) {

	all_x = list()
	all_y = list()
	test_x = list()
	test_y = list()
	ii = 1
	count = 1

	for(crf_input_file in crf_input_files) {
		cat("Reading from: ", crf_input_file, "\n")
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
				if(!is.na(excluded_participant) && participant == excluded_participant) {			
					cat("Excluding " , participant, "\n")
					test_x[[ii]] = x
					test_y[[ii]] = y
					ii = ii + 1
					x = array(0, dim = c(0,length(filtered_indices)))
					y = character()
					line = readLines(conn, n= 1, warn = FALSE)
					next
				}
				# do not use append here, it does some funny business while appending the dataframe 
				all_x[[count]] = x
				all_y[[count]] = y
				count = count + 1
				x = array(0, dim = c(0,length(filtered_indices)))
				y = character()
			}
			else {
				feature_values = unlist(strsplit(trim(line), "\t"))
				# If the participant is the excluded participant, then skip
				participant = feature_values[2]
				

				feature_values_filtered = feature_values[filtered_indices]						
				x = rbind(x,as.numeric(feature_values_filtered))
				y = append(y,feature_values[1])
			}		
			line = readLines(conn, n= 1, warn = FALSE)
		}
	}
	print(ii)
	close(conn)
	return (list(all_x,all_y,test_x,test_y))
}


