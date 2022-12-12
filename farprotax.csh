#!/bin/sh
#
####SBATCH --job-name=farprotax 
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

qiime taxa collapse \
  --i-table table.qza \
  --i-taxonomy taxonomy.qza \
  --p-level 7 \
  --o-collapsed-table table_l7.qza

date

qiime tools export \
  --input-path table_l7.qza \
  --output-path table_l7_export

date

~/work/code/FAPROTAX_1.2.4/collapse_table.py -i
table_l7_export/feature-table.biom -o
table_l7_export/FAPROTAX_output_table.txt -r
table_l7_export/FAPROTAX_report.txt -l
table_l7_export/FAPROTAX_log.txt \
  --input_groups_file ~/work/code/FAPROTAX_1.2.4/FAPROTAX.txt \

date

biom convert -i
table_l7_export/FAPROTAX_output_table.txt -o
table_l7_export/FAPROTAX_output_table.biom \
  --table-type="OTU table" \
  --to-hdf5 \

date

qiime tools import \
  --input-path table_l7_export/FAPROTAX_output_table.biom \
  --type 'FeatureTable[Frequency]' \
  --output-path table_l7_export/FAPROTAX_output_table.qza
