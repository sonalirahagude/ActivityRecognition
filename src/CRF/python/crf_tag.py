#!/usr/bin/env python
"""
author : Sonali Rahagude (srahagud@eng.ucsd.edu)
Script to train CRF, accepts input file which is complaint to CRFSuite requirements
"""

import crfsuite
import sys

def read_file_to_crfsuite(crf_input_file, crf_tagger):    
    import crfsuite
    f = open(crf_input_file, 'r')
    xseq = crfsuite.ItemSequence()
    yseq = crfsuite.StringList()
    for line in f:        
        if "START" in line:
            continue
        if "END" in line:
            #crf_tagger.set(xseq)    
            y_itr = yseq.iterator()
            for prediction in crf_tagger.tag(xseq):
                label = y_itr.next()
                #print "prediction: " + prediction
                #print "label: " + label
                print prediction.strip() + "," + label.strip()
            xseq = crfsuite.ItemSequence()
            yseq = crfsuite.StringList()
        else:
            item = crfsuite.Item()
            fields = line.split('\t')
            for feature_tuple in fields[1:]:
                p = feature_tuple.rfind(':')
                if p == -1:
                    # Unweighted (weight=1) attribute.
                    item.append(crfsuite.Attribute(feature_tuple))
                else:
                    # Weighted attribute
                    item.append(crfsuite.Attribute(feature_tuple[:p], float(feature_tuple[p+1:])))           
            xseq.append(item)
            #print xseq.items()
            yseq.append(fields[0])



if __name__ == '__main__':
    fi = sys.stdin
    fo = sys.stdout

	# Create a tagger object.
    tagger = crfsuite.Tagger()
    
    # Load the model to the tagger.
    tagger.open(sys.argv[1])

    print "Prediction,True Label"
    read_file_to_crfsuite(sys.argv[2],tagger)
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