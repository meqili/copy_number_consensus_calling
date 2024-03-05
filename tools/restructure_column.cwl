cwlVersion: v1.2
class: CommandLineTool

requirements:
- class: InlineJavascriptRequirement
- class: DockerRequirement
  dockerPull: 'pgc-images.sbgenomics.com/qqlii44/python:3.8.10'
- class: InitialWorkDirRequirement
  listing:
    - entryname: restructure_column.py
      entry:
        $include: ../scripts/restructure_column.py

inputs:
  merged_bedfile:
    type: File

outputs:
  restructured_bedfile:
    type: File
    outputBinding:
      glob: "*.filtered3.bed"

baseCommand: [bash -c]
arguments:
- position: 0
  valueFrom: |-
    python3 restructure_column.py --file $(inputs.merged_bedfile.path) > $(inputs.filtered_bedfile.basename.replace("filtered2.bed", "filtered3.bed"))
  shellQuote: true
