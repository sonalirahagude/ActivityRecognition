	#!/bin/sh

#Rscript ../../../preprocessing/R/test/test.R
participant_list="SDU078 SDU079 SDU080 SDU082 SDU085 SDU086 SDU087 SDU089 SDU090 SDU091 SDU092 SDU093 SDU094 SDU096 SDU097 SDU098 SDU099 SDU100"
#participant_list="SDU102 SDU103 SDU109 SDU111 SDU113 SDU114 SDU115 SDU116 SDU117 SDU118 SDU119 SDU120 SDU121 SDU122 SDU123 SDU124"


#participant_list="SDU096 SDU097 SDU098 SDU099 SDU100 SDU102 SDU103 SDU109 SDU111 SDU113 SDU114 SDU115"

#participant_list="SDU118 SDU119 SDU120 SDU121 SDU122 SDU123 SDU124"


# list with weak participants , more epochs
#participant_list="SDU124"

loo_output_file="LOO_results"
accuracy_file = "LOO_accuracy"

# if the output already exists, move it to a back up file
#mv $loo_output_file $loo_output_file".bk"
#mv $accuracy_file $accuracy_file".bk"
for excluded_participant in $participant_list; do
	#echo $excluded_participant
	#test_file="results/all_train_"$excluded_participant"_test_contrasive_divergence_20epochs_1LR_10rounds"
	#echo $test_file
	#Rscript run.R all $excluded_participant 10 1 contrasive_divergence FALSE 10 TRUE
	Rscript run.R all $excluded_participant 10 1 contrasive_divergence FALSE 10 TRUE
	#python find_accuracy.py test_file accuracy_file >> $loo_output_file
done
