library(tidyverse)

# Read in the file listing gene counts per species 
counts <- read_tsv('~/environment/analyses/orthofinder/TCS/Results_EukProt_Proteins/Orthogroups/Orthogroups.GeneCount.tsv')

# Pull out orthogroup names
ogs <- counts$Orthogroup

# For simplicity, recode any non-zero gene counts to 1. 
counts.bin <- counts[,-ncol(counts)] %>% mutate_if(is.numeric, ~1 * (. > 0))

# Calculate rowsums to identify which orthogroups are observed in at least four species
num.spp.per.og <- rowSums(counts.bin[,-1])

# Now, read in the summaries of supergroup membership for each orthogroup
grp.counts <- read_tsv('~/environment/analyses/orthofinder/TCS/OrthogroupAnnotations/GenericOrthogroups/og_taxonomy_genecount_summaries/NumSpecies_PerSupergroup_InOGs.tsv')

# And count the number of supergroups per orthogroup.
num.grps.per.og <- rowSums(grp.counts[,-c(1:3)] > 0)

# Using this, we want to identify a 'core' set of orthogroups - those that 
# include at least four taxonomic supergroups, with a mean gene copy number 
# per species <= 3
# First calculate the mean per-species gene copy number:
og.perspp.means <- c(grp.counts$TotalNumGenes / num.spp.per.og)

# Then get the list of 'core' orthogroups
core.ogs <- counts[which(og.perspp.means <= 2 & num.grps.per.og >= 31),]

# Now create a dataframe that contains the Orthogroups with at least four species, and the total gene counts for each. 
# These totals will help to guide computational resources for downstream analyses. 
core.ogs <- data.frame(
    Orthogroup = core.ogs$Orthogroup,
    TotalGeneCount = core.ogs$Total)
    
# Write out to file. One with column names, one without 
write.table(core.ogs, file = '~/environment/analyses/orthofinder/TCS/Results_EukProt_Proteins/CoreOGs_All-SupGrps_MaxMean2-GeneCount-WithHeader.tsv', 
    sep = "\t", quote = F, row.names = F)
write.table(core.ogs, file = '~/environment/analyses/orthofinder/TCS/Results_EukProt_Proteins/CoreOGs_All-SupGrps_MaxMean2-GeneCount-NoHeader.tsv', 
    sep = "\t", quote = F, row.names = F, col.names=F)
