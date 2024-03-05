cwlVersion: v1.2
class: CommandLineTool

requirements:
- class: InlineJavascriptRequirement
- class: DockerRequirement
  dockerPull: 'staphb/bedtools:2.31.1'

inputs:
  filtered_bedfile:
    type: File
  max_overlap:
    type: int
    default: 10000

outputs:
  merged_bedfile:
    type: File
    outputBinding:
      glob: "*.filtered2.bed"

baseCommand: [/bin/bash, -c]
arguments:
- position: 0
  valueFrom: |-
    set -eo pipefail; sort -k1,1V -k2,2n $(inputs.filtered_bedfile.path) | bedtools merge -i stdin -d $(inputs.max_overlap) -c 2,3,5,7,8 -o collapse,collapse,collapse,collapse,distinct > $(inputs.filtered_bedfile.basename.replace("filtered.bed", "filtered2.bed"))
  shellQuote: true
