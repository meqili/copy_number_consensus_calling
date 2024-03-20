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
  child_bed_file:
    type: File
    inputBinding:
      prefix: --child
      position: 3
      shellQuote: false
  parent1_bed_file:
    type: File
    inputBinding:
      prefix: --parent1
      position: 3
      shellQuote: false
  parent2_bed_file:
    type: File
    inputBinding:
      prefix: --parent2
      position: 3
      shellQuote: false
  famly_id:
    type: string
    inputBinding:
      prefix: --familyID
      position: 3
      shellQuote: false
  cnv_type:
    type: string
      

outputs:
  child_parent1_bedfile:
    type: File
    outputBinding:
      glob: "*child_parent1.bed"
  child_parent2_bedfile:
    type: File
    outputBinding:
      glob: "*child_parent2.bed"


baseCommand: 
  - python
arguments:
  - valueFrom: |-
      compare_variant_calling_updated.py --child_parent1 $(inputs.famly_id).$(inputs.cnv_type).child_parent1.bed --child_parent2 $(inputs.famly_id).$(inputs.cnv_type).child_parent2.bed
    shellQuote: false
    position: 1