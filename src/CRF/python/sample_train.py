#!/usr/bin/env python

import crfsuite
import sys

# Inherit crfsuite.Trainer to implement message() function, which receives
# progress messages from a training process.
class Trainer(crfsuite.Trainer):
    def message(self, s):
        # Simply output the progress messages to STDOUT.
        sys.stdout.write(s)

def instances(fi):
    xseq = crfsuite.ItemSequence()
    yseq = crfsuite.StringList()
    
    for line in fi:
        line = line.strip('\n')
        if not line:
        	# An empty line presents an end of a sequence.
            yield xseq, tuple(yseq)
            xseq = crfsuite.ItemSequence()
            yseq = crfsuite.StringList()
            continue

		# Split the line with TAB characters.
        fields = line.split('\t')
    	
    	# Append attributes to the item.
        item = crfsuite.Item()
        for field in fields[1:]:
            p = field.rfind(':')
            if p == -1:
            	# Unweighted (weight=1) attribute.
                item.append(crfsuite.Attribute(field))
            else:
            	# Weighted attribute
                item.append(crfsuite.Attribute(field[:p], float(field[p+1:])))
        
        # Append the item to the item sequence.
        xseq.append(item)
        # Append the label to the label sequence.
        yseq.append(fields[0])


def read_file_to_crfsuite(crf_input_file, crf_trainer):
    """
    Convert an item sequence into an object compatible with crfsuite
    Python module.

    @type   X:      list of mapping objects
    @param  X:      The sequence.
    @rtype          crfsuite.ItemSequence
    @return        The same sequence in crfsuite.ItemSequence type.
    """
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
	# This demonstrates how to obtain the version string of CRFsuite.
    #print crfsuite.version()

	# Create a Trainer object.
    trainer = Trainer()
    
    print sys.argv[1]
    read_file_to_crfsuite(sys.argv[1],trainer)
    # Read training instances from STDIN, and set them to trainer.
    #for xseq, yseq in instances(crf_input_file):
    #    trainer.append(xseq, yseq, 0)

	# Use L2-regularized SGD and 1st-order dyad features.
    trainer.select('l2sgd', 'crf1d')
    
    # This demonstrates how to list parameters and obtain their values.
    for name in trainer.params():
        print name, trainer.get(name), trainer.help(name)
    
    # Set the coefficient for L2 regularization to 0.1
    trainer.set('c2', '0.1')
    
    # Start training; the training process will invoke trainer.message()
    # to report the progress.
    trainer.train(sys.argv[2], -1)

