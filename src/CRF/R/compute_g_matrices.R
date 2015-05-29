# Author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module contains functions to compute the G matrices for inference and learning in CRF


# compute_g_matrices = function(x,weights, labels) {

#     no_of_labels = length(labels)
#     crf_sequence_length = nrow(x)
#     crf_sequence_length = crf_sequence_length + 1

#     #Creates a 3 dimensional G matrix, total 'crf_sequence_length' matrices each of size no_of_labels*no_of_labels
#     G = array(0,dim=c(no_of_labels, no_of_labels, crf_sequence_length),dimnames=(list(labels, labels, 1:crf_sequence_length)))
#     for (i in 1:crf_sequence_length) {
#         #print(typeof(x))
#         #print(x)
#         #print(i)
#         # We need to calculate all the cells for the prediction part, so that all possible combinations are available while inferring the mostly likely sequence
#         for(label_prev in labels) {
#             for(label_cur in labels) {
#                 if (i == crf_sequence_length) {
#                     # for the n+1 step, we don't have x, so use the previous one      
#                     #cat("i: ", i, ", x[i-1]: " , x[i-1,], ", label_cur: " , label_cur, ", label_prev: ", label_prev,"\n")  
#                     G[label_prev,label_cur,i] = compute_position_feature_values(x[i-1,],label_cur,label_prev,weights)       
#                 }
#                 else {
#                     #cat("i: ", i, ", x[i]: " , x[i,], ", label_cur: " , label_cur, ", label_prev: ", label_prev,"\n")  
#                     G[label_prev,label_cur,i] = compute_position_feature_values(x[i,],label_cur,label_prev,weights)
#                 }                
#             }
#         }        
#     }
#     print(G[,,1])
#     return (G)
# }


compute_g_matrices = function(x,weights, labels) {

    no_of_labels = length(labels)
    crf_sequence_length = nrow(x)
    x = rbind(x,x[crf_sequence_length,])
    crf_sequence_length = crf_sequence_length + 1    
    #Creates a 3 dimensional G matrix, total 'crf_sequence_length' matrices each of size no_of_labels*no_of_labels
    G = array(0,dim=c(no_of_labels, no_of_labels, crf_sequence_length),dimnames=(list(labels, labels, 1:crf_sequence_length)))
        # We need to calculate all the cells for the prediction part, so that all possible combinations are available while inferring the mostly likely sequence
    for(label_prev in labels) {
        for(label_cur in labels) {
                #cat(" x: " , x, ", label_cur: " , label_cur, ", label_prev: ", label_prev,"\n")                  
                G[label_prev,label_cur,] = t( x %*% as.matrix(weights[label_prev,label_cur,])) 
        }
    }            
    return (G)
}



# For the training phase, we need to enumerate the G matrix only for the observed label pairs, 
# so that the inference part(viterbi/contrasive divergence) within the training algorithm can be done correct
compute_g_matrices_train = function(x,y,weights, labels) {

    no_of_labels = length(labels)
    crf_sequence_length = nrow(x)
    crf_sequence_length = crf_sequence_length + 1

    #Creates a 3 dimensional G matrix, total 'crf_sequence_length' matrices each of size no_of_labels*no_of_labels
    G = array(0,dim=c(no_of_labels, no_of_labels, crf_sequence_length),dimnames=(list(labels, labels, 1:crf_sequence_length)))
    for (i in 1:crf_sequence_length) {
        if (i == crf_sequence_length) {
            label_prev = y[i-1]
            label_cur = "STOP"
            # for the n+1 step, we dont have x, so use the previous one
            G[label_prev,label_cur,i] = compute_position_feature_values(x[i-1,],label_cur,label_prev,weights)       
        }
        else if ( i == 1) {
            label_prev = "START"
            label_cur = y[i]
            G[label_prev,label_cur,i] = compute_position_feature_values(x[i,],label_cur,label_prev,weights)
        }
        else {
            label_prev = y[i-1]             
            label_cur = y[i]
            G[label_prev,label_cur,i] = compute_position_feature_values(x[i,],label_cur,label_prev,weights)
        }
          
    }
    return (G)
}

# Computes the sum of all the feature functions for a particular position 'i' in the given crf sequence
# compute_position_feature_values = function(token,label_cur,label_prev,weights) {
#     total = 0.0
#     for(feature in names(token)) {
#         # cat("weights: ", weights[label_prev,label_cur,feature], "\n")
#          total = total + weights[label_prev,label_cur,feature] * token[feature]        
#          # cat("total: ", total, "\n")
#     }
#     # print(total)
#     return(total)
# }