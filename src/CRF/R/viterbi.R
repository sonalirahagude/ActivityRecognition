# Author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module implements viterbi algorithm to infer the most likely label sequence

#The G matrix's last dimension is the length of the sentence
viterbi = function (G, x, labels)  {
	crf_sequence_length = nrow(x)
    #U represents the score of the best sequence of tags from position 1 to k,
    U = array(0, dim = c(crf_sequence_length,length(labels)),dimnames = list(1:crf_sequence_length, labels) )
    for (i in 1 : crf_sequence_length) {
        for (j in 1 : length(labels)) {
           # we regard values related to START (i=0) as zero, uniform
            # across all tags and to the starting tag ie. the score of
            # sequence being j for all j is the same, ie. zero. We can
            #modify this to give make the score 1 for SPACE,since SPACE is
            # the most probable first tag in the sequence
            # BASE CASE: U(1,v) = g_1(START,v);
            label_cur = labels[j]
            if(i == 1) {
            	label_prev = "START"
                U[i,j] = G[label_prev,label_cur,i]
            }
            else{
                #find max of U[i-1] -- max U(i-1, : )            
                U[i,j] = max ( U[i-1,] + G[,label_cur,i] ) 
            }
        }
    }

    #find the best sequence from U now,
    yHat = array(0,dim=crf_sequence_length)
    #yHat = zeros(sampleLength,1);
    #[maxU yHat(sampleLength)] = max(U(sampleLength , : ));
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
    # print("crf_sequence_length: ")
    # print(crf_sequence_length)
    crf_sequence_length = crf_sequence_length - 1
    for( i in crf_sequence_length:1 ) {     
    	# print(x)
    	# print("i:")
    	# print(i)
    	# print(U[i,])
    	# print(G[,max_label,i])
        max_index = which.max(U[i,] + G[,max_label,i])
        max_label = dimnames(U)[[2]][max_index]
        if(max_label == 'START' || max_label == 'STOP') {
    		# predicting the label of the next timestep
    		max_label = yHat[i+1]
	    }
        yHat[i] = max_label    
        
    }
    return(yHat)
}