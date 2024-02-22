#!/bin/bash
set -o pipefail

## The awk command line is to filter out the raw file.
## The end result has 8 columns
## | chr# | start | end | CNV_length | copy_numbers | pval | seg.mean | CNV type |
## The first awk looks at column 7 to filter out for loss/gain (-/+).
## Then it prints out all 8 of the columns above.
## It writes NA for both p-value and copy number since gatk results don't have these values.
## The first awk command also changes -/+ to DEL/DUP to match the other callers formatting
## The second awk filters the CNV length, and add in the CNV type
## The sort command sorts the first digit of chromosome number numerically
## The last pipe is to introduce tab into the file and output file name.

gatk_cnv_input_file=$1
cnv_size_cutoff=$2

awk '$4~/DEL/ {print $1,$2,$3,$12,$5,"NA","NA",$4}' "$gatk_cnv_input_file" | \
awk -v cutoff="$cnv_size_cutoff" '{if ($4 > cutoff) print}' | \
sort -k1,1V -k2,2n | \
tr [:blank:] '\t' > "$(basename "$gatk_cnv_input_file" .tsv).gatk.del.bed"

awk '$4~/DUP/ {print $1,$2,$3,$12,$5,"NA","NA",$4}' "$gatk_cnv_input_file" | \
awk -v cutoff="$cnv_size_cutoff" '{if ($4 > cutoff) print}' | \
sort -k1,1V -k2,2n | \
tr [:blank:] '\t' > "$(basename "$gatk_cnv_input_file" .tsv).gatk.dup.bed"