# Install and load required libraries if not already installed
# install.packages(c("ggplot2", "gridExtra"))

library(ggplot2)
library(gridExtra)

# File paths
file_paths <- c(
  "Q1777.mixed_cohort.gatk_gcnv.genotyped_segments.vcf.gatk.del.bed",
  "Q1777.mixed_cohort.gatk_gcnv.genotyped_segments.vcf.gatk.dup.bed",
  "Q1777p1.mixed_cohort.gatk_gcnv.genotyped_segments.vcf.gatk.del.bed",
  "Q1777p1.mixed_cohort.gatk_gcnv.genotyped_segments.vcf.gatk.dup.bed",
  "Q1777p2.mixed_cohort.gatk_gcnv.genotyped_segments.vcf.gatk.del.bed",
  "Q1777p2.mixed_cohort.gatk_gcnv.genotyped_segments.vcf.gatk.dup.bed"
)

# Read data and create plots
plots <- list()

for (i in seq_along(file_paths)) {
  file_path <- file_paths[i]
  
  # Read data without header, assuming third column is svlen
  data <- read.table(file_path, header = FALSE)
  
  # Create histograms
  plot <- ggplot(data, aes(x = log10(V3))) +
    geom_histogram(fill = ifelse(grepl("del", file_path), "blue", "green"), alpha = 0.7) +
    labs(title = file_path)
  plots[[i]] <- plot
}

# Arrange plots in a 3x2 grid
grid.arrange(
  plots[[1]], plots[[2]],
  plots[[3]], plots[[4]],
  plots[[5]], plots[[6]],
  ncol = 2
)
