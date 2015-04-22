#python ../crf_train.py ../feature_list ../../../preprocessing/R/test/crf_feature_disjoint crf.disjoint.model
#~/git/crfsuite-0.12/frontend/crfsuite dump crf.disjoint.model > crf.disjoint.model.friendly

#python ../crf_train.py ../feature_list ../../../preprocessing/R/test/crf_feature crf.model
#~/git/crfsuite-0.12/frontend/crfsuite dump crf.model > crf.model.friendly



#python ../crf_train.py ../feature_list ../../../preprocessing/R/test/crf_feature_SDU079 crf.SDU079.model
#~/git/crfsuite-0.12/frontend/crfsuite dump crf.SDU079.model > crf.SDU079.model.friendly

python ../crf_train.py ../feature_list ../../../preprocessing/R/test/crf_feature_SDU082 crf.SDU082.model
~/git/crfsuite-0.12/frontend/crfsuite dump crf.SDU082.model > crf.SDU082.model.friendly


#python ../crf_train.py ../feature_list ../../../preprocessing/R/test/crf_feature_SDU079 crf.SDU079.speed_only.model
#~/git/crfsuite-0.12/frontend/crfsuite dump crf.SDU079.speed_only.model > crf.SDU079.speed_only.model.friendly

#python ../crf_train.py ../feature_list ../../../preprocessing/R/test/crf_feature_SDU082 crf.SDU082.speed_eleDelta.all_transitions.model
#~/git/crfsuite-0.12/frontend/crfsuite dump crf.SDU082.speed_eleDelta.all_transitions.model > crf.SDU082.speed_eleDelta.all_transitions.model.friendly