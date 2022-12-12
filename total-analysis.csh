#!/bin/sh
#
###SBATCH --job-name=moving_pictures 
#SBATCH --time=72:00:00
#SBATCH --ntasks=12
#SBATCH --cpus-per-task=1
#SBATCH --partition=shared
#load qiime module
module load qiime2/2018.8

export TMPDIR='/scratch/users/s-zwang302@jhu.edu/tmp'
export LC_ALL=en_US.utf-8
export LANG=en_US.utf-8

echo "Beginning QIIME"
date

OUTPUT=ZY_pipeline_test
METADATA=metadata.txt
MANIFEST=short_CB_manifest.csv
VAR1=SC
DEPTH=1000

mkdir $OUTPUT

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path ${MANIFEST} \
  --output-path ${OUTPUT}/demux.qza \
  --input-format PairedEndFastqManifestPhred33

cp ${METADATA} ${OUTPUT}/sample-metadata.tsv

qiime demux summarize \
  --i-data $OUTPUT/demux.qza \
  --o-visualization $OUTPUT/demux.qzv

date

qiime dada2 denoise-paired \
  --i-demultiplexed-seqs ${OUTPUT}/demux.qza \
  --p-trim-left-f 23 \
   --p-trim-left-r 23 \
   --p-trunc-len-f 200 \
   --p-trunc-len-r 200\
  --p-n-threads 0 --p-min-fold-parent-over-abundance 10\
  --o-representative-sequences ${OUTPUT}/rep-seqs-dada2.qza \
  --o-table ${OUTPUT}/table-dada2.qza \
  --o-denoising-stats ${OUTPUT}/stats-dada2.qza

qiime metadata tabulate \
  --m-input-file $OUTPUT/stats-dada2.qza \
  --o-visualization $OUTPUT/stats-dada2.qzv

mv $OUTPUT/rep-seqs-dada2.qza $OUTPUT/rep-seqs.qza
mv $OUTPUT/table-dada2.qza $OUTPUT/table.qza

date

qiime feature-table summarize \
  --i-table $OUTPUT/table.qza \
  --o-visualization $OUTPUT/table.qzv \
  --m-sample-metadata-file $OUTPUT/sample-metadata.tsv
qiime feature-table tabulate-seqs \
  --i-data $OUTPUT/rep-seqs.qza \
  --o-visualization $OUTPUT/rep-seqs.qzv

qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences $OUTPUT/rep-seqs.qza \
  --o-alignment $OUTPUT/aligned-rep-seqs.qza \
  --o-masked-alignment $OUTPUT/masked-aligned-rep-seqs.qza \
  --o-tree $OUTPUT/unrooted-tree.qza \
  --o-rooted-tree $OUTPUT/rooted-tree.qza

qiime diversity core-metrics-phylogenetic \
  --i-phylogeny $OUTPUT/rooted-tree.qza \
  --i-table $OUTPUT/table.qza \
  --p-sampling-depth ${DEPTH} \
  --m-metadata-file $OUTPUT/sample-metadata.tsv \
  --output-dir $OUTPUT/core-metrics-results

qiime diversity alpha-group-significance \
  --i-alpha-diversity $OUTPUT/core-metrics-results/faith_pd_vector.qza \
  --m-metadata-file $OUTPUT/sample-metadata.tsv \
  --o-visualization $OUTPUT/core-metrics-results/faith-pd-group-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity $OUTPUT/core-metrics-results/evenness_vector.qza \
  --m-metadata-file $OUTPUT/sample-metadata.tsv \
  --o-visualization $OUTPUT/core-metrics-results/evenness-group-significance.qzv

qiime diversity alpha-rarefaction \
  --i-table $OUTPUT/table.qza \
  --i-phylogeny $OUTPUT/rooted-tree.qza \
  --p-max-depth ${DEPTH} \
  --m-metadata-file $OUTPUT/sample-metadata.tsv \
  --o-visualization $OUTPUT/alpha-rarefaction.qzv

wget \
  -O $OUTPUT/"gg-13-8-99-515-806-nb-classifier.qza" \
  "https://data.qiime2.org/2018.8/common/gg-13-8-99-515-806-nb-classifier.qza"

qiime feature-classifier classify-sklearn \
  --i-classifier $OUTPUT/gg-13-8-99-515-806-nb-classifier.qza \
  --i-reads $OUTPUT/rep-seqs.qza \
  --o-classification $OUTPUT/taxonomy.qza

qiime metadata tabulate \
  --m-input-file $OUTPUT/taxonomy.qza \
  --o-visualization $OUTPUT/taxonomy.qzv

qiime taxa barplot \
  --i-table $OUTPUT/table.qza \
  --i-taxonomy $OUTPUT/taxonomy.qza \
  --m-metadata-file $OUTPUT/sample-metadata.tsv \
  --o-visualization $OUTPUT/taxa-bar-plots.qzv

date

qiime composition add-pseudocount \
  --i-table $OUTPUT/table.qza \
  --o-composition-table $OUTPUT/comp-table.qza

qiime composition ancom \
  --i-table $OUTPUT/comp-table.qza \
  --m-metadata-file $OUTPUT/sample-metadata.tsv \
  --m-metadata-column ${VAR1} \
  --o-visualization $OUTPUT/ancom.qzv

qiime taxa collapse \
  --i-table $OUTPUT/table.qza \
  --i-taxonomy $OUTPUT/taxonomy.qza \
  --p-level 6 \
  --o-collapsed-table $OUTPUT/table-l6.qza

qiime composition add-pseudocount \
  --i-table $OUTPUT/table-l6.qza \
  --o-composition-table $OUTPUT/comp-table-l6.qza

qiime composition ancom \
  --i-table $OUTPUT/comp-table-l6.qza \
  --m-metadata-file $OUTPUT/sample-metadata.tsv \
  --m-metadata-column ${VAR1} \
  --o-visualization $OUTPUT/l6-ancom.qzv

date

qiime taxa collapse \
  --i-table $OUTPUT/table.qza \
  --i-taxonomy $OUTPUT/taxonomy.qza \
  --p-level 5 \
  --o-collapsed-table $OUTPUT/table-l5.qza

qiime composition add-pseudocount \
  --i-table $OUTPUT/table-l5.qza \
  --o-composition-table $OUTPUT/comp-table-l5.qza

qiime composition ancom \
  --i-table $OUTPUT/comp-table-l5.qza \
  --m-metadata-file $OUTPUT/sample-metadata.tsv \
  --m-metadata-column ${VAR1} \
  --o-visualization $OUTPUT/l5-ancom.qzv


