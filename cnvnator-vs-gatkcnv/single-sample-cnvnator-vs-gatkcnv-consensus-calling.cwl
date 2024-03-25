#!/usr/bin/env cwl-runner

cwlVersion: v1.2
class: Workflow
id: single-sample-cnvnator-vs-gatk-consensus-calling-wf
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
- id: sample_id
  type: string

outputs:
- id: gatk_cnvnator_merge_bedfile_del
  type: File
  outputSource:
  - compare_cnv_methods_del/gatk_cnvnator_merged_bedfile
- id: gatk_cnvnator_merge_bedfile_dup
  type: File
  outputSource:
  - compare_cnv_methods_dup/gatk_cnvnator_merged_bedfile

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
- id: filter_excluded_dup
  in:
  - id: exclude_list
    source: exclude_list
  - id: excluded_list_overlap_threshold
    source: excluded_list_overlap_threshold
  - id: bedfile
    source:
    - gatk_filter/gatk_dup
    - cnvnator_filter/cnvnator_dup
  run: tools/filter_excluded.cwl
  scatter: bedfile
  out:
  - id: filtered_bedfile
- id: filter_excluded_del
  in:
  - id: exclude_list
    source: exclude_list
  - id: excluded_list_overlap_threshold
    source: excluded_list_overlap_threshold
  - id: bedfile
    source:
    - gatk_filter/gatk_del
    - cnvnator_filter/cnvnator_del
  run: tools/filter_excluded.cwl
  scatter: bedfile
  out:
  - id: filtered_bedfile
- id: first_merge_dup
  in:
  - id: max_overlap
    source: max_overlap
  - id: filtered_bedfile
    source:
    - filter_excluded_dup/filtered_bedfile
  run: tools/first_merge.cwl
  scatter: filtered_bedfile
  out:
  - id: merged_bedfile
- id: first_merge_del
  in:
  - id: max_overlap
    source: max_overlap
  - id: filtered_bedfile
    source:
    - filter_excluded_del/filtered_bedfile
  run: tools/first_merge.cwl
  scatter: filtered_bedfile
  out:
  - id: merged_bedfile
- id: restructure_column_dup
  in:
  - id: merged_bedfile
    source:
    - first_merge_dup/merged_bedfile
  run: tools/restructure_column.cwl
  scatter: merged_bedfile
  out:
  - id: restructured_bedfile
- id: restructure_column_del
  in:
  - id: merged_bedfile
    source:
    - first_merge_del/merged_bedfile
  run: tools/restructure_column.cwl
  scatter: merged_bedfile
  out:
  - id: restructured_bedfile
- id: compare_cnv_methods_dup
  in:
  - id: gatk_and_cnvnator_bed_files
    source:
    - restructure_column_dup/restructured_bedfile
  - id: sample_id
    source:
    - sample_id
  - id: cnv_type
    default: 'dup'
  run: tools/compare_cnv_methods.cwl
  out:
  - id: gatk_cnvnator_merged_bedfile
- id: compare_cnv_methods_del
  in:
  - id: gatk_and_cnvnator_bed_files
    source:
    - restructure_column_del/restructured_bedfile
  - id: sample_id
    source:
    - sample_id
  - id: cnv_type
    default: 'del'
  run: tools/compare_cnv_methods.cwl
  out:
  - id: gatk_cnvnator_merged_bedfile