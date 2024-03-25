#!/usr/bin/env Rscript
library(vcfR)
library(tidyverse)

# if CNVnator input is in VCF format, using following code
readCNVnatorVcf <- function(nator_vcf_file) {
  vcf <- read.vcfR(nator_vcf_file)
  v <- vcfR2tidy(vcf)
  vcf_info <- merge(v$fix, v$gt, by = c("ChromKey", "POS"))
  vcf_info <- vcf_info %>% mutate(SVLEN = abs(SVLEN), seg.mean = NA) %>%
    select(c("CHROM", "POS", "END", "SVLEN", "gt_CN",
             "natorP1", "seg.mean", "SVTYPE"))
  return(vcf_info)
}

# main
args <- commandArgs(trailingOnly = TRUE)
nator_cnv <- readCNVnatorVcf(args[1])
cnv_size_cutoff <- as.integer(args[2])
file_name <- args[3]

nator_cnv %>% filter(nator_cnv$SVTYPE == "DEL" & nator_cnv$SVLEN > cnv_size_cutoff) %>%
  write.table(file = paste0(file_name, ".cnvnator.del.bed"),
  quote = FALSE, row.names = FALSE, col.names = FALSE, sep = "\t")
nator_cnv %>% filter(nator_cnv$SVTYPE == "DUP" & nator_cnv$SVLEN > cnv_size_cutoff) %>%
  write.table(file = paste0(file_name, ".cnvnator.dup.bed"),
  quote = FALSE, row.names = FALSE, col.names = FALSE, sep = "\t")