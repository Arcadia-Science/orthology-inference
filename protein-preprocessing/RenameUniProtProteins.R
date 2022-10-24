#!/env/Rscript

# This script is just a bit of final tidying up, renaming something descriptive,
# following the format: "Genus_species:ProteinID" - all additional information 
# will subsequently be retained. 
library(seqinr)

# formats for reference and non-reference proteomes from uniprot are the same,
# as are proteins downloaded from UniProtKb, so we'll combine them.
spps.up <- 
    c(gsub("_UniProtRefProteome.fasta", "", 
            list.files("./proteins/", 
            pattern = "UniProtRefProteome")),
      gsub("_UniProtProteome.fasta", "", 
        list.files("./proteins/", 
        pattern = "UniProtProteome")),
      gsub("_UniProtKbProteins.fasta", "", 
        list.files("./proteins/", 
        pattern = "UniProtKbProteins.fasta")))
        

# Begin with the species for which proteins were downloaded from uniprot. 
# These ones are the most straightforward to handle, as UniProtIDs are already
# in their sequence name
for(spp in 1:length(spps.up)){
    print(paste0("Working on ", spps.up[spp], "! This is species ", spp, " of ", length(spps.up), "."))
    # read in the species' fasta file
    fa <- read.fasta(file = paste0("./final-proteins/", spps.up[spp], "-clean-proteome.fasta"), 
                       seqtype = "AA", as.string = TRUE, set.attributes = TRUE)

    # rename these: Genus_species:ProteinID
    og.names <- names(fa)
    acc <- do.call('rbind', strsplit(as.character(og.names),'|',fixed=TRUE))[,2]
    names(fa) <- paste(spps.up[spp], acc, sep = ":")
   
    # And again, because seqinr strips all the additional details from the sequence name,
    # pull these out and combine with the names we just made
    for(i in 1:length(fa)){
        names(fa)[i] <- paste(names(fa)[i], gsub(">", "", attr(fa[[i]], 'Annot')))
    }
    write.fasta(sequences = fa, names = names(fa), 
                file.out = paste0("./final-proteins/", spps.up[spp], "-clean-proteome.fasta"))
}