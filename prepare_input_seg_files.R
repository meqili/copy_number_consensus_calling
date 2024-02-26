library(tidyverse)
library(tidyr)
library(vcfR)

setwd("/Users/liq3/gatkCNV_cnvnator_cnv_analysis/Q1777/")
## if CNVnator input is in VCF format, using following code
# readCNVnatorVcf <- function(nator_vcf_file) {
#   vcf <- read.vcfR(vcf_file)
#   v <- vcfR2tidy(vcf, info_only = TRUE)
#   vcf_fix <- v$fix %>%
#     select(c("CHROM", "POS", "END", "SVLEN", "SVTYPE", 
#              "natorRD", "natorP1", "natorP2", "natorP3", 
#              "natorP4", "natorQ0", "natorPE")) %>%
#     mutate(SVLEN = abs(SVLEN))
#   return(vcf_fix)
# }
# nator_cnv <- readCNVnatorVcf(nator_vcf_file)

## if CNVnator input is in TXT format, using following code
readCNVnatorTable <- function(nator_txt_file){
  nator_cols <- c("CNV_type", "CNV_id", "SVLEN", "natorRD", "natorP1", 
                  "natorP2", "natorP3", "natorP4", "natorQ0")
  cnv_tb <- read.table(nator_txt_file, header = FALSE,
                       col.names = nator_cols) %>%
    separate(CNV_id, into = c("CHROM", "POS_END"), sep = ":", remove = TRUE) %>%
    separate(POS_END, into = c("POS", "END"), sep = "-", remove = TRUE)
}

readGatkVcf <- function(gatk_vcf_file) {
  vcf <- read.vcfR(gatk_vcf_file)
  v <- vcfR2tidy(vcf)
  vcf_fix <- v$fix %>%
    drop_na(ALT) %>%
    mutate(SVTYPE = str_remove_all(ALT, "<|>")) %>%
    unite("key", ChromKey, POS, sep = "-", remove = FALSE) %>%
    select(c("key", "ChromKey", "CHROM", "POS", "END", "SVTYPE"))
  gt <- v$gt %>% unite("key", ChromKey, POS, sep = "-", remove = FALSE) %>%
    select(-c("Indiv", "gt_GT_alleles"))
  variants <- vcf_fix %>% left_join(gt, by = "key") %>% 
    select(-contains(".y")) %>% select(-c("key", "ChromKey.x")) %>%
    rename("POS"="POS.x") %>%
    mutate(SVLEN = END - POS +1)
  return(variants)
}


# nator_vcf_file <- "Q1777/BS_529GMFX4/2b8b954b-20c3-406b-912a-d3dbaf07e741.mixed_cohort.cnvnator_call.vcf"
nator_txt_file <- "Q1777/BS_529GMFX4/2b8b954b-20c3-406b-912a-d3dbaf07e741.mixed_cohort.cnvnator_call.txt"
gatk_vcf_file <- "Q1777/BS_529GMFX4/2b8b954b-20c3-406b-912a-d3dbaf07e741.mixed_cohort.gatk_gcnv.genotyped_segments.vcf"

nator_cnv <- readCNVnatorTable(nator_txt_file)
gatk_cnv <- readGatkVcf(gatk_vcf_file)

nator_cnv_file_name = paste0(dirname(nator_txt_file), "/cnv-cnvnator.tsv")
gatk_cnv_file_name = paste0(dirname(nator_txt_file), "/cnv-gatk.tsv")

write_tsv(nator_cnv, nator_cnv_file_name)
write_tsv(gatk_cnv, gatk_cnv_file_name)


# Q1777
for (gatk_file in list.files(pattern = ".mixed_cohort.gatk_gcnv.genotyped_segments.vcf.gz")) {
  gatk_cnv <- readGatkVcf(gatk_file)
  gatk_cnv_file_name = gsub("vcf.gz", "vcf.tsv", gatk_file)
  write_tsv(gatk_cnv, gatk_cnv_file_name)
}