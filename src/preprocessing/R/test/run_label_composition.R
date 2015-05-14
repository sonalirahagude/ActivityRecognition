
print("label composition")
print(getwd())
source('../count_labels_composition.R')

labels = c("StandingMoving", "StandingStill","Sedentary","Walking","Biking","Vehicle")

label_dir = '../data/AnnotatedFilesNew_aligned'
output_file = 'label_composition.csv'
count_labels (label_dir, output_file, labels, names = NULL)
