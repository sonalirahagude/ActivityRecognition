#!/usr/bin/env python
"""
author : Sonali Rahagude (srahagud@eng.ucsd.edu)
Script to train CRF, accepts input file which is complaint to CRFSuite requirements
"""

import crfsuite
import sys

# Inherit crfsuite.Trainer to implement message() function, which receives
# progress messages from a training process.
class Trainer(crfsuite.Trainer):
    def message(self, s):
        # Simply output the progress messages to STDOUT.
        sys.stdout.write(s)

"""
Convert the file into an object compatible with crfsuite Python module.
Every line in the crf input file consists of features for a particular token in the CRF sequence and every sequence is contained with a START-END pair
<token label> \t <token attribute1 name: tokan attribute1 value> \t <token attribute2 name: tokan attribute2 value> ....
"""
def read_file_to_crfsuite(crf_input_file, crf_trainer, feature_inclusion_list):    
    import crfsuite
    f = open(crf_input_file, 'r')
    xseq = crfsuite.ItemSequence()
    yseq = crfsuite.StringList()
    for line in f:        
        if "START" in line:
            continue
        if "END" in line:
            crf_trainer.append(xseq, yseq,0)
            #print xseq.items()
            xseq = crfsuite.ItemSequence()
            yseq = crfsuite.StringList()
        else:
            item = crfsuite.Item()
            fields = line.split('\t')
            for attribute_tuple in fields[1:]:
                p = attribute_tuple.rfind(':')                
                if p == -1:
                    # Unweighted (weight=1) attribute.
                    attribute_name = attribute_tuple.strip()
                    if( attribute_name in feature_inclusion_list):
                        item.append(crfsuite.Attribute(attribute_name))
                else:
                    # Weighted attribute
                    attribute_name = attribute_tuple[:p].strip()
                    attribute_val = float(attribute_tuple[p+1:])
                    
                    if(attribute_name in feature_inclusion_list):
                        item.append(crfsuite.Attribute(attribute_name, attribute_val))
            xseq.append(item)
            #print xseq.items()
            yseq.append(fields[0])


def get_feature_inclusion_list(file):
    f = open(file,'r')
    feature_inclusion_list = []
    for line in f:
        feature_inclusion_list.append(line.strip())
    f.close()
    return feature_inclusion_list


if __name__ == '__main__':

	# arg1: feature_list, arg2: crf file, arg3: file to save crf model to
	# Create a Trainer object.
    trainer = Trainer()
    

    print sys.argv[1]
    print sys.argv[2]
    print sys.argv[3]
    feature_inclusion_list = get_feature_inclusion_list(sys.argv[1])
    read_file_to_crfsuite(sys.argv[2], trainer, feature_inclusion_list)
    # Read training instances from STDIN, and set them to trainer.
    #for xseq, yseq in instances(crf_input_file):
    #    trainer.append(xseq, yseq, 0)

	# Use L2-regularized SGD and 1st-order dyad features.
    trainer.select('l2sgd', 'crf1d')    
    trainer.set('feature.minfreq','-100000')
    #trainer.set('feature.possible_states', '1')
    #trainer.set('feature.possible_transitions', '1')
    
    # This demonstrates how to list parameters and obtain their values.
    for name in trainer.params():
        print name, trainer.get(name), trainer.help(name)
    
    # Set the coefficient for L2 regularization to 0.1
    trainer.set('c2', '0.1')
    
    # Start training; the training process will invoke trainer.message()
    # to report the progress.
    trainer.train(sys.argv[3], -1)

