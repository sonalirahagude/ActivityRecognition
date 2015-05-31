import sys
import pandas as pd
import numpy as np

def build_confusion_matrix(prediction_file,confusion_matrix,labels):
	f = open(prediction_file,'r') 
	for line in f:
		prediction, label = line.split(',')
		prediction = prediction.strip()
		label = label.strip()
		#skip header
		if(prediction == 'Prediction'):
			continue
		# in case of pandas data frame , the first subsccript is the column and the second one is the row -- COUNTER INTUITIVE!
		confusion_matrix[label][prediction] = confusion_matrix[label][prediction] + 1
	return confusion_matrix

if __name__ == '__main__':
	period = 5	
	feature_list_file = sys.argv[1]
	reg_constant = float(sys.argv[2])
	accuracy_file = 'test/accuracies/confusion_matrix_' + str(period) + '_period_' + str(reg_constant) + '_reg_constant_'  + feature_list_file
	labels = ['Sedentary', 'StandingStill','StandingMoving', 'Walking', 'Biking', 'Vehicle']
	confusion_matrix = pd.DataFrame(data= np.zeros([len(labels), len(labels)]), index = labels, columns = labels)
	
	participant_list=["SDU078","SDU079","SDU080","SDU082","SDU085","SDU086","SDU087","SDU089","SDU090","SDU091","SDU092","SDU093","SDU094","SDU096","SDU097","SDU098","SDU099","SDU100","SDU102","SDU103","SDU109","SDU111","SDU113","SDU114","SDU115","SDU116","SDU117","SDU118","SDU119","SDU120","SDU121","SDU122","SDU123","SDU124"]
	for excluded_participant in participant_list:
		output_prediction_file='test/results/results_AllTrain'+ excluded_participant + 'Test_' + str(period) + '_period_' + str(reg_constant) + '_reg_constant_'  + feature_list_file
		confusion_matrix = build_confusion_matrix(output_prediction_file,confusion_matrix,labels)
	confusion_matrix = confusion_matrix/confusion_matrix.sum()
	confusion_matrix.columns = [label + "_label" for label in labels]
	print confusion_matrix
	confusion_matrix.to_csv(accuracy_file,mode='a')
	