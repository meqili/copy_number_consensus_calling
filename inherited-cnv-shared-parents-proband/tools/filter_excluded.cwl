cwlVersion: v1.2
class: CommandLineTool

requirements:
- class: DockerRequirement
  dockerPull: 'staphb/bedtools:2.31.1'

inputs:
  bedfile:
    type: File
  exclude_list:
    type: File
  excluded_list_overlap_threshold:
    type: float
    default: 0.5

outputs:
  filtered_bedfile:
    type: File
    outputBinding:
      glob: "*.filtered.bed"

baseCommand: [/bin/bash, -c]
arguments:
- position: 0
  valueFrom: |-
    bedtools subtract -N -a $(inputs.bedfile.path) -b $(inputs.exclude_list.path) -f $(inputs.excluded_list_overlap_threshold) > $(inputs.bedfile.nameroot).filtered.bed
  shellQuote: true