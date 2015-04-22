#python ../crf_tag.py crf.disjoint.model ../../../preprocessing/R/test/crf_feature


#python ../crf_tag.py crf.SDU079.model ../../../preprocessing/R/test/crf_feature_SDU080 > results_SDU079Train_SDU080Test
python ../crf_tag.py crf.SDU082.model ../../../preprocessing/R/test/crf_feature_SDU085 > results_SDU082Train_SDU085Test

#python ../crf_tag.py crf.SDU079.speed_only.model ../../../preprocessing/R/test/crf_feature_SDU080 > results_SDU079Train_SDU080Test_speed_only

#python ../crf_tag.py crf.SDU079.speed_only.model ../../../preprocessing/R/test/crf_feature_SDU082 > results_SDU079Train_SDU082Test_speed_only

#python ../crf_tag.py crf.SDU082.speed_only.model ../../../preprocessing/R/test/crf_feature_SDU085 > results_SDU082Train_SDU085Test_speed_only

#python ../crf_tag.py crf.SDU082.speed_eleDelta.all_transitions.model ../../../preprocessing/R/test/crf_feature_SDU085 > results_SDU082Train_SDU085Test_speed_eleDelta_all_transitions