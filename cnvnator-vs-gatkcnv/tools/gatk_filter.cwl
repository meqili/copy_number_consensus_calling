cwlVersion: v1.2
class: CommandLineTool
id: gatk_filter.cwl
label: GATK_CNV_Filter
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: DockerRequirement
  dockerPull: 'pgc-images.sbgenomics.com/qqlii44/vcfr-with-tidyverse:1.0'
- class: InitialWorkDirRequirement
  listing:
    - entryname: gatk_filter_script.R
      entry:
        $include: ../scripts/gatk_filter_script.R

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
      glob: "*.gatkcnv.del.bed"
  gatk_dup:
    type: File
    outputBinding:
      glob: "*.gatkcnv.dup.bed"

baseCommand: [Rscript, gatk_filter_script.R]

arguments:
  - valueFrom: $(inputs.gatk_cnv_input_file.path)
  - valueFrom: $(inputs.cnv_size_cutoff)
  - valueFrom: $(inputs.gatk_cnv_input_file.nameroot)
