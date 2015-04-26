# Author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module contains functions to compute the G matrices for inference and learning in CRF


compute_g_matrices = function(x,weights, labels) {

    no_of_labels = length(labels)
    crf_sequence_length = nrow(x)
    crf_sequence_length = crf_sequence_length + 1
    #Creates a 3 dimensional G matrix, total 'crf_sequence_length' matrices each of size no_of_labels*no_of_labels
    G = array(0,dim=c(no_of_labels, no_of_labels, crf_sequence_length),dimnames=(list(labels, labels, 1:crf_sequence_length)))
    for (i in 1:crf_sequence_length) {
        # if (i == crf_sequence_length) {
        #     label_prev = y[i-1]
        #     label_cur = "STOP"
        #     # for the n+1 step, we dont have x, so use the previous one
        #     G[label_prev,label_cur,i] = compute_position_feature_values(x[i-1,],label_cur,label_prev,weights)       
        # }
        # else if ( i == 1) {
        #     label_prev = "START"
        #     label_cur = y[i]
        #     G[label_prev,label_cur,i] = compute_position_feature_values(x[i,],label_cur,label_prev,weights)
        # }
        # else {
        #     label_prev = y[i-1]             
        #     label_cur = y[i]
        #     G[label_prev,label_cur,i] = compute_position_feature_values(x[i,],label_cur,label_prev,weights)
        # }
        for(label_prev in labels) {
            for(label_cur in labels) {
                if (i == crf_sequence_length) {
                    # for the n+1 step, we dont have x, so use the previous one
                    G[label_prev,label_cur,i] = compute_position_feature_values(x[i-1,],label_cur,label_prev,weights)       
                }
                else if ( i == 1) {
                    G[label_prev,label_cur,i] = compute_position_feature_values(x[i,],label_cur,label_prev,weights)
                }
                else {
                    G[label_prev,label_cur,i] = compute_position_feature_values(x[i,],label_cur,label_prev,weights)
                }
            }
        }        
    }
    return (G)
}

compute_position_feature_values = function(token,label_cur,label_prev,weights) {
    total = 0.0
    #print(dimnames(weights))
    for(feature in colnames(token)) {
         # print (feature)
         # print (label_prev)
         # print (label_cur)
        total = total + weights[label_prev,label_cur,feature] * token[1,feature]
    }
    return(total)
}