cwlVersion: v1.2
class: CommandLineTool
id: cnvnator_filter.cwl
label: CNVnator_CNV_Filter
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: DockerRequirement
  dockerPull: 'kible/coreutils:x86'
- class: InitialWorkDirRequirement
  listing:
    - entryname: cnvnator_filter_script.sh
      entry:
        $include: ../scripts/cnvnator_filter_script.sh

inputs:
  cnvnator_cnv_input_file:
    type: File
  cnv_size_cutoff:
    type: int?
    default: 3000

outputs:
  cnvnator_del:
    type: File
    outputBinding:
      glob: "*.cnvnator.del.bed"
  cnvnator_dup:
    type: File
    outputBinding:
      glob: "*.cnvnator.dup.bed"

baseCommand: [/bin/bash, cnvnator_filter_script.sh]

arguments:
  - valueFrom: $(inputs.cnvnator_cnv_input_file.path)
  - valueFrom: $(inputs.cnv_size_cutoff)
