# Author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module implements contrasive divergence technique to learn the CRF weights/
#               It uses Gibbs sample with 4 number of rounds. 

contrasive_divergence = function(G, y, labels, gibbs_sampling_rounds) {
    rounds = gibbs_sampling_rounds
    crf_sequence_length = length(y)
    #select an initial value close to y, we start with the first position
    #y_new = y
    y_new = sample(labels, crf_sequence_length ,replace=TRUE)
    y_old = y_new
    for (round in  1 : rounds) {
        for (i in 1 : crf_sequence_length) {
            if (i == crf_sequence_length) {
                label_next = "STOP"
            }
            else {
                label_next = y_new[i+1]
            }
            if (i == 1) {
                label_prev = "START"
            }
            else {
                label_prev = y_new[i-1]
            }
            
            sum = 0;           
            no_of_labels = length(labels)
            p = array(0, dim=c(crf_sequence_length, no_of_labels), dimnames = list(1:crf_sequence_length,labels))
            #now, compute for every possible value of the tag at position i
            for (u in labels ) {
                # print(i)
                # print(u)
                # print(label_prev)
                # print(label_next)
                # print(G[label_prev, u, i])
                # print(G[u, label_next, i+1])
                # calculate the log of the numerator
                p[i,u] = (G[label_prev, u, i]) + (G[u, label_next, i+1])                                                        
                # print(p[i,u])
                # print(sum)
            }
            # now use the log sum exp trick to actually calculate the probabilities
            lse = logSumExp(p[i,])
            # print(lse)
            # print (p[i,])
            p[i,] = exp(p[i,] - lse)            
            # print (p)
            # choose a random number for sampling the data
            rand_no = runif(1) 
            rand_no = rand_no * sum(p[i,])            
            csum = 0;
            for (u in labels ) {                                
                #p[i,u] = p[i,u]/sum                               
                csum = csum + p[i,u]
                #If the rand_no falls within this range of buckets, choose the value u
                # print(rand_no)
                # print(p[i,u])
                # print(csum)
                if(rand_no < csum && u!='START' && u!= 'STOP') {
                    y_new[i] = u
                    break
                }                
            }                        
        }       
    }
    # cat("y:" , y, "\n")
    # cat("y_old:" , y_old, "\n")
    # cat("y_new:" , y_new, "\n\n")
    return (y_new)
}   