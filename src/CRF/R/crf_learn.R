# Author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module updates the weights of the feature functions in the CRF

# modify this to include multiple feature functions
update_features = function(x,y,weights_old,learning_rate,labels) {
	crf_sequence_length = nrow(x)	
	weights = weights_old
	crf_sequence_length = crf_sequence_length + 1
	# get the features from the weights
	features = dimnames(weights_old)[[3]]
	for(feature in features) {
		feature_value = compute_single_feature_across_sequence(x,feature)
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
            # print(feature)
     	   weights[label_prev,label_cur,feature] = weights[label_prev,label_cur,feature] + feature_value*learning_rate
    	}       
    }
    return (weights)
    
}

normalize = function(weights) {
	sum = 0.0
	for (i in 1:dim(weights)[1]) {
		for (j in 1:dim(weights)[2]) {
			for (k in 1:dim(weights)[3]) {
				sum = sum + weights[i,j,k]
			}
		}
	}
	for (i in 1:dim(weights)[1]) {
		for (j in 1:dim(weights)[2]) {
			for (k in 1:dim(weights)[3]) {
				weights[i,j,k] = weights[i,j,k]/sum
			}
		}
	}
	return(weights)
}

compute_single_feature_across_sequence = function(x, feature) {
	crf_sequence_length = nrow(x)	
	crf_sequence_length = crf_sequence_length + 1
	feature_value = 0.0
	# get the features from the weights
    for (i in 1:crf_sequence_length) {
        if (i == crf_sequence_length) {
            # for the n+1 step, we dont have x, so use the previous one
            feature_value = feature_value + x[i-1,feature]
        }        
        else {
            feature_value = feature_value + x[i,feature]

        }
        return (feature_value)
    }
    
}
