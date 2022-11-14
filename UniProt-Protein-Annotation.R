# Libraries to get annotations using parallel computing
library(UniProt.ws)
library(tidyverse)

# Get the list of species for which we will be doing this GO-term mapping, and the paths to their corresponding UniProt accessions.
idDir <- '~/environment/data/nf-test/protein-ids/'
ids <- list.files(path = idDir)

# and pull out the species names
spps <- gsub("\\-.*","", ids)

# Because this is going to be a fair bit of information, let's make a new directory to house these outputs/gene ontologies. 
annotDir <- '~/environment/data/nf-test/protein-annots/'
dir.create(file.path(annotDir), showWarnings = FALSE) # Will only create the directory if it doesn't already exist. 


# Great. Now we can begin to work through the list of species in a for loop, getting the go-terms for all of their uniprot accessions. 
# This will involve the following steps (per species):
# 1) In parallel, submit N accessions for GO-term mapping (where accessions will be drawn from their index from 1:length(accessions)) and fill in a list by their index (where the list will be equal in length to the number of uniprot accessionskeyy)
# 2) This list (of dataframes) will then be combined into a single data frame using rlist::list.rbind(), and written to file. 

# Specify the fieldshat we would like to download. 
seqMeta <- 
    c('organism_name', 'organism_id', 'accession', 
    'protein_name', 'length', 'mass')

gos <- 
    c('go_p', 'go_c', 'go_f', 'go_id')
    
famDomains <- 
    c('xref_disprot','xref_ideal','xref_interpro',
    'xref_panther','xref_pirsf','xref_pfam',
    'xref_sfld','xref_supfam','xref_tigrfams')

ogDBs <- 
    c('xref_inparanoid','xref_orthodb','xref_phylomedb',
    'xref_treefam','xref_eggnog')

for(spp in spps){
    # Who are we working on?
    print(paste0("Working on ", spp, ". This is species ", which(spp == spps), " of ", length(spps), "."))

    # get the list of accessions for this species. 
    accessions <- read_tsv(paste0(idDir, spp, '-prot-ids.txt'), col_types = cols(), col_names = F)$X1

    # Get the species tax ID by pulling out into for the first accession
    taxID <- queryUniProt(paste0("accession:", accessions[1]), fields = 'organism_id')[[1]]
    # Pull down annotations for proteins in this species 
    up <- UniProt.ws(taxID)
    
    # And pull down annotations, removing rows for proteins without any annotations. 
    annots <- UniProt.ws::select(up, accessions, c(seqMeta, gos, famDomains, ogDBs), 'UniProtKB')
    toDrop <- which(rowSums(is.na(annots[,-c(1:2)])) == ncol(annots[,-c(1:2)]))
    if(length(toDrop) > 0){
        annots <- annots[-toDrop,]
    }
    colnames(annots) <- gsub("[.][.]", "_", colnames(annots)) %>% gsub("[.]", "_", .) %>% sub("_$", "", .)

    # Write out to a tsv.
    write.table(annots, file = paste0(annotDir, spp, '-Protein-Annotations.tsv'), col.names = T, row.names = F, sep = '\t', quote = F)
}
