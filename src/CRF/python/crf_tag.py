#!/usr/bin/env python
"""
author : Sonali Rahagude (srahagud@eng.ucsd.edu)
Script to train CRF, accepts input file which is complaint to CRFSuite requirements
"""

import crfsuite
import sys
import pandas as pd
import crf_train


def read_file_to_crfsuite(crf_input_file, feature_inclusion_list, crf_tagger, output):    
    import crfsuite
    f = open(crf_input_file, 'r')
    min_max  = pd.load('min_max_dataframe')
    xseq = crfsuite.ItemSequence()
    yseq = crfsuite.StringList()
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
            y_itr = yseq.iterator()
            for prediction in crf_tagger.tag(xseq):
                label = y_itr.next()   
                output.write(prediction.strip() + "," + label.strip()+"\n")
                #print prediction.strip() + "," + label.strip()
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
            yseq.append(fields[0])


def crf_tag(crf_model_file, crf_test_file, feature_list_file, output_file):
    output = open(output_file, 'w')
	# Create a tagger object.
    tagger = crfsuite.Tagger()
    
    # Load the model to the tagger.
    tagger.open(crf_model_file)

    output.write("Prediction,True Label\n")
    feature_inclusion_list = crf_train.get_feature_inclusion_list(feature_list_file)

    read_file_to_crfsuite(crf_test_file,feature_inclusion_list, tagger,output)
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