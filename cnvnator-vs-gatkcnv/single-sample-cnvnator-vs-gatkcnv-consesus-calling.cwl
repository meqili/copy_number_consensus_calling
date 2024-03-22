#!/usr/bin/env cwl-runner

cwlVersion: v1.2
class: Workflow
id: family-based-variant-filtering-wf
label: Single Sample Consesus Calling - gatkCNV vs CNVnator
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: InlineJavascriptRequirement
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement

inputs:
- id: gatk_cnv_input_file
  type: File
- id: cnvnator_cnv_input_file
  type: File
- id: cnv_size_cutoff
  type: int?
  default: 3000
- id: exclude_list
  type: File
- id: excluded_list_overlap_threshold
  type: float?
  default: 0.5
- id: max_overlap
  type: int?
  default: 10000

steps:
- id: gatk_filter
  in:
  - id: gatk_cnv_input_file
    source: gatk_cnv_input_file
  - id: cnv_size_cutoff
    source: cnv_size_cutoff
  run: tools/gatk_filter.cwl
  out:
  - id: gatk_del
  - id: gatk_dup
- id: cnvnator_filter
  in:
  - id: cnvnator_cnv_input_file
    source: cnvnator_cnv_input_file
  - id: cnv_size_cutoff
    source: cnv_size_cutoff
  run: tools/cnvnator_filter.cwl
  out:
  - id: cnvnator_del
  - id: cnvnator_dup
- id: filter_excluded
  in:
  - id: exclude_list
    source: exclude_list
  - id: excluded_list_overlap_threshold
    source: excluded_list_overlap_threshold
  - id: bedfile
    source:
    - gatk_filter/gatk_del
    - gatk_filter/gatk_dup
    - cnvnator_filter/cnvnator_del
    - cnvnator_filter/cnvnator_dup
  run: tools/filter_excluded.cwl
  scatter: bedfile
  out:
  - id: gatk_cnvnator_deldup_filtered_outputs
- id: first_merge
  in:
  - id: max_overlap
    source: max_overlap
  - id: filtered_bedfile
    source:
    - filter_excluded/gatk_cnvnator_deldup_filtered_outputs
  run: tools/first_merge.cwl
  scatter: filtered_bedfile
  out:
  - id: gatk_cnvnator_deldup_filtered2_outputs
- id: restructure_column
  in:
  - id: merged_bedfile
    source:
    - first_merge/gatk_cnvnator_deldup_filtered2_outputs
  run: tools/restructure_column.cwl
  scatter: merged_bedfile
  out:
  - id: gatk_cnvnator_deldup_filtered3_outputs