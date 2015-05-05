# Author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module updates the weights of the feature functions in the CRF

update_features = function(x, y, yHat, weights, learning_rate, labels) {
    crf_sequence_length = nrow(x)   
    x = rbind(x,x[crf_sequence_length,])
    crf_sequence_length = crf_sequence_length + 1
    # get the features from the weights
    features = dimnames(weights)[[3]]

    feature_values = array(0,dim=c(length(features)), dimnames = features)
    # calculate the feature sum across the sequence
    feature_values = colSums(x)
    
    for (i in 1:crf_sequence_length) {
        if (i == crf_sequence_length) {
            label_prev = y[i-1]
            label_cur = "STOP"
            label_prev_yHat = yHat[i-1]
            label_cur_yHat = "STOP"
        }
        else if ( i == 1) {
            label_prev = "START"
            label_cur = y[i]      
            label_prev_yHat = "START"
            label_cur_yHat = yHat[i]      
        }
        else {
            label_prev = y[i-1]             
            label_cur = y[i]
            label_prev_yHat = yHat[i-1]
            label_cur_yHat = yHat[i]
        }                    
        # Computes the sum of the values of a single feature function across all positions in the given crf sequence
        weights[label_prev,label_cur,] = weights[label_prev,label_cur,] + feature_values*learning_rate
        weights[label_prev_yHat,label_cur_yHat,] = weights[label_prev_yHat,label_cur_yHat,] - feature_values*learning_rate
    }
    #print(weights[,,"fft14"])
    return (weights)    
}


update_features_expectation = function(G, x, y, weights, learning_rate, labels, alpha, beta) {
    crf_sequence_length = nrow(x)   
    crf_sequence_length = crf_sequence_length + 1
    # get the features from the weights
    features = dimnames(weights)[[3]]
    for(feature in features) {
        feature_value = compute_single_feature_across_sequence(x,feature)
        expectation = compute_expectation(alpha, beta, G, x, feature, labels)            
        cat("feature_value: ", feature_value, ", expectation: ", expectation, "\n")           
        for (i in 1:crf_sequence_length) {
            if (i == crf_sequence_length) {
                label_prev = y[i-1]
                label_cur = "STOP"
            }
            else if ( i == 1) {
                label_prev = "START"
                label_cur = y[i]      
            }
            else {
                label_prev = y[i-1]             
                label_cur = y[i]
            }                    
            # print(label_prev)
            # print(label_cur)
            weights[label_prev,label_cur,feature] = weights[label_prev,label_cur,feature] + learning_rate*(feature_value - expectation)           
        }       
    }
    #print(weights)
    return (weights)    
}

normalize = function(weights) {
    max_w = max(weights)
    min_w = min(weights)
    diff = max_w - min_w
    for (i in 1:dim(weights)[1]) {
        for (j in 1:dim(weights)[2]) {
            for (k in 1:dim(weights)[3]) {
                weights[i,j,k] = (weights[i,j,k] - min_w)*1.0/diff
            }
        }
    }  
    return(weights)
}
