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
		if(prediction == 'prediction'):
			continue
		confusion_matrix[label][prediction] = confusion_matrix[label][prediction] + 1
	return confusion_matrix

if __name__ == '__main__':
	prediction_file = sys.argv[1]
	accuracy_file = sys.argv[2]
	fa = open(accuracy_file,'a+')
	f = open(prediction_file,'r')  
	accuracy = 0
	total = 0
	for line in f:
		prediction, label = line.split(',')
		prediction = prediction.strip()
		label = label.strip()
		if (prediction == label):
			accuracy = accuracy + 1
		total = total + 1 
	print "prediction for: " + prediction_file
	print "accuracy: " + str(accuracy*1.0/total*100.0)
	#fa.write(str(accuracy*1.0/total*100.0))
	df = build_confusion_matrix(sys.argv[1])
	df.to_csv(accuracy_file)
	print("-------------------------------------------------------------------------------------------------------------------------")
	f.close()
