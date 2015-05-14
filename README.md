# ActivityRecognition

--------------------------------------------------------------------------------------------------------------------------------------------------------

# Running and testing the CRF compliant file generation (Preprocessing)
## This will generate the CRF complaint file 'crf_features' and will calculate the features from the feature_list specified.
## You need to specify the absolute path of the script in RStudio

	source('/home/sonali/git/ActivityRecognition/src/preprocessing/R/test/test.R',chdir=TRUE)

## chdir=True will temporarily change the working directory to the source directory of the 'test.R' script

--------------------------------------------------------------------------------------------------------------------------------------------------------

# Running and testing the CRF implementation
## You need to specify the absolute path of the script in RStudio

	source('/home/sonali/git/ActivityRecognition/src/CRF/R/test/test.R',chdir=TRUE)

## Now check result_* file in the same directory.

--------------------------------------------------------------------------------------------------------------------------------------------------------

# Checking the accuracy and confusion matrix given the prediction file.
## Run the following command on the command line,
	python find_accuracy.py /home/sonali/git/ActivityRecognition/src/CRF/R/test/<result_file_name>

--------------------------------------------------------------------------------------------------------------------------------------------------------

# Running and testing the CRFSuite train implementation[DEPRECATED]
## Install CRFSuite 0.12 and its bindings for python
## Please follow the instructions at https://raw.githubusercontent.com/chokkan/crfsuite/master/swig/python/README


## Run this from the command line from .../ActivityRecognition/src/CRF/python/test
	./test_CRF_train.sh

## Now check crf.model.friendly file in the same directory. It will give a summary of the trained CRF model

-------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------

# Exploratory Data Analysis
## Running label composition
source()
count_labels = function(label_dir, output_file, labels, names = NULL) {

