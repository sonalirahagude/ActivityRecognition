# Author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module implements contrasive divergence technique to learn the CRF weights/
#               It uses Gibbs sample with 4 number of rounds. 

contrasive_divergence = function(G, y, labels) {
    rounds = 4
    crf_sequence_length = length(y)
    #select an initial value close to y, we start with the first position
    y_new = y
   
    for (epoch in  1 : rounds) {
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
            scaled = array(FALSE, dim=length(labels),dimnames=list(labels))
            #now, compute for every possible value of the tag at position i
            for (u in labels ) {
                # print(i)
                # print(u)
                # print(label_prev)
                # print(label_next)
                # print(G[label_prev, u, i])
                # print(G[u, label_next, i+1])
                p[i,u] = exp(G[label_prev, u, i]) * exp(G[u, label_next, i+1])                
                if (p[i,u] > 10000) {
                    p[i,u] = p[i,u]/10000
                    scaled[u] = TRUE
                }            
                sum = sum + p[i,u]
            }

            
            # choose a random number for sampling the data
            rand_no = runif(1) 
            rand_no = rand_no * (sum)
            
            csum = 0;
            for (u in labels ) {                
                
                if(scaled[u]) {
                    p[i,u] = p[i,u]/sum
                    p[i,u] = p[i,u] * 10000
                }
                else {
                    p[i,u] = p[i,u]/sum               
                }
                csum = csum + p[i,u]
                #If the rand_no falls within this range of buckets, choose the value u, ignore labels 'START' and 'STOP'
                if(rand_no < csum && u!='START' && u!= 'STOP') {
                    y_new[i] = u
                    break
                }                
            }                        
        }       
    }
    return (y_new)
}