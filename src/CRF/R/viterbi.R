# Author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module implements viterbi algorithm to infer the most likely label sequence given the feature function weights and G matrix for a particular CRF sequence x

#The G matrix's last dimension is the length of the sentence
viterbi = function (G, x, labels)  {
	crf_sequence_length = nrow(x)
    #U represents the score of the best sequence of tags from position 1 to k
    U = array(0, dim = c(crf_sequence_length,length(labels)),dimnames = list(1:crf_sequence_length, labels) )
    for (i in 1 : crf_sequence_length) {
        for (label_cur in labels) {
            # BASE CASE: U(1,v) = g_1(START,v);
            # print(label_cur)
            # print(i)
            # print(G[,label_cur,i])

            if(i == 1) {
            	label_prev = "START"
                U[i,label_cur] = G[label_prev,label_cur,i]
            }
            else{
                #find max of U[i-1] -- max U(i-1, : )    
                # print(label_cur)
                # print(U[i-1,])
                # print(G[,label_cur,i])
                U[i,label_cur] = max ( U[i-1,] + G[,label_cur,i] ) 
            }
        }
    }
    #print(U)
    #find the best sequence from U now,
    yHat = array(0,dim=crf_sequence_length)
    max_index = which.max(U[crf_sequence_length,])
    max_label = dimnames(U)[[2]][max_index]
    
    if(max_label == 'START' || max_label == 'STOP') {
    	# predicting the most common label -- sedentary
    	max_label = 'Sedentary'
    }
    yHat[crf_sequence_length] = max_label
    if(crf_sequence_length == 1) {
    	return(yHat)
    }
    
        
    crf_sequence_length = crf_sequence_length - 1
    for( i in crf_sequence_length:1 ) {             
        max_index = which.max(U[i,] + G[,max_label,i+1])
        max_label = dimnames(U)[[2]][max_index]
        # print(G[,,i+1])
        # print(max_index)
        # print(max_label)
        # #stop("")
        if(max_label == 'START' || max_label == 'STOP') {
    		# predicting the label of the next timestep
    		yHat[i] = yHat[i+1]
	    }
        else {
        yHat[i] = max_label
        }
        
    }
    return(yHat)
}