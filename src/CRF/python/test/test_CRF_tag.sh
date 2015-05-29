#python ../crf_tag.py crf.disjoint.model ../../../preprocessing/R/test/crf_feature


#python ../crf_tag.py crf.SDU079.model ../../../preprocessing/R/test/crf_feature_SDU080 > results_SDU079Train_SDU080Test
#python ../crf_tag.py crf.SDU082.model ../../../preprocessing/R/test/crf_feature_SDU085 > results_SDU082Train_SDU085Test
#python ../crf_tag.py crf.SDU082.speed_only.model ../../../preprocessing/R/test/crf_feature_SDU085 > results_SDU082Train_SDU085Test_speed_only
#python ../crf_tag.py crf.SDU082.speeed_ele.model ../../../preprocessing/R/test/crf_feature_SDU085 > results_SDU082Train_SDU085Test_speeed_ele


#python ../crf_tag.py crf.SDU079.model ../../../preprocessing/R/test/crf_feature_SDU080 > results_SDU079Train_SDU080Test
#python ../crf_tag.py crf.SDU079.speed_only.model ../../../preprocessing/R/test/crf_feature_SDU080 > results_SDU079Train_SDU080Test_speed_only


#python ../crf_tag.py crf.SDU085.model ../../../preprocessing/R/test/crf_feature_SDU086 > results_SDU085Train_SDU086Test
#python ../crf_tag.py crf.SDU085.speed_only.model ../../../preprocessing/R/test/crf_feature_SDU086 > results_SDU085Train_SDU086Test_speed_only


participant_list="SDU078 SDU079 SDU080 SDU082 SDU085 SDU086 SDU087 SDU089 SDU090 SDU091 SDU092 SDU093 SDU094 SDU096 SDU097 SDU098 SDU099 SDU100 SDU102 SDU103 SDU109 SDU111 SDU113 SDU114 SDU115 SDU116 SDU117 SDU118 SDU119 SDU120 SDU121 SDU122 SDU123 SDU124"
#participant_list="SDU124"
for excluded_participant in $participant_list; do
	participant_file='../../../preprocessing/R/test/results/crf_feature_all_15_seqLength_0_overlap_'$excluded_participant
	echo $participant_file
	output_prediction_file='results_AllTrain_'$excluded_participant'Test'
	python ../crf_tag.py crf.all.model $participant_file ../feature_list_all > $output_prediction_file
	#echo "$excluded_participant"
	python find_accuracy.py $output_prediction_file
done
