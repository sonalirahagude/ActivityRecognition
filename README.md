# ActivityRecognition

# Working Directory : ~
## All file paths are relative
## if your git folder is not in the home directory (~), replace ~ in the following commands with the specific directory name

--------------------------------------------------------------------------------------------------------------------------------------------------------

# PREPROCESSING MODULE

# Running and testing the CRF compliant afile generation (Preprocessing)
## This will generate the CRF complaint file 'crf_features' and will calculate the features from the feature_list specified.
## Place the data  -- Accelerometer, GPS files, label files in the data directory

	~/git/ActivityRecognition/src/preprocessing/R/data

## Run the preprocessing module using the following command
## You need to specify the absolute path of the script in RStudio

	source('~/git/ActivityRecognition/src/preprocessing/R/test/test.R',chdir=TRUE)

## chdir=True will temporarily change the working directory to the source directory of the 'test.R' script

--------------------------------------------------------------------------------------------------------------------------------------------------------

# CRF MODULE

# Running and testing the CRFSuite train and test implementation

## Install CRFSuite 0.12 and its bindings for python
## Please follow the instructions at https://raw.githubusercontent.com/chokkan/crfsuite/master/swig/python/README


## To run the Leave-one-subject-out(LOSO) validation , run the following command from directory .../ActivityRecognition/src/CRF/python ,
## Results from the run with be written in ./test/results directory
	python test_CRF_LOO.sh

## This will save a trained model in a file per LOSO validation in the results directory. Run the following to get a friendly version of the learnt CRF model
	~/git/crfsuite-0.12/frontend/crfsuite dump 'crf-model-file-from-training' > 'output-file-name'

   For e.g.,
	~/git/crfsuite-0.12/frontend/crfsuite dump crf_all_model_SDU119_excluded5_period_0.01_reg_constant_feature_list_all_shorter_and_sequence_wide > crf.model.friendly


## Find accuracy for a particular participant from ~/git/ActivityRecognition/src/CRF/python/test
	python find_accuracy.py results/results_AllTrainSDU119Test_5_period_0.01_reg_constant_feature_list_all_shorter_and_sequence_wide

## Find the confusion matrix for an entire LOSO run, for a given feature file and reg constant 
## run the following from /git/ActivityRecognition/src/CRF/python/
	python test/find_confusion_matrix.py <feature-list-file> <reg-constant>

   For e.g.,
	python test/find_confusion_matrix.py feature_list_all_shorter_and_sequence_wide 0.01

--------------------------------------------------------------------------------------------------------------------------------------------------------

# Exploratory Data Analysis
## Running label composition
source()
count_labels = function(label_dir, output_file, labels, names = NULL) {

--------------------------------------------------------------------------------------------------------------------------------------------------------

# Running and testing the CRF implementation [DEPRECATED]
## You need to specify the absolute path of the script in RStudio

	source('/home/sonali/git/ActivityRecognition/src/CRF/R/test/test.R',chdir=TRUE)

## Now check result file in the same directory.

--------------------------------------------------------------------------------------------------------------------------------------------------------

# Checking the accuracy and confusion matrix given the prediction file.[DEPRECATED]
## Run the following command on the command line,
	python find_accuracy.py /home/sonali/git/ActivityRecognition/src/CRF/R/test/<result_file_name>


