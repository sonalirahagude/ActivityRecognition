# Author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module updates the weights of the feature functions in the CRF

update_features = function(x, y, yHat, weights, learning_rate, labels) {
    crf_sequence_length = nrow(x)   
    #x = rbind(x,x[crf_sequence_length,])
    crf_sequence_length = crf_sequence_length + 1
    # get the features from the weights
    features = dimnames(weights)[[3]]

    feature_values = array(0,dim=c(length(features)), dimnames = features)
    # calculate the feature sum across the sequence
    feature_values = colSums(x)
    
    #print(x)
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
        for(feature in features) {
            weights[label_prev,label_cur,feature] = weights[label_prev,label_cur,feature] + compute_single_feature_across_sequence(x,y,feature, label_prev, label_cur)*learning_rate
            weights[label_prev_yHat,label_cur_yHat,feature] = weights[label_prev_yHat,label_cur_yHat,feature] - compute_single_feature_across_sequence(x,yHat,feature, label_prev_yHat, label_cur_yHat)*learning_rate
        }
    }
    #print(weights[,,"fft14"])
    return (weights)    
}



# uses a intersection of the original and shifted label sequence to compute the feature value accross the sequence faster
update_features_fast = function(x, y, yHat, weights, learning_rate, labels) {
    crf_sequence_length = nrow(x)   
    x = rbind(x,x[crf_sequence_length,])
    crf_sequence_length = crf_sequence_length + 1
    # get the features from the weights
    features = dimnames(weights)[[3]]

    feature_values = array(0,dim=c(length(features)), dimnames = features)
    # calculate the feature sum across the sequence
    feature_values = colSums(x)
    
    # print(x)
    # print(weights[,,"fft14"])
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
        y_appended = append(y,"START",0)
        y_shifted = Lag(y_appended,-1)
        y_shifted[y_shifted == ""] = "STOP"
        prev_indices = which(y_appended == label_prev)
        cur_indices = which(y_shifted == label_cur)
        sum_indices_y =  intersect(prev_indices,cur_indices)
        
        yHat_appended = append(yHat,"START",0)
        yHat_shifted = Lag(yHat_appended,-1)
        yHat_shifted[yHat_shifted == ""] = "STOP"
        prev_indices = which(yHat_appended == label_prev_yHat)
        cur_indices = which(yHat_shifted == label_cur_yHat)
        sum_indices_yHat =  intersect(prev_indices,cur_indices)
        feature_values = colSums(as.matrix(x[sum_indices_y,]))
        # print(feature_values)
        feature_values_yHat = colSums(as.matrix(x[sum_indices_yHat,]))
        weights[label_prev,label_cur,] = weights[label_prev,label_cur,] + feature_values*learning_rate
        weights[label_prev_yHat,label_cur_yHat,] = weights[label_prev_yHat,label_cur_yHat,] - feature_values_yHat*learning_rate

    }
    # print(weights[,,"fft14"])
    # stop("")
    return (weights)    
}

update_features_fast_with_l2_reguralization = function(x, y, yHat, weights, learning_rate, labels,regularizer) {
    crf_sequence_length = nrow(x)   
    x = rbind(x,x[crf_sequence_length,])
    crf_sequence_length = crf_sequence_length + 1
    # get the features from the weights
    features = dimnames(weights)[[3]]

    feature_values = array(0,dim=c(length(features)), dimnames = features)
    # calculate the feature sum across the sequence
    feature_values = colSums(x)
    
    #print(x)
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
        y_appended = append(y,"START",0)
        y_shifted = Lag(y_appended,-1)
        y_shifted[y_shifted == ""] = "STOP"
        prev_indices = which(y_appended == label_prev)
        cur_indices = which(y_shifted == label_cur)
        sum_indices_y =  intersect(prev_indices,cur_indices)
        
        yHat_appended = append(yHat,"START",0)
        yHat_shifted = Lag(yHat_appended,-1)
        yHat_shifted[yHat_shifted == ""] = "STOP"
        prev_indices = which(yHat_appended == label_prev_yHat)
        cur_indices = which(yHat_shifted == label_cur_yHat)
        sum_indices_yHat =  intersect(prev_indices,cur_indices)
        
        feature_values = colSums(as.matrix(x[sum_indices_y,]))
        feature_values_yHat = colSums(as.matrix(x[sum_indices_yHat,]))
        
        # if we are updating the same set of weights for y and yHat, then subtract the regularizer term only once
        # if (label_prev == label_prev_yHat && label_cur == label_cur_yHat) {
        #         weights[label_prev,label_cur,] = weights[label_prev,label_cur,] + feature_values*learning_rate - feature_values_yHat*learning_rate - (weights[label_prev,label_cur,]*regularizer)
        # } else {
        #     weights[label_prev,label_cur,] = weights[label_prev,label_cur,] + feature_values*learning_rate  - (weights[label_prev,label_cur,]*regularizer)
        #     weights[label_prev_yHat,label_cur_yHat,] = weights[label_prev_yHat,label_cur_yHat,] - feature_values_yHat*learning_rate - (weights[label_prev_yHat,label_cur_yHat,]*regularizer)
        # }
    }
    #print(weights[,,"fft14"])
    return (weights)    
}

update_features_fast_with_l1_reguralization = function(x, y, yHat, weights, learning_rate, labels,regularizer) {
    crf_sequence_length = nrow(x)   
    x = rbind(x,x[crf_sequence_length,])
    crf_sequence_length = crf_sequence_length + 1
    # get the features from the weights
    features = dimnames(weights)[[3]]

    feature_values = array(0,dim=c(length(features)), dimnames = features)
    # calculate the feature sum across the sequence
    feature_values = colSums(x)
    
    #print(x)
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
        y_appended = append(y,"START",0)
        y_shifted = Lag(y_appended,-1)
        y_shifted[y_shifted == ""] = "STOP"
        prev_indices = which(y_appended == label_prev)
        cur_indices = which(y_shifted == label_cur)
        sum_indices_y =  intersect(prev_indices,cur_indices)
        
        yHat_appended = append(yHat,"START",0)
        yHat_shifted = Lag(yHat_appended,-1)
        yHat_shifted[yHat_shifted == ""] = "STOP"
        prev_indices = which(yHat_appended == label_prev_yHat)
        cur_indices = which(yHat_shifted == label_cur_yHat)
        sum_indices_yHat =  intersect(prev_indices,cur_indices)
        
        feature_values = colSums(as.matrix(x[sum_indices_y,]))
        feature_values_yHat = colSums(as.matrix(x[sum_indices_yHat,]))
        
        # if we are updating the same set of weights for y and yHat, then subtract the regularizer term only once
        # if (label_prev == label_prev_yHat && label_cur == label_cur_yHat) {
        #         weights[label_prev,label_cur,] = weights[label_prev,label_cur,] + feature_values*learning_rate - feature_values_yHat*learning_rate - regularizer
        # } else {
        #     weights[label_prev,label_cur,] = weights[label_prev,label_cur,] + feature_values*learning_rate  - regularizer
        #     weights[label_prev_yHat,label_cur_yHat,] = weights[label_prev_yHat,label_cur_yHat,] - feature_values_yHat*learning_rate - regularizer
        # }

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
        #cat("feature_value: ", feature_value, ", expectation: ", expectation, "\n")           
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


update_features_expectation_fast = function(G, x, y, weights, learning_rate, labels, alpha, beta) {
    crf_sequence_length = nrow(x)   
    x = rbind(x,x[crf_sequence_length,])
    crf_sequence_length = crf_sequence_length + 1
    # get the features from the weights
    features = dimnames(weights)[[3]]    
    expectations = compute_expectation_all_features(alpha, beta, G, x, labels)            
    #cat("feature_value: ", feature_value, ", expectation: ", expectation, "\n")           
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

        y_appended = append(y,"START",0)
        y_shifted = Lag(y_appended,-1)
        y_shifted[y_shifted == ""] = "STOP"
        prev_indices = which(y_appended == label_prev)
        cur_indices = which(y_shifted == label_cur)
        sum_indices_y =  intersect(prev_indices,cur_indices)
        #print(sum_indices_y)
        feature_values = colSums(as.matrix(x[sum_indices_y,]))
        
        # print(label_prev)
        # print(label_cur)
        weights[label_prev,label_cur,] = weights[label_prev,label_cur,] + learning_rate*(feature_values - expectations)           
    }       
    #print(weights)
    return (weights)    
}


# Computes the sum of the values of a single feature function across all positions in the given crf sequence for a given label pair
compute_single_feature_across_sequence = function(x, y, feature, label_prev, label_cur) {
    crf_sequence_length = nrow(x)   
    #crf_sequence_length = crf_sequence_length + 1
    feature_value = 0.0
    # print (y)
    # print(crf_sequence_length)
    # get the features from the weights
    if(label_prev == "START" && label_cur == y[1]) {
        feature_value = feature_value + x[1,feature]
    }
    if(crf_sequence_length > 2) {
        for (i in 2:crf_sequence_length) {           
            # cat("i: " , i, "\n")
            if(label_prev == y[i-1] && label_cur == y[i]) {
                feature_value = feature_value + x[i,feature]  
            } 
            #cat("feature_value: ", feature_value,"\n")
        }
        # last one    
        if(y[crf_sequence_length]==label_prev && label_cur == "STOP")  {
            feature_value = feature_value + x[crf_sequence_length,feature]            
        }    
    }
    
     #print(feature_value)
    return (feature_value)
}

