library(tidyverse)
library(tidyr)
library(vcfR)

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
nator_cnv <- readCNVnatorVcf(nator_txt_file)

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
gatk_cnv <- readGatkVcf(gatk_vcf_file)

writeOutputs < function(sample_id, nator_cnv, gatk_cnv) {
}

# nator_vcf_file <- "Q1777/BS_529GMFX4/2b8b954b-20c3-406b-912a-d3dbaf07e741.mixed_cohort.cnvnator_call.vcf"
nator_txt_file <- "Q1777/BS_529GMFX4/2b8b954b-20c3-406b-912a-d3dbaf07e741.mixed_cohort.cnvnator_call.txt"
gatk_vcf_file <- "Q1777/BS_529GMFX4/2b8b954b-20c3-406b-912a-d3dbaf07e741.mixed_cohort.gatk_gcnv.genotyped_segments.vcf"
SAMPLEID <- "BS_529GMFX4"



