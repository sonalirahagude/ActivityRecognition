# author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module implements testing part of the crf

crf_test = function(crt_test_file, crf_model_file, feature_inclusion_file, output_prediction_file, options) {
	weights_new = c()
	load(crf_model_file)
	crf_weights = weights_new
	feature_inclusion_list = get_feature_inclusion_list(feature_inclusion_file)
	# read training data from file
	train_list = get_training_data(crt_test_file, feature_inclusion_list)
	x_list = train_list[[1]]
	y_list = train_list[[2]]


	# get the template features. These will be combined with indicator functions I(y[i-1]='label1') * I(y[i]='label2') 
	features = colnames(x_list[[1]])
	# get the list of labels from the dimension names of the weights array
	labels = dimnames(crf_weights)[[2]]
	# Weights is a 3 dimensional matrix, 
	predictions = file.path(output_prediction_file)
	if (file.exists( predictions) ) {
      file.remove(output_prediction_file)
    }
	cat('prediction,label\n', file=predictions, append=TRUE)	

    for(j in 1:length(x_list)) {
    	# TODO: CAN TRY TAKING THIS OUT OF THE LOOP
        x = x_list[[j]]
        y = y_list[[j]]
        #print (x)
        #print (y)
        if (length(y) != nrow(x)) {
            cat('Error with Preprocessing, lengths x and y dont match\n');          
            return
        }

        #Calculate Viterbi Path and y_hat, uses anotherCOMPUTEG           
        G = compute_g_matrices(x, crf_weights, labels)
 		yHat = viterbi(G,x,labels)     
        #if isequal(yHat, y_mapped)
        #    numYhatMatches = numYhatMatches + 1;
        #end
        for(i in 1:length(yHat)) {
        	cat(yHat[i], y[i], sep=",", file=predictions, append=TRUE)
        	cat('\n',file=predictions, append = TRUE)
        }
    }
}

