cwlVersion: v1.2
class: CommandLineTool
id: cnvnator_filter.cwl
label: CNVnator_CNV_Filter
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: DockerRequirement
  dockerPull: 'pgc-images.sbgenomics.com/qqlii44/vcfr-with-tidyverse:1.0'
- class: InitialWorkDirRequirement
  listing:
    - entryname: cnvnator_filter_script.R
      entry:
        $include: ../scripts/cnvnator_filter_script.R

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

baseCommand: [Rscript, cnvnator_filter_script.R]

arguments:
  - valueFrom: $(inputs.cnvnator_cnv_input_file.path)
  - valueFrom: $(inputs.cnv_size_cutoff)
  - valueFrom: $(inputs.cnvnator_cnv_input_file.nameroot)
