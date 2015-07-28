#!/usr/bin/env python
"""
author : Sonali Rahagude (srahagud@eng.ucsd.edu)
Script to train CRF, accepts input file which is complaint to CRFSuite requirements
"""

import crfsuite
import sys
import pandas as pd
import crf_train
import util

def write_prediction_to_file (prediction_seq, label_seq, overlapped_predictions, output, options_dict):

    crf_sequence_length = options_dict ['crf_sequence_length']
    sliding_window_length = options_dict ['sliding_window_length']

    '''
    if len(overlapped_predictions) == 0 :
        if crf_sequence_length != len(prediction_seq):
            # write from 0 to len(prediction_seq)
            for i in range(0: legnt)
            overlapped_predictions = []
            return overlapped_predictions
        else:         
            # write from 0 to (prediction_seq - sliding window length)
            new_start = crf_sequence_length - sliding_window_length
            overlapped_predictions = prediction_seq[new_start:len(prediction_seq)]
            return overlapped_predictions
    '''
    # voting mechanism: we can find overlap between subsequent sequences as follows,
    ## 1. for the overlap received from the previous sequence, voting can be done and written
    ## 2. for no overlap region, the prediction can be written as are, to the output file
    ## 2. if the sequence is not cut off, it will have some overlap with the next sequence. So the overlap can be passed to the next
    ##    of this method for voting

    # I assume that the length of the prediction sequence should be at least the length of the overlapped predictions. This will 
    # fail if the sequence cut off exactly at the provided sequence length (crf_sequence_file). 
    # Need to have an exact way of finding overlaps. Sequences could have an additional feature in the input file
    # telling if shares an overlap with the next one.
    for i in range(0, len(overlapped_predictions)) :

        if prediction_seq[i] != overlapped_predictions[i] :
            
            print ("applying voting. i: ",i,", prediction_seq[i]: ", prediction_seq[i], ", overlapped_predictions[i]: ",overlapped_predictions[i],"label_seq[i]: ",label_seq[i],"\n")
            similarity_cur = util.get_similarity(prediction_seq[i],prediction_seq[0:len(prediction_seq)])
            similarity_prev = util.get_similarity(overlapped_predictions[i], overlapped_predictions)
            print("similarity_cur: ", similarity_cur, ", similarity_prev: ", similarity_prev, "\n")
            
            if similarity_prev < similarity_cur :
                output.write( prediction_seq[i] + "," + label_seq[i] +"\n")
            else :
                output.write( overlapped_predictions[i] + "," + label_seq[i] +"\n")

        else :
            output.write( prediction_seq[i] + "," + label_seq[i] +"\n")

    no_overlap_region = min(crf_sequence_length - sliding_window_length, len(prediction_seq))

    for i in range(len(overlapped_predictions), no_overlap_region) :
        output.write( prediction_seq[i] + "," + label_seq[i] +"\n")

    if(no_overlap_region == len(prediction_seq)):
        overlapped_predictions = []
        return overlapped_predictions

    overlapped_predictions = prediction_seq[no_overlap_region:crf_sequence_length]
    return overlapped_predictions
   
   
'''
    for i in range(0, actual_overlap) :
        if len(overlapped_predictions) == 0 :
                output.write( prediction_seq[i] + "," + label_seq[i] +"\n")
        else :
            # apply voting
            if prediction_seq[i] != overlapped_predictions[i] :
                
                print ("applying voting. i: ",i,", prediction_seq[i]: ", prediction_seq[i], ", overlapped_predictions[i]: ",overlapped_predictions[i],"label_seq[i]: ",label_seq[i],"\n")
                similarity_cur = util.get_similarity(prediction_seq[i],prediction_seq[0:actual_overlap])
                similarity_prev = util.get_similarity(overlapped_predictions[i], overlapped_predictions)
                print("similarity_cur: ", similarity_cur, ", similarity_prev: ", similarity_prev, "\n")
                
                if similarity_prev < similarity_cur :
                    output.write( prediction_seq[i] + "," + label_seq[i] +"\n")
                else :
                    output.write( overlapped_predictions[i] + "," + label_seq[i] +"\n")

            else :
                output.write( prediction_seq[i] + "," + label_seq[i] +"\n")

    if len(prediction_seq) != crf_sequence_length : 
        overlapped_predictions = []
        return overlapped_predictions

    new_start = crf_sequence_length - sliding_window_length
    overlapped_predictions = prediction_seq[new_start:len(prediction_seq)]
    return overlapped_predictions
'''
'''
def read_file_to_crfsuite(crf_input_file, feature_inclusion_list, crf_tagger, output, options_dict):    
    import crfsuite
    f = open(crf_input_file, 'r')
    min_max  = pd.load('min_max_dataframe')
    xseq = crfsuite.ItemSequence()
    yseq = crfsuite.StringList()
    for line in f:        
        if "label" in line:            
            feature_index_list = crf_train.get_feature_index_list(line, feature_inclusion_list)
            header = line.split('\t')
            continue
        if "START" in line:
            continue
        if "END" in line:
            #crf_tagger.set(xseq)    
            y_itr = yseq.iterator()
            for prediction in crf_tagger.tag(xseq):
                label = y_itr.next()
                #print "prediction: " + prediction
                #print "label: " + label
                output.write(prediction.strip() + "," + label.strip()+"\n")
                #print prediction.strip() + "," + label.strip()
            xseq = crfsuite.ItemSequence()
            yseq = crfsuite.StringList()
        else:
            item = crfsuite.Item()
            fields = line.split('\t')
            for i in range(0,len(fields)):
                if i in feature_index_list:
                    # print header[i]
                    # print fields[i]
                    attribute_name = header[i]
                    if(fields[i] == 'NA'):
                        attribute_val = 0
                    else:
                        #attribute_val = float(fields[i]) 
                        denom = min_max['max'][attribute_name] - min_max['min'][attribute_name]
                        if denom == 0:
                            attribute_val = 0
                        else: 
                            attribute_val = (float(fields[i]) - min_max['min'][attribute_name] )/ denom
                        #print attribute_val
                    item.append(crfsuite.Attribute(attribute_name, attribute_val))            
            xseq.append(item)
            #print xseq.items()
            yseq.append(fields[0])

               

'''
def read_file_to_crfsuite(crf_input_file, feature_inclusion_list, crf_tagger, output, options_dict):    
    sliding_window_length = options_dict['sliding_window_length']
    import crfsuite
    f = open(crf_input_file, 'r')
    #min_max  = pd.load('min_max_dataframe')
    xseq = crfsuite.ItemSequence()
    yseq = crfsuite.StringList()
    overlapped_predictions = []
    for line in f:        
        if line.strip(' \t\n\r')=="":
            continue
        if "label" in line:
            feature_index_list = crf_train.get_feature_index_list(line, feature_inclusion_list)
            header = line.split('\t')
            continue  
        if "START" in line:
            continue        
        if "END" in line:
            #crf_tagger.set(xseq)    
            #prediction_seq = util.convert_to_python_list(crf_tagger.tag(xseq))
            prediction_seq = crf_tagger.tag(xseq)
            label_seq = util.convert_to_python_list (yseq)
            if (sliding_window_length != 0 ):
                overlapped_predictions = write_prediction_to_file (prediction_seq, label_seq, overlapped_predictions, output , options_dict)
            else:
                y_itr = yseq.iterator()
                for prediction in prediction_seq:
                    #print 'straightforward'
                    label = y_itr.next()   
                    output.write(prediction.strip() + "," + label.strip()+"\n")

            xseq = crfsuite.ItemSequence()
            yseq = crfsuite.StringList()
        else:
            item = crfsuite.Item()
            fields = line.split('\t')
            for i in range(0,len(fields)):
                if i in feature_index_list:
                    attribute_name = header[i]
                    if(fields[i] == 'NA'):
                        attribute_val = 0
                    else:
                        attribute_val = float(fields[i])                    
                    item.append(crfsuite.Attribute(attribute_name, attribute_val))
            xseq.append(item)            
            yseq.append(fields[0].strip('"'))

def crf_tag(crf_model_file, crf_test_file, feature_list_file, output_file, options_dict):

    output = open(output_file, 'w')
	# Create a tagger object.
    tagger = crfsuite.Tagger()
    
    # Load the model to the tagger.
    tagger.open(crf_model_file)

    output.write("Prediction,True Label\n")
    feature_inclusion_list = crf_train.get_feature_inclusion_list(feature_list_file)

    read_file_to_crfsuite(crf_test_file,feature_inclusion_list, tagger,output, options_dict)
    """
    for xseq in instances(fi):
    	# Tag the sequence.
        tagger.set(xseq)
        # Obtain the label sequence predicted by the tagger.
        yseq = tagger.viterbi()
        # Output the probability of the predicted label sequence.
        print tagger.probability(yseq)
        for t, y in enumerate(yseq):
        	# Output the predicted labels with their marginal probabilities.
            print '%s:%f' % (y, tagger.marginal(y, t))
        print
    """