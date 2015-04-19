"""
A miscellaneous utility for sequential labeling.
Copyright 2010,2011 Naoaki Okazaki.
"""

import optparse
import sys

def escape(src):
    """
    Escape colon characters from feature names. CRFSuite does not accept Colon in feature name

    @type   src:    str
    @param  src:    A feature name
    @rtype          str
    @return         The feature name escaped.
    """
    return src.replace(':', '__COLON__')

def output_features(fo, X, field=''):
    """
    Output features (and reference labels) of a sequence in CRFSuite
    format. For each item in the sequence, this function writes a
    reference label (if L{field} is a non-empty string) and features.

    @type   fo:     file
    @param  fo:     The file object.
    @type   X:      list of mapping objects
    @param  X:      The sequence.
    @type   field:  str
    @param  field:  The field name of reference labels.
    """
    for t in range(len(X)):
        if field:
            fo.write('%s' % X[t][field])
        for a in X[t]['F']:
            if isinstance(a, str):
                fo.write('\t%s' % escape(a))
            else:
                fo.write('\t%s:%f' % (escape(a[0]), a[1]))
        fo.write('\n')
    fo.write('\n')

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
    yseq = []
    for line in f:
        item = crfsuite.Item()
        if "START" in line:
            continue
        if "END" in line:
            crf_trainer.append(xseq, yseq)
            xseq = crfsuite.ItemSequence()
            yseq = []
        else:
            is_label = True 
            for feature_tuple in line.split('\t'):
            print(feature_tuple)    
                if is_label:
                    yseq.append(feature_tuple)
                    is_label = False
                    continue
                item.append(crfsuite.Attribute(feature_tuple)
            xseq.append(item)
    return xseq

"""
def main(feature_extractor, fields='w pos y', sep=' '):
    fi = sys.stdin
    fo = sys.stdout

    # Parse the command-line arguments.
    parser = optparse.OptionParser(usage="""usage: %prog [options]
This utility reads a data set from STDIN, and outputs attributes to STDOUT.
Each line of a data set must consist of field values separated by SEPARATOR
characters. The names and order of field values can be specified by -f option.
The separator character can be specified with -s option. Instead of outputting
attributes, this utility tags the input data when a model file is specified by
-t option (CRFsuite Python module must be installed)."""
        )
    parser.add_option(
        '-t', dest='model',
        help='tag the input using the model (requires "crfsuite" module)'
        )
    parser.add_option(
        '-f', dest='fields', default=fields,
        help='specify field names of input data [default: "%default"]'
        )
    parser.add_option(
        '-s', dest='separator', default=sep,
        help='specify the separator of columns of input data [default: "%default"]'
        )
    (options, args) = parser.parse_args()

    # The fields of input: ('w', 'pos', 'y) by default.
    F = options.fields.split(' ')

    if not options.model:
        # The generator function readiter() reads a sequence from a 
        for X in readiter(fi, F, options.separator):
            feature_extractor(X)
            output_features(fo, X, 'y')

    else:
        # Create a tagger with an existing model.
        import crfsuite
        tagger = crfsuite.Tagger()
        tagger.open(options.model)

        # For each sequence from STDIN.
        for X in readiter(fi, F, options.separator):
            # Obtain features.
            feature_extractor(X)
            xseq = to_crfsuite(X)
            yseq = tagger.tag(xseq)
            for t in range(len(X)):
                v = X[t]
                fo.write('\t'.join([v[f] for f in F]))
                fo.write('\t%s\n' % yseq[t])
            fo.write('\n')
"""

if __name__ == '__main__':
    
    read_file_to_crfsuite()