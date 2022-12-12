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
VAR1=SC
DEPTH=1000

date

qiime taxa collapse \
  --i-table $OUTPUT/table.qza \
  --i-taxonomy $OUTPUT/taxonomy.qza \
  --p-level 5 \
  --o-collapsed-table $OUTPUT/table-l5.qza

date

qiime composition add-pseudocount \
  --i-table $OUTPUT/table-l5.qza \
  --o-composition-table $OUTPUT/comp-table-l5.qza

date

qiime composition ancom \
  --i-table $OUTPUT/comp-table-l5.qza \
  --m-metadata-file $OUTPUT/sample-metadata.tsv \
  --m-metadata-column ${VAR1} \
  --o-visualization $OUTPUT/l5-ancom.qzv

date
