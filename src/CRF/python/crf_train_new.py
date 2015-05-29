#!/usr/bin/env python
"""
author : Sonali Rahagude (srahagud@eng.ucsd.edu)
Script to train CRF, accepts input file which is complaint to CRFSuite requirements
"""

import crfsuite
import sys
import os.path
import pandas as pd
import numpy as np
import crf_tag
import find_accuracy
# Inherit crfsuite.Trainer to implement message() function, which receives
# progress messages from a training process.
class Trainer(crfsuite.Trainer):
    def message(self, s):
        # Simply output the progress messages to STDOUT.
        sys.stdout.write(s)

def get_feature_index_list(line, feature_inclusion_list) :
    feature_index_list = []
    fields = line.split('\t')
    for i in range(0 , len(fields)):
        if(fields[i] in feature_inclusion_list):
            feature_index_list.append(i)
    return feature_index_list

def get_min_max_scaling_values (crf_input_file, feature_inclusion_list):
    f = open(crf_input_file, 'r')
    feature_index_list = []
    header = []
    for line in f:      
        if "label" in line:
            feature_index_list = get_feature_index_list(line, feature_inclusion_list)
            header = line.split('\t')
            min_max = pd.DataFrame(data= np.zeros([len(header),2],dtype=float), index = header, columns = ['min','max'])
            min_max['min'] = 99999.0
            min_max['max'] = -99999.0
            continue  
        if "START" in line:
            continue
        if "END" in line:
            continue
        else:
            fields = line.split('\t')
            for i in range(0,len(fields)):
                if i in feature_index_list:
                    # print header[i]
                    # print fields[i]
                    attribute_name = header[i]
                    if(fields[i] == 'NA'):
                        continue
                    else:
                        attribute_val = float(fields[i])
                    if(min_max['min'][attribute_name] > attribute_val ):
                        min_max['min'][attribute_name] = attribute_val 
                    if(min_max['max'][attribute_name] < attribute_val ):
                        min_max['max'][attribute_name] = attribute_val 
    print min_max
    min_max.save('min_max_dataframe')
    return min_max

"""
Convert the file into an object compatible with crfsuite Python module.
Every line in the crf input file consists of features for a particular token in the CRF sequence and every sequence is contained with a START-END pair
<token label> \t <token attribute1 name: tokan attribute1 value> \t <token attribute2 name: tokan attribute2 value> ....
"""
def read_file_to_crfsuite(crf_input_file, crf_trainer, feature_inclusion_list, participant_list):    
    if os.path.isfile('min_max_dataframe'):
        min_max = pd.load('min_max_dataframe')
    else:
        min_max = get_min_max_scaling_values (crf_input_file, feature_inclusion_list)
    import crfsuite
    f = open(crf_input_file, 'r')
    feature_index_list = []
    header = []
    xseq = crfsuite.ItemSequence()
    yseq = crfsuite.StringList()
    for line in f:      
        if "label" in line:
            feature_index_list = get_feature_index_list(line, feature_inclusion_list)
            header = line.split('\t')
            continue  
        if "START" in line:
            continue
        if "END" in line:
            print participant_group
            crf_trainer.append(xseq, yseq,participant_group)   
            xseq = crfsuite.ItemSequence()
            yseq = crfsuite.StringList()
        else:            
            item = crfsuite.Item()
            fields = line.split('\t')
            participant = fields[1]
            participant_group = participant_list.index(participant)
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
                        if min_max['max'][attribute_name] == min_max['min'][attribute_name]:
                            attribute_val = 1
                        else: 
                            attribute_val = (float(fields[i]) - min_max['min'][attribute_name] )/ denom
                        #print attribute_name + ", " + str(attribute_val)
                    item.append(crfsuite.Attribute(attribute_name, attribute_val))
            xseq.append(item)
            #print xseq.items()
            #print fields[0]
            yseq.append(fields[0])


def get_feature_inclusion_list(feature_file):
    print feature_file
    f = open(feature_file,'r')
    feature_inclusion_list = []
    for line in f:
        if '#' in line:
            continue
        if line.strip(' \t\n\r')=="":
            continue
        feature_inclusion_list.append(line.strip())
    f.close()
    return feature_inclusion_list


def crf_train(crf_train_file,feature_list_file,crf_model_file,excluded_participant_list, options_dict):

	# arg1: feature_list, arg2: crf file, arg3: file to save crf model to
	# Create a Trainer object.
    reg_constant = options_dict['reg_constant']
    period = options_dict['period']
    print 'reg_constant: ' + str(reg_constant)
    print 'period: ' + str(period)
    trainer = Trainer()
    
    feature_inclusion_list = get_feature_inclusion_list(feature_list_file)    
    read_file_to_crfsuite(crf_train_file, trainer, feature_inclusion_list,excluded_participant_list)
    # Read training instances from STDIN, and set them to trainer.
    #for xseq, yseq in instances(crf_input_file):
    #    trainer.append(xseq, yseq, 0)

    #-----------------------------------------
	# Use L2-regularized SGD and 1st-order dyad features.
    # trainer.select('l2sgd', 'crf1d')    
    # trainer.set('c2', '0.8')
    # trainer.set('period', '20')
    # trainer.set('max_iterations','5000')
    # trainer.set('calibration.eta', '5')
    # trainer.set('calibration.samples', '10000')
    # trainer.set('calibration.max_trials', '1000')
    #-----------------------------------------
    #LBFGS trainer
    trainer.select('lbfgs','crf1d')    
    trainer.set('num_memories','20')
    trainer.set('c2', reg_constant)
    trainer.set('period', period)
    #-----------------------------------------
    

    trainer.set('max_iterations','5000')
    trainer.set('feature.minfreq','-100000')
    trainer.set('feature.possible_states', '1')
    trainer.set('feature.possible_transitions', '1')
    
    # This demonstrates how to list parameters and obtain their values.
    for name in trainer.params():
        print name, trainer.get(name), trainer.help(name)
    

    # Start training; the training process will invoke trainer.message()
    # to report the progress.
    trainer.train(crf_model_file, -1)



def leave_one_out(crf_train_file,feature_list_file,participant_list, test_participant_list, options_dict):
    reg_constants = options_dict['reg_constants']
    periods = options_dict['periods']
    
    output_name = 'test/accuracies/grid_search' + feature_list_file
    output = open(output_name, 'a')
    output.write('period, reg_constant,avg_acc\n')
    trainer = Trainer()
    
    feature_inclusion_list = get_feature_inclusion_list(feature_list_file)
    print feature_inclusion_list
    read_file_to_crfsuite(crf_train_file, trainer, feature_inclusion_list,participant_list)
    print 'read from file'
    
    for period in periods:
        for reg_constant in reg_constants:
            print 'reg_constant: ' + str(reg_constant)
            print 'period: ' + str(period)
            trainer.select('lbfgs','crf1d')    
            trainer.set('num_memories','20')
            trainer.set('c2', str(reg_constant))
            trainer.set('period',str(period))
    
            trainer.set('max_iterations','500')
            trainer.set('feature.minfreq','-100000')
            trainer.set('feature.possible_states', '1')
            trainer.set('feature.possible_transitions', '1')
    
            avg_acc = 0.0

            participant_details_file_name  = 'test/accuracies/' + feature_list_file + '_Acc_' + str(period) + '_period_' + str(reg_constant) + '_reg_constant' 
            participant_details_file = open(participant_details_file_name,'w')
            participant_details_file.write('participant,accuracy\n')
            for excluded_participant in test_participant_list :
                crf_model_file = 'test/results/crf_all_model_' + excluded_participant + '_excluded' + str(period) + '_period_' + str(reg_constant) + '_reg_constant_'  + feature_list_file

                excluded_participant_group = test_participant_list.index(excluded_participant)
                trainer.train(crf_model_file, excluded_participant_group)            
                
                participant_file= crf_train_file  +'_' + excluded_participant 
                output_prediction_file='test/results/results_AllTrain'+ excluded_participant + 'Test_' + str(period) + '_period_' + str(reg_constant) + '_reg_constant_'  + feature_list_file
                crf_tag.crf_tag(crf_model_file, participant_file, feature_list_file, output_prediction_file)
                
                acc  = find_accuracy.find_accuracy(output_prediction_file)
                print excluded_participant + ": " + str(acc)
                participant_details_file.write(excluded_participant + ','  + str(acc) + '\n')
                participant_details_file.flush()
                avg_acc = avg_acc + acc
            avg_acc = avg_acc/len(test_participant_list)    
            print "avg_acc: " +  str(avg_acc)
            participant_details_file.write('Avg' + ', ' + str(avg_acc) + '\n')
            participant_details_file.close()
            output.write( str(period) + ', ' + str(reg_constant) + ', ' + str(avg_acc) +"\n")
            output.flush()
    output.close()
    
