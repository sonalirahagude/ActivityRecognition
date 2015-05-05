# Author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module implements the logic to calculate forward and backward vectors and compute the expectation of log linear probability

# compute_forward_backword_vectors = function(G,x,y, labels) {
# 	crf_sequence_length = length(y)
# 	crf_sequence_length = crf_sequence_length + 1
# 	no_of_labels = length(labels)
# 	alpha = array(0, dim=c(crf_sequence_length, no_of_labels), dimnames = list(1:crf_sequence_length,labels))
# 	beta = array(0, dim=c(no_of_labels, crf_sequence_length), dimnames = list(labels,1:crf_sequence_length))

#     alpha[1,] = exp(G["START", , 1])
#     beta[,crf_sequence_length - 1] = exp(G[,"STOP", crf_sequence_length]) 
# 	for(i in 2:crf_sequence_length) {
# 		for (u in labels) {
# 			alpha[i,u] = sum(alpha [i-1,] * exp(G[,u,i]))
# 			beta[u,crf_sequence_length -i] = sum(exp(G[u,,crf_sequence_length-i+1]) * beta[,crf_sequence_length-i+1] )		
# 		}
# 	}
# 	# normalize alpha and beta
# 	# for(i in 1: crf_sequence_length) {
# 	# 	alpha [i,] = alpha[i,]/sum(alpha[i,])
# 	# 	beta[,i] = beta[,i]/sum(beta[,i])
# 	# }
# 	return (list(alpha,beta))
# }


compute_forward_backword_vectors = function(G,x,y, labels) {
    crf_sequence_length = length(y)
    crf_sequence_length = crf_sequence_length + 1
    no_of_labels = length(labels)
    log_alpha = array(0, dim=c(crf_sequence_length, no_of_labels), dimnames = list(1:crf_sequence_length,labels))
    log_beta = array(0, dim=c(no_of_labels, crf_sequence_length), dimnames = list(labels,1:crf_sequence_length))

    log_alpha[1,] = G["START", , 1]
    log_beta[,crf_sequence_length - 1] = (G[,"STOP", crf_sequence_length]) 
    for(i in 2:crf_sequence_length) {
        for (u in labels) {
            log_alpha[i,u] = logSumExp(log_alpha [i-1,] + (G[,u,i]))
            log_beta[u,crf_sequence_length -i] = logSumExp((G[u,,crf_sequence_length-i+1]) + log_beta[,crf_sequence_length-i+1] )      
        }
    }
    alpha = (log_alpha)
    beta = (log_beta)
    #normalize alpha and beta
    for(i in 1: crf_sequence_length) {
        if(sum(alpha[i,]) == 0){
            next
        }
      alpha [i,] = alpha[i,]/sum(alpha[i,])
      if(sum(beta[,i]) == 0){
            next
        }
      beta[,i] = beta[,i]/sum(beta[,i])
    }    
    return (list(alpha,beta))
}


compute_expectation = function(alpha, beta, G, x, feature, labels) {
	crf_sequence_length = nrow(x)
	crf_sequence_length = crf_sequence_length + 1
    sum = 0.0
    # print(G)
    for(i in 1: crf_sequence_length) {
    	for(u in labels) {
    		for (v in labels) {
    			if(i == crf_sequence_length) {
    					val = x[i-1,feature]*alpha[i-1,u]/alpha[crf_sequence_length,"STOP"]*exp(G[u,v,i])
    					sum = sum + val
    					#cat ("feature: " , feature, ", i: " , i, ", u: " , u, ", ", "v: " , v, ", x[i,feature]: " , x[i-1,feature], ", alpha[i-1,u]: " , alpha[i-1,u], ", G[u,v,i]: " , G[u,v,i] ,  ", sum: ", sum, "\n"  )
    			}
    			else if(i == 1 ) {
    					val = x[i,feature]* beta[v, i]/alpha[crf_sequence_length,"STOP"]*exp(G[u,v,i])
    					sum = sum + val
    					#cat ("feature: " , feature, ", i: " , i, ", u: " , u, ", ", "v: " , v, ", x[i,feature]: " , x[i,feature],  ", G[u,v,i]: " , G[u,v,i] , ", beta[v,i]: ", beta[v,i], ", sum: ", sum, "\n"  )
    			}
    			else {
    				val = x[i,feature]*alpha[i-1,u]*beta[v, i] /alpha[crf_sequence_length,"STOP"] *exp(G[u,v,i])
    				sum = sum + val
    				#cat ("feature: " , feature, ", i: " , i, ", u: " , u, ", ", "v: " , v, ", x[i,feature]: " , x[i,feature], ", alpha[i-1,u]: " , alpha[i-1,u], ", G[u,v,i]: " , G[u,v,i] , ", beta[v,i]: ", beta[v,i], ", sum: ", sum, "\n"  )
    			}
    		}
    	}    
    }
    #sum =sum / alpha[crf_sequence_length,"STOP"]
    print(sum)    
    if(is.nan(sum) || is.infinite(sum)) {
        print(alpha)
        print(beta)
        print(G)
        print(feature)
        stop("")
    }
    return (sum)
}