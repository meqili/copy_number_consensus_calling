#!/bin/bash
set -o pipefail

## The awk command line is to filter out the raw file.
## The end result has 8 columns
## | chr# | start | end | CNV_length | copy_numbers | pval | seg.mean | CNV type |
## The first awk looks at column 7 to filter out for loss/gain (-/+).
## Then it prints out all 8 of the columns above.
## It writes NA for both p-value and copy number since cnvnator results don't have these values.
## The first awk command also changes -/+ to DEL/DUP to match the other callers formatting
## The second awk filters the CNV length, and add in the CNV type
## The sort command sorts the first digit of chromosome number numerically
## The last pipe is to introduce tab into the file and output file name.

cnvnator_cnv_input_file=$1
cnv_size_cutoff=$2

awk '$1~/deletion/ {print $2,$3,$4,$5,"NA",$7,"NA","DEL"}' "$cnvnator_cnv_input_file" | \
awk -v cutoff="$cnv_size_cutoff" '{if ($4 > cutoff) print}' | \
sort -k1,1V -k2,2n | \
tr [:blank:] '\t' > "$(basename "$cnvnator_cnv_input_file" .tsv).cnvnator.del.bed"

awk '$1~/duplication/ {print $2,$3,$4,$5,"NA",$7,"NA","DUP"}' "$cnvnator_cnv_input_file" | \
awk -v cutoff="$cnv_size_cutoff" '{if ($4 > cutoff) print}' | \
sort -k1,1V -k2,2n | \
tr [:blank:] '\t' > "$(basename "$cnvnator_cnv_input_file" .tsv).cnvnator.dup.bed"