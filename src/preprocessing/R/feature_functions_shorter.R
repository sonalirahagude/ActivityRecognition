# author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module contains functions to generate different feature function templates for the CRF model. These will be written in form of sequences in a file. 
#              The CRF trainer module will read this file and generate feature functions by appending indicator functions fot the output tokens. 



get_shorter_sequence = function(seq,position, options = NULL) {
    no_of_steps_backward = as.numeric(options['no_of_steps_backward'])
    no_of_steps_forward = as.numeric(options['no_of_steps_forward'])
    seq_range = (position - no_of_steps_backward):(position+no_of_steps_forward)
    seq_range = seq_range[seq_range>0 & seq_range<=nrow(seq)]
    seq = seq[seq_range,]
    return (seq)
}


no_of_pauses_shorter = function(seq, position, labels, options = NULL) {
    if ("lat" %in% colnames(seq) & "lon" %in% colnames(seq)) {
        seq = get_shorter_sequence(seq, position, options)
        return(no_of_pauses(seq,position, labels,options))
    }
}

# finds distance between 2points defined as (lat1,lon1) & (lat2,lon2)s
net_distance_shorter = function(seq, position, labels, options = NULL) {
    if ("lat" %in% colnames(seq) & "lon" %in% colnames(seq)) {
        seq = get_shorter_sequence(seq, position, options)
        return(net_distance(seq, position, labels, options))
    }   
}

# finds average speed
average_speed_shorter = function(seq, position, labels, options = NULL) {
    if ("speed" %in% colnames(seq)) {
        seq = get_shorter_sequence(seq, position, options)
        avg = mean(seq$speed)
        return (avg)
    }
}

sd_speed_shorter = function(seq, position, labels, options = NULL) {
    if ("speed" %in% colnames(seq)) {
        seq = get_shorter_sequence(seq, position, options)
        std_dev = sd(seq$speed)
        return (std_dev)
    }
}

coefficient_of_variation_shorter = function(seq, position, labels, options = NULL) {
    if ("speed" %in% colnames(seq)) {
        seq = get_shorter_sequence(seq, position, options)
        std_dev = sd(seq$speed)
        avg = mean(seq$speed)
        if (avg > 0) {            
            return (std_dev*1.0/avg)
        } else {
            return (0.0)
        }
    }
}



# finds total distance covered
total_distance_shorter = function(seq, position, labels, options = NULL) {
    if ("distance" %in% colnames(seq)) {
        seq = get_shorter_sequence(seq, position, options)
        total = sum(seq$distance)
        return (total)
    }
}

net_to_total_distance_ratio_shorter = function(seq, position, labels, options = NULL) {
    if ("distance" %in% colnames(seq)) {
        seq = get_shorter_sequence(seq, position, options)
        return(net_to_total_distance_ratio(seq, position, labels, options))        
    }    
}


# no of changes in directions
direction_change_count_shorter = function(seq, position, labels, options = NULL) {
    seq = get_shorter_sequence(seq, position, options)
    return(direction_change_count(seq, potion, labels, options))
}
