cwlVersion: v1.2
class: CommandLineTool

requirements:
- class: InlineJavascriptRequirement
- class: ShellCommandRequirement
- class: DockerRequirement
  dockerPull: 'staphb/bedtools:2.31.1'

inputs:
  child_parent1_bedfile:
    type: File
  child_parent2_bedfile:
    type: File

outputs:
  family_merged_bedfile:
    type: File
    outputBinding:
      glob: "*.merged.bed"

baseCommand: [bash, -c]
arguments:
  - valueFrom: |
      set -eo pipefail
      cat $(inputs.child_parent1_bedfile.path) $(inputs.child_parent2_bedfile.path) \
        | sort -k1,1V -k2,2n \
        | bedtools merge -c 4,5,6,7,8,9 -o collapse,collapse,collapse,distinct,distinct,collapse \
        > $(inputs.child_parent1_bedfile.basename.replace("child_parent1.bed", "merged.bed"))
  - shellQuote: false
