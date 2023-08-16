# :::::::::::::::::::::::::::::::::::::::::::::::::::
# rachael's cirque du machine learning
# :::::::::::::::::::::::::::::::::::::::::::::::::::

# sync to latest version:
git pull
conda env update --file environment.yml --prune

# set directory vars to make cmds more readable
# also makes it easier for:
# 	- moving the ML pipeline scripts to a new repo or different clone
#	- changing project directory without editing a bunch of cmds
script_dir="/project/rmcox/github_repos/leca-proteomics/scripts"
proj_dir="/project/rmcox/misc/vy.pipeline"

# if setting up a new project directory:
cd $proj_dir
mkdir {data,results,logs,cmds}
mkdir data/{feature_files,feature_subsets,feature_matrix}
mkdir results/{tpot,feature_selection,ppi_predict,walktrap}
tree -d * # confirm directory structure

# ---------------------------------------------------
# build feature matrix
# ---------------------------------------------------

# pickle feats (run time ~5min)
[ ! -e cmds/pickle_feat_files.sh ] || rm cmds/pickle_feat_files.sh; touch cmds/pickle_feat_files.sh
for dir in all chicken dolphin mouse pig rabbit; do
	for x in `ls --ignore=*.pkl ${proj_dir}/data/feature_files/${dir}`; do echo "python3 ${script_dir}/make_pkl.py -i ${proj_dir}/data/feature_files/${dir}/${x}"; done >> cmds/pickle_feat_files.sh
done
cat cmds/pickle_feat_files.sh | parallel -j24

# combine subsets (run time ~45min)
for dir in all chicken dolphin mouse pig rabbit; do echo \
"python3 ${script_dir}/build_featmat.py \
--directory ${proj_dir}/data/feature_files/${dir}/ \
--pickle --outfile_name ${proj_dir}/data/feature_subsets/${dir}_features"; done > cmds/join_subsets.sh
cat cmds/join_subsets.sh | parallel -j6 2>&1 | tee ${proj_dir}/logs/join_subsets.log

# combine all (run time ~20min)
python3 ${script_dir}/build_featmat.py --directory ${proj_dir}/data/feature_subsets/ \
--pickle --outfile_name ${proj_dir}/data/feature_matrix/feature_matrix 2>&1 | tee ${proj_dir}/logs/build_featmat.log

# ---------------------------------------------------
# label feature matrix
# ---------------------------------------------------

# label positive/negative PPIs (run time ~2 hours)
# seed makes negative PPI labels reproducible
python3 ${script_dir}/label_featmat.py \
--featmat ${proj_dir}/data/feature_matrix/feature_matrix.pkl \
--gold_std_file /project/vyqtdang/MS_brain/nextflow_brain/cfmsflow/gold_std/verNOG/CORUM4.1_core_merged.txt \
--outfile_name ${proj_dir}/data/feature_matrix/feature_matrix_labeled --seed 13 2>&1 | tee ${proj_dir}/logs/label_featmat.log

# ---------------------------------------------------
# get optimized ML pipeline
# ---------------------------------------------------

# tpot "generations" and "pop_size" set here to default cfmsflow params
# seed makes group splits, train/test splits, & model reproducible
# extremely slow (will probably run overnight)
# to speed things up reduce num_splits, generations, & pop_size
python3 ${script_dir}/run_tpot.py \
--featmat ${proj_dir}/data/feature_matrix/feature_matrix_labeled_traintest.pkl \
--outdir ${proj_dir}/results/tpot/ \
--group_split_method GroupShuffleSplit --num_splits 5 --train_size 0.7 \
--generations 10 --pop_size 20 --seed 13 2>&1 | tee ${proj_dir}/logs/run_tpot.log

# ---------------------------------------------------
# run recursive feature elimination
# ---------------------------------------------------

# choose best tpot model as input
# get all scores:
grep 'Average CV score' ${proj_dir}/results/tpot/*
# get all optimized pipelines:
grep -A3 'exported_pipeline = make_pipeline' ${proj_dir}/results/tpot/*

# seed makes group splits, train/test splits, & model reproducible
# kinda slow (will take 1-4 hours depending on # of features)
# to speed things up increase remove_per_step value
python3 ${script_dir}/select_features.py \
--featmat ${proj_dir}/data/feature_matrix/feature_matrix_labeled_traintest.pkl \
--model ${proj_dir}/results/tpot/tpot_model_3.pkl \
--outdir ${proj_dir}/results/feature_selection/ \
--threads 12 --remove_per_step 3 --seed 13 2>&1 | tee ${proj_dir}/logs/select_features.log

# ---------------------------------------------------
# predict PPIs
# ---------------------------------------------------

# seed makes group splits, train/test splits, & model reproducible
# pretty quick (run time ~10min)
mkdir results/ppi_predict/{all_feats,top100_feats}

# generate predictions using all features
python3 ${script_dir}/predict_ppis.py \
--featmat ${proj_dir}/data/feature_matrix/feature_matrix_labeled.pkl \
--model ${proj_dir}/results/tpot/tpot_model_3.pkl \
--outdir ${proj_dir}/results/ppi_predict/all_feats/ \
--fdr_cutoff 0.1 --seed 13 2>&1 | tee ${proj_dir}/logs/predict_ppis_allfeats.log

# generate predictions using top 100 features
python3 ${script_dir}/predict_ppis.py \
--featmat ${proj_dir}/data/feature_matrix/feature_matrix_labeled.pkl \
--model ${proj_dir}/results/tpot/tpot_model_3.pkl \
--outdir ${proj_dir}/results/ppi_predict/top100_feats/ \
--feature_selection ${proj_dir}/results/feature_selection/top_feats_ExtraTreesClassifier_RFECV_all.csv \
--num_feats 100 --fdr_cutoff 0.1 --seed 13 2>&1 | tee ${proj_dir}/logs/predict_ppis_top100feats.log

# ---------------------------------------------------
# cluster PPIs
# ---------------------------------------------------

# **WORK IN PROGRESS**
# claire's old script
# i modified it so ~hopefully~ it won't throw an error
# we'll see ¯\_(ツ)_/¯
python ${script_dir}/diffusion_clustering.py \
--input_edges ${proj_dir}/results/ppi_predict/top100_feats/scored_interactions_fdr10_ExtraTreesClassifier.csv --sep , \
--header --id_cols ID --id_sep ' ' --threshold 0 --method walktrap --use_scores \
--outfile ${proj_dir}/results/walktrap/walktrap_clustering_fdr10_top100feats \
--weight_col ppi_score --steps 5 --export_excel

# note: threshold set to 0 because we already made an FDR-thresholded file

# ---------------------------------------------------
# sanity check your pipeline
# ---------------------------------------------------

# pretty quick (run time ~5min)
# will make a nice table in the log file
python3 ${script_dir}/sanity_checks.py \
--featmat_file ${proj_dir}/data/feature_matrix/feature_matrix_labeled.pkl \
--results_file ${proj_dir}/results/ppi_predict/all_feats/scored_interactions_all_ExtraTreesClassifier.csv 2>&1 | tee /project/rmcox/misc/vy.pipeline/logs/sanity_checks.log