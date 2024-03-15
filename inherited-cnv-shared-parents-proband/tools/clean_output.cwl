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
  all_CNVs_combined_file:
    type: File

outputs:
  clean_output_file:
    type: File
    outputBinding:
      glob: "*cnv_consensus.tsv"

baseCommand: [bash -c]
arguments:
- position: 0
  valueFrom: |-
    python3 remove_dup_NULL_overlap_entries.py --file $(inputs.all_CNVs_combined_file.path) > $(inputs.all_CNVs_combined_file.basename.replace("all_CNVs_combined", "cnv_consensus"))
  shellQuote: true
