import sys
import pandas as pd
import numpy as np

def build_confusion_matrix(prediction_file):
	labels = ['Sedentary', 'StandingStill','StandingMoving', 'Walking', 'Biking', 'Vehicle']
	confusion_matrix = pd.DataFrame(data= np.zeros([len(labels), len(labels)]), index = labels, columns = labels)
	f = open(prediction_file,'r') 
	for line in f:
		prediction, label = line.split(',')
		prediction = prediction.strip()
		label = label.strip()
		#skip header
		if(prediction == 'Prediction') or label=='True Label':
			continue
		# in case of pandas data frame , the first subsccript is the column and the second one is the row -- COUNTER INTUITIVE!
		confusion_matrix[label][prediction] = confusion_matrix[label][prediction] + 1
	confusion_matrix.columns = [label + "_label" for label in labels]
	return confusion_matrix

if __name__ == '__main__':
	prediction_file = sys.argv[1]
	accuracy_file = sys.argv[2]
	#fa = open(accuracy_file,'a+')
	f = open(prediction_file,'r')  
	accuracy = 0
	total = 0

	prev_label = ""
	prev_prediction = ""
	transition_accuracy = 0
	transition_total = 0

	for line in f:
		prediction, label = line.split(',')
		prediction = prediction.strip()
		label = label.strip()
		if(prediction == 'prediction'):			
			continue
		if (prediction == label):
			accuracy = accuracy + 1
		total = total + 1 
		if(prev_label != label) : 
			transition_total = transition_total + 1
			if(prediction == label):
				transition_accuracy = transition_accuracy + 1 
		prev_label = label
		
	print "prediction for: " + prediction_file
	print "accuracy: " + str(accuracy*1.0/total*100.0)
	print "total: " + str(total)
	print "transition accuracy: " + str(transition_accuracy*1.0/transition_total*100.0)
	print "total transitions: " + str(transition_accuracy) + "/" + str(transition_total)

	#fa.write(str(accuracy*1.0/total*100.0))
	df = build_confusion_matrix(sys.argv[1])
	#fa.write(df)
	print df
	df = df/df.sum()
	df.to_csv(accuracy_file,mode='a')
	print("-------------------------------------------------------------------------------------------------------------------------")
	#f.close()
