
crf_model_file = 'results/crf_all_model_cd_100epochs_2_LR_10gibbs_15_len_0_overlap_275_l2_reg10'
out_file = paste0(crf_model_file,"_weights_trend")

	
if (file.exists( file.path(out_file) )) {
      file.remove(out_file)
    }
model = list()
# This will load weights_new object from the saved training model
load(crf_model_file)
crf_weights = model$weights
labels = dimnames(crf_weights)[[2]]
features = dimnames(crf_weights)[[3]]

#cat(, feature,"\n",file=out_file,append=TRUE)

for(feature in features) {
	same_transition_weights = array(0,dim=length(labels),dimnames = list(labels))
	for(label in labels) {
		same_transition_weights[label] = crf_weights[label, label,feature]
	}
	same_transition_weights = sort(same_transition_weights)
	print(same_transition_weights)
	cat(feature,", ",file=out_file,append=TRUE)
	cat(paste(names(same_transition_weights),collapse=", "), "\n\n",file=out_file, append=TRUE)
}

    