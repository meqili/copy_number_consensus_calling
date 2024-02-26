# Script Name: svlen_histograms.R
# Purpose: Generate histograms for SVLEN distributions of three samples (Q1777, Q1777p1, Q1777p2)
# Author: Qi Li
# Date: 02-26-2024
# Usage: Rscript svlen_histograms.R
# Note: Modify file paths accordingly.

# Load required libraries
library(ggplot2)
library(dplyr)

# Read the TSV files into data frames
Q1777_data <- read.delim("Q1777.mixed_cohort.gatk_gcnv.genotyped_segments.vcf.tsv", header = TRUE)
Q1777p1_data <- read.delim("Q1777p1.mixed_cohort.gatk_gcnv.genotyped_segments.vcf.tsv", header = TRUE)
Q1777p2_data <- read.delim("Q1777p2.mixed_cohort.gatk_gcnv.genotyped_segments.vcf.tsv", header = TRUE)

# Combine all data into one dataframe with an additional column indicating the sample
combined_data <- rbind(
  transform(Q1777_data, Sample = "Q1777"),
  transform(Q1777p1_data, Sample = "Q1777p1"),
  transform(Q1777p2_data, Sample = "Q1777p2")
)

# Create histogram with facets
ggplot(combined_data, aes(x = log10(SVLEN))) +
  geom_histogram(fill = "blue", alpha = 0.7) +
  facet_wrap(~ Sample, scales = "free") +
  labs(title = "SVLEN Distribution")

