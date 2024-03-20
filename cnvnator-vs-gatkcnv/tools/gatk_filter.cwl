cwlVersion: v1.2
class: CommandLineTool
id: gatk_filter.cwl
label: GATK_CNV_Filter
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: DockerRequirement
  dockerPull: 'kible/coreutils:x86'
- class: InitialWorkDirRequirement
  listing:
    - entryname: gatk_filter_script.sh
      entry:
        $include: ../scripts/gatk_filter_script.sh

inputs:
  gatk_cnv_input_file:
    type: File
  cnv_size_cutoff:
    type: int?
    default: 3000

outputs:
  gatk_del:
    type: File
    outputBinding:
      glob: "*.gatk.del.bed"
  gatk_dup:
    type: File
    outputBinding:
      glob: "*.gatk.dup.bed"

baseCommand: [/bin/bash, gatk_filter_script.sh]

arguments:
  - valueFrom: $(inputs.gatk_cnv_input_file.path)
  - valueFrom: $(inputs.cnv_size_cutoff)
