# author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module implements prediction part of the crf

# Predicts sequences for test data based on the CRF model passed to it
# Arguments:
## crt_test_file: file containing the crf sequences along with the labels. Each line is of the form <label, feature1, feature2,...featuren>
##                 each sequence is enclosed between tags #START and #END
## crf_model_file: filename to read the weights of feature functions from
## feature_list_file: contains list of names of feature functions to be used to generate features
## output_prediction_file: file to save the predictions and actual labels
## options: A dictionary contains values for miscellaneous parameters
crf_tag = function(crt_test_file, crf_model_file, feature_list_file, output_prediction_file, options) {
	weights_new = c()
	load(crf_model_file)
	crf_weights = weights_new
	feature_inclusion_list = get_feature_inclusion_list(feature_list_file)
	# read training data from file
	train_list = get_training_data(crt_test_file, feature_inclusion_list)
	x_list = train_list[[1]]
	y_list = train_list[[2]]


	# get the template features. These will be combined with indicator functions I(y[i-1]='label1') * I(y[i]='label2') 
	features = colnames(x_list[[1]])
	# get the list of labels from the dimension names of the weights array
	labels = dimnames(crf_weights)[[2]]

	predictions = file.path(output_prediction_file)
	if (file.exists( predictions) ) {
      file.remove(output_prediction_file)
    }
	cat('prediction,label\n', file=predictions, append=TRUE)	

    for(j in 1:length(x_list)) {
        x = x_list[[j]]
        y = y_list[[j]]
        if (length(y) != nrow(x)) {
            cat('Error with Preprocessing, lengths x and y dont match\n');          
            return
        }

        #Calculate Viterbi Path and y_hat, uses anotherCOMPUTEG           
        G = compute_g_matrices(x, crf_weights, labels)
 		yHat = viterbi(G,x,labels)     
        for(i in 1:length(yHat)) {
        	cat(yHat[i], y[i], sep=",", file=predictions, append=TRUE)
        	cat('\n',file=predictions, append = TRUE)
        }
    }
}

