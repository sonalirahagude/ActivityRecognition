#python ../crf_tag.py crf.disjoint.model ../../../preprocessing/R/test/crf_feature


#python ../crf_tag.py crf.SDU079.model ../../../preprocessing/R/test/crf_feature_SDU080 > results_SDU079Train_SDU080Test
#python ../crf_tag.py crf.SDU082.model ../../../preprocessing/R/test/crf_feature_SDU085 > results_SDU082Train_SDU085Test
#python ../crf_tag.py crf.SDU082.speed_only.model ../../../preprocessing/R/test/crf_feature_SDU085 > results_SDU082Train_SDU085Test_speed_only
#python ../crf_tag.py crf.SDU082.speeed_ele.model ../../../preprocessing/R/test/crf_feature_SDU085 > results_SDU082Train_SDU085Test_speeed_ele


#python ../crf_tag.py crf.SDU079.model ../../../preprocessing/R/test/crf_feature_SDU080 > results_SDU079Train_SDU080Test
#python ../crf_tag.py crf.SDU079.speed_only.model ../../../preprocessing/R/test/crf_feature_SDU080 > results_SDU079Train_SDU080Test_speed_only


#python ../crf_tag.py crf.SDU085.model ../../../preprocessing/R/test/crf_feature_SDU086 > results_SDU085Train_SDU086Test
#python ../crf_tag.py crf.SDU085.speed_only.model ../../../preprocessing/R/test/crf_feature_SDU086 > results_SDU085Train_SDU086Test_speed_only


python ../crf_tag.py crf.all.model ../../../preprocessing/R/test/crf_feature_SDU078 > results_AllTrain_SDU078Test
python ../crf_tag.py crf.all.speed_only.model ../../../preprocessing/R/test/crf_feature_SDU078 > results_AllTrain_SDU078Test_speed_only

python ../crf_tag.py crf.SDU085.model ../../../preprocessing/R/test/crf_feature_SDU078 > results_SDU085Train_SDU078Test
python ../crf_tag.py crf.SDU085.speed_only.model ../../../preprocessing/R/test/crf_feature_SDU078 > results_SDU085Train_SDU078Test_speed_only
