cwlVersion: v1.2
class: CommandLineTool

requirements:
- class: InlineJavascriptRequirement
- class: ShellCommandRequirement
- class: DockerRequirement
  dockerPull: 'staphb/bedtools:2.31.1'

inputs:
  gatk_cnvnator_dup_merge_bed_file:
    type: File
  gatk_cnvnator_del_merge_bed_file:
    type: File
  sample_id:
    type: string

outputs:
  final_gatk_cnvnator_dup_merge_bed_file:
    type: File
    outputBinding:
      glob: "*.dup.merged.final.bed"
  final_gatk_cnvnator_del_merge_bed_file:
    type: File
    outputBinding:
      glob: "*.del.merged.final.bed"
  final_gatk_cnvnator_all_merge_bed_file:
    type: File
    outputBinding:
      glob: "*all_CNVs_combined.tsv"

baseCommand: [/bin/bash, -c]
arguments:
  - position: 0
    valueFrom: |-
      set -eo pipefail
      bedtools subtract -a $(inputs.gatk_cnvnator_dup_merge_bed_file.path) -b $(inputs.gatk_cnvnator_del_merge_bed_file.path) \
       > $(inputs.sample_id).dup-del.bed &&
      bedtools subtract -a $(inputs.gatk_cnvnator_del_merge_bed_file.path) -b $(inputs.gatk_cnvnator_dup_merge_bed_file.path) \
       > $(inputs.sample_id).del-dup.bed &&
        # intersect dups and dels to find regions where both where present
      bedtools intersect -a $(inputs.gatk_cnvnator_dup_merge_bed_file.path) -b $(inputs.gatk_cnvnator_del_merge_bed_file.path) \
       > $(inputs.sample_id).deldup_intersect.bed &&
        # find which of the intersection regions came from a duplication segment, then which came from deletions
      bedtools intersect -f 1 -r -a $(inputs.gatk_cnvnator_dup_merge_bed_file.path) -b $(inputs.sample_id).deldup_intersect.bed   \
       >  $(inputs.sample_id).dup_intersect.bed &&
      bedtools intersect -f 1 -r -a $(inputs.gatk_cnvnator_del_merge_bed_file.path) -b $(inputs.sample_id).deldup_intersect.bed  \
       >  $(inputs.sample_id).del_intersect.bed &&
        # combine dups and dels separately
      cat $(inputs.sample_id).dup-del.bed  $(inputs.sample_id).dup_intersect.bed | sort -k1,1V -k2,2n \
       > $(inputs.sample_id).dup.merged.final.bed &&
      cat $(inputs.sample_id).del-dup.bed  $(inputs.sample_id).del_intersect.bed | sort -k1,1V -k2,2n \
       > $(inputs.sample_id).del.merged.final.bed
        ## Take all of the del and dup files of ALL samples as input.
      echo 'chrom\tstart\tend\tgatk_CNVs\tcnvnator_CNVs\tCNV_type\tSampleID' > $(inputs.sample_id).all_CNVs_combined.tsv
      cut -f 1-7 $(inputs.sample_id).del.merged.final.bed $(inputs.sample_id).dup.merged.final.bed  \
        | sort -k1,1V -k2,2n >> $(inputs.sample_id).all_CNVs_combined.tsv
    shellQuote: false

