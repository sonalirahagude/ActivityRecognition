#python ../sample_train.py ../../../preprocessing/R/test/crf_feature_disjoint crf.disjoint.model
python ../sample_train.py ../../../preprocessing/R/test/crf_feature crf.model
~/git/crfsuite-0.12/frontend/crfsuite dump crf.model > crf.model.friendly
