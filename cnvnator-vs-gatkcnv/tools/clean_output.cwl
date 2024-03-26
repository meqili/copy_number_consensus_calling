cwlVersion: v1.2
class: CommandLineTool

requirements:
- class: InlineJavascriptRequirement
- class: DockerRequirement
  dockerPull: 'pgc-images.sbgenomics.com/qqlii44/python:3.8.10'
- class: InitialWorkDirRequirement
  listing:
    - entryname: remove_dup_NULL_overlap_entries.py
      entry:
        $include: ../scripts/remove_dup_NULL_overlap_entries.py

inputs:
  cnv_file:
    type: File
  sample_id:
    type: string

outputs:
  clean_cnv_consensus_file:
    type: File
    outputBinding:
      glob: "*.cnv_consensus-cnator-gatk.tsv"

baseCommand: [bash -c]
arguments:
- position: 0
  valueFrom: |-
    python3 remove_dup_NULL_overlap_entries.py --file $(inputs.cnv_file.path) > $(inputs.sample_id)".cnv_consensus-cnator-gatk.tsv"
  shellQuote: true
