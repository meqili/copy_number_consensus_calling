cwlVersion: v1.2
class: CommandLineTool

requirements:
- class: DockerRequirement
  dockerPull: 'pgc-images.sbgenomics.com/qqlii44/python:3.8.10'
- class: InitialWorkDirRequirement
  listing:
    - entryname: compare_variant_calling_updated.py
      entry:
        $include: ../scripts/compare_variant_calling_updated.py
- class: ShellCommandRequirement

inputs:
  gatk_and_cnvnator_bed_files:
    type: File[]
    inputBinding:
      prefix: --gatk_and_cnvnator_bed_files
      position: 3
      itemSeparator: ","
      shellQuote: false
  sample_id:
    type: string
    inputBinding:
      prefix: --sample_id
      position: 3
  cnv_type:
    type: string
      

outputs:
  gatk_cnvnator_merged_bedfile:
    type: File
    outputBinding:
      glob: "*gatk_cnvnator.bed"


baseCommand: 
  - python
arguments:
  - valueFrom: |-
      compare_variant_calling_updated.py --gatk_cnvnator $(inputs.sample_id).$(inputs.cnv_type).gatk_cnvnator.bed
    shellQuote: false
    position: 1