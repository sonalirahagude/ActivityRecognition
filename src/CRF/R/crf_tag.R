# author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module implements prediction part of the crf

# Predicts sequences for test data based on the CRF model passed to it
# Arguments:
## crf_test_file: file containing the crf sequences along with the labels. Each line is of the form <label, feature1, feature2,...featuren>
##                 each sequence is enclosed between tags #START and #END
## crf_model_file: filename to read the weights of feature functions from
## feature_list_file: contains list of names of feature functions to be used to generate features
## output_prediction_file: file to save the predictions and actual labels
## options: A dictionary contains values for miscellaneous parameters

crf_tag = function(crf_test_file, crf_model_file, feature_list_file, output_prediction_file, options, test_list = NULL) {

    model = list()
	# This will load weights_new object from the saved training model
	load(crf_model_file)
    crf_weights = model$weights
    pre_proc_values = model$pre_proc_values
    #print(crf_weights)
	feature_inclusion_list = get_feature_inclusion_list(feature_list_file)
    #print(feature_inclusion_list)

	# read training data from file
    if(is.null(test_list)) {        
        #cat("Reading from file: ", crf_test_file,"\n")
	   test_list = get_training_data(crf_test_file, feature_inclusion_list)
    } 
	x_list = test_list[[1]]
	y_list = test_list[[2]]

    pre_proc_values = get_pre_proc_values(x_list)
    x_list = get_scaled_training_data(x_list, pre_proc_values)

	# get the template features. These will be combined with indicator functions I(y[i-1]='label1') * I(y[i]='label2') 
	features = colnames(x_list[[1]])
	# get the list of labels from the dimension names of the weights array
	labels = dimnames(crf_weights)[[2]]
    
    # just in case the feature list from training does not conform
     crf_weights = crf_weights[,,unlist(features)]
	
    predictions = file.path(output_prediction_file)
	if (file.exists( predictions) ) {
      file.remove(output_prediction_file)
    }
    
    crf_sequence_length = as.numeric(options["crf_sequence_length"])
    overlap_window_length = as.numeric(options["overlap_window_length"])    
    overlapped_predictions = list()
    overlapped_labels = list()
	
    cat('prediction,label\n', file=predictions, append=TRUE)	
    ii = 0
    for(j in 1:length(x_list)) {
        x = x_list[[j]]
        y = y_list[[j]]
        if (length(y) != nrow(x)) {
            cat('Error with Preprocessing, lengths x and y dont match\n');          
            return
        }
        #cat("taggging example: ", j, "\n")
        #Calculate Viterbi Path and y_hat, uses anotherCOMPUTEG               
        G = compute_g_matrices(x, crf_weights, labels)
        #print(G)
 		yHat = viterbi(G, x, labels) 
        # print(x)
        # print (yHat)
        # print("actual y")
        # print (y)    
        # --------------------------------------------------------------------
        for(i in 1:length(yHat)) {
            cat(yHat[i], y[i], sep=",", file=predictions, append=TRUE)
            cat('\n', file=predictions, append = TRUE)
        }
        # --------------------------------------------------------------------
        
        # --------------------------------------------------------------------
        # voting mechanism
        # actual_overlap = min(overlap_window_length, length(yHat))
        # print(actual_overlap)
        # for(i in 1: actual_overlap) {
        #     if(length(overlapped_predictions) == 0) {
        #             cat(yHat[i], y[i], sep=",", file=predictions, append=TRUE)
        #             cat('\n', file=predictions, append = TRUE)
        #     }
        #     else {
        #         # apply voting
        #         if(yHat[i] != overlapped_predictions[i]) {
        #             ii = ii + 1
        #             cat("applying voting. i: ",i,", yHat[i]: ", yHat[i], ", overlapped_predictions[i]: ",overlapped_predictions[i],"y[i]: ",y[i],"\n")
        #             similarity_cur = get_similarity(yHat[i],yHat[1:actual_overlap])
        #             similarity_prev = get_similarity(overlapped_predictions[i], overlapped_predictions)
        #             cat("similarity_cur: ", similarity_cur, ", similarity_prev: ", similarity_prev, "\n")
        #             print(overlapped_predictions)
        #             print(yHat[1:actual_overlap])
        #             print(y[1:actual_overlap])
        #             if(similarity_prev < similarity_cur) {
        #                 cat(yHat[i], y[i], sep=",", file=predictions, append=TRUE)
        #                 cat('\n', file=predictions, append = TRUE)
        #             } else {
        #                 cat(overlapped_predictions[i], y[i], sep=",", file=predictions, append=TRUE)
        #                 cat('\n', file=predictions, append = TRUE)
        #             }
        #         }
        #         else {
        #             cat(yHat[i], y[i], sep=",", file=predictions, append=TRUE)
        #             cat('\n', file=predictions, append = TRUE)
        #         }
        #     }
        # }
        # if(length(yHat) <= overlap_window_length) {
        #     next
        # }
        # new_start = overlap_window_length + 1
        # overlapped_predictions = yHat[new_start:length(yHat)]
        # overlapped_labels = y[new_start:length(y)]
        # if (length(yHat) != crf_sequence_length) {
        #     overlapped_predictions = list()
        #     overlapped_labels = list()
        # }
        # --------------------------------------------------------------------
    }    
    cat("total conflicts: ",ii,"\n")
}


get_similarity = function(label, label_sequence) {
    sim = sum(label_sequence == label)
}

