# set the working directory to the directory of this folder
#source('/home/sonali/git/ActivityRecognition/src/preprocessing/R/align_data.R', chdir=TRUE)
print("test")
print(getwd())
source('../setup.R')
generate_sequences_from_raw_data( "sample_gps", "sample_label","feature_list", "crf_feature", 10,1, 15 )
