#!/usr/bin/env Rscript
library(vcfR)
library(tidyverse)

# if GATKCNV input is in VCF format, using following code
readGATKcnvVcf <- function(gatk_vcf_file) {
  vcf <- read.vcfR(gatk_vcf_file)
  v <- vcfR2tidy(vcf)
  vcf_info <- merge(v$fix, v$gt, by = c("ChromKey", "POS"))
  vcf_info <- vcf_info %>% 
    filter(ALT != "<NA>") %>%
    mutate(SVLEN = abs(END-POS+1), seg.mean = NA, ALT = gsub("<|>", "", ALT)) %>%
    select(c("CHROM", "POS", "END", "SVLEN", "gt_CN",
             "QUAL", "seg.mean", "ALT"))
  return(vcf_info)
}

# main
args <- commandArgs(trailingOnly = TRUE)
gatk_cnv <- readGATKcnvVcf(args[1])
cnv_size_cutoff <- as.integer(args[2])
file_name <- args[3]

gatk_cnv %>% filter(gatk_cnv$ALT == "DEL" & gatk_cnv$SVLEN > cnv_size_cutoff) %>%
  write.table(file = paste0(file_name, ".gatkcnv.del.bed"),
  quote = FALSE, row.names = FALSE, col.names = FALSE, sep = "\t")
gatk_cnv %>% filter(gatk_cnv$ALT == "DUP" & gatk_cnv$SVLEN > cnv_size_cutoff) %>%
  write.table(file = paste0(file_name, ".gatkcnv.dup.bed"),
  quote = FALSE, row.names = FALSE, col.names = FALSE, sep = "\t")