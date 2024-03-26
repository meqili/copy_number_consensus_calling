cwlVersion: v1.2
class: CommandLineTool

requirements:
- class: InlineJavascriptRequirement
- class: ShellCommandRequirement
- class: DockerRequirement
  dockerPull: 'staphb/bedtools:2.31.1'

inputs:
  final_family_dup_merge_bed_file:
    type: File
  final_family_del_merge_bed_file:
    type: File
  sample_id:
    type: string
  callable_bed_file:
    type: File

outputs:
  neutral_regions_bed_file:
    type: File
    outputBinding:
      glob: "*neutral.bed"


baseCommand: [/bin/bash, -c]
arguments:
  - position: 0
    valueFrom: |-
      set -eo pipefail;
      bedtools subtract -a $(inputs.callable_bed_file.path) -b $(inputs.final_family_dup_merge_bed_file.path) \
         | bedtools subtract -a stdin -b $(inputs.final_family_del_merge_bed_file.path) \
         | sed 's/$/\t$(inputs.sample_id)/' | sort -k1,1V -k2,2n > $(inputs.sample_id).neutral.bed
    shellQuote: false

