cwlVersion: v1.2
class: CommandLineTool

requirements:
- class: InlineJavascriptRequirement
- class: ShellCommandRequirement
- class: DockerRequirement
  dockerPull: 'staphb/bedtools:2.31.1'

inputs:
  family_dup_merge_bed_file:
    type: File
  family_del_merge_bed_file:
    type: File
  famly_id:
    type: string

outputs:
  final_family_dup_merge_bed_file:
    type: File
    outputBinding:
      glob: "*.dup.merged.final.bed"
  final_family_del_merge_bed_file:
    type: File
    outputBinding:
      glob: "*.del.merged.final.bed"

baseCommand: [/bin/bash, -c]
arguments:
  - position: 0
    valueFrom: |-
      set -eo pipefail
      bedtools subtract -a $(inputs.family_dup_merge_bed_file.path) -b $(inputs.family_del_merge_bed_file.path) \
       > $(inputs.famly_id).dup-del.bed &&
      bedtools subtract -a $(inputs.family_del_merge_bed_file.path) -b $(inputs.family_dup_merge_bed_file.path) \
       > $(inputs.famly_id).del-dup.bed &&
        # intersect dups and dels to find regions where both where present
      bedtools intersect -a $(inputs.family_dup_merge_bed_file.path) -b $(inputs.family_del_merge_bed_file.path) \
       > $(inputs.famly_id).deldup_intersect.bed &&
        # find which of the intersection regions came from a duplication segment, then which came from deletions
      bedtools intersect -f 1 -r -a $(inputs.family_dup_merge_bed_file.path) -b $(inputs.famly_id).deldup_intersect.bed   \
       >  $(inputs.famly_id).dup_intersect.bed &&
      bedtools intersect -f 1 -r -a $(inputs.family_del_merge_bed_file.path) -b $(inputs.famly_id).deldup_intersect.bed  \
       >  $(inputs.famly_id).del_intersect.bed &&
        # combine dups and dels separately
      cat $(inputs.famly_id).dup-del.bed  $(inputs.famly_id).dup_intersect.bed \
       > $(inputs.famly_id).dup.merged.final.bed &&
      cat $(inputs.famly_id).del-dup.bed  $(inputs.famly_id).del_intersect.bed  \
       > $(inputs.famly_id).del.merged.final.bed
    shellQuote: false

