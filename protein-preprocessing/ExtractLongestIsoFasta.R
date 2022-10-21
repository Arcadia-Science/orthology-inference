#!/env/Rscript
library(seqinr)

# Navigate to the working directory
setwd('../../../data/TNCS/')

# For each species, read in the protein info (designated as either 
# isoform/gene and length), and identify the longest isoform for each gene,
# excluding proteins < 20 AA long. 
dir.create('iso-reduced-proteins', showWarnings = F)

fs <- list.files('./ProteinFilteringIntermediates/')

for(f in 1:length(fs)){
    prots <- read.table(paste0('./ProteinFilteringIntermediates/', fs[f]))
    spp <- gsub("-ProtLens.txt", "", fs[f])
    
    print(paste0("Working on ", spp, "!"))
    # Drop out short proteins
    if(min(prots[,2]) < 20){
     prots <- prots[-which(prots[,2] < 20),]   
    }
    
    genes <- unique(prots[,3])
    
    # Now, identify for each gene, which protein is longest
    longestProts <- by(prots, prots$V3, function(X) X[which.max(X$V2),])
    longestProts <- do.call("rbind", longestProts)[,1]
    
    # read in the species' fasta file
    fa <- read.fasta(file = list.files(path = "./proteins/", pattern = spp, full.names=T), 
                       seqtype = "AA", as.string = TRUE, set.attributes = TRUE)
    
    # Pull out the proteins we're keeping, and write out
    final.fa <- fa[names(fa) %in% longestProts]
    for(i in 1:length(final.fa)){
        names(final.fa)[i] <- gsub(">", "", attr(final.fa[[i]], 'Annot'))
    }
    
    write.fasta(sequences = final.fa, names = names(final.fa), file.out = paste0('iso-reduced-proteins/', spp, '-IsoReduced.fasta'))
    print("###############")
    print("#### Done! ####")
    print("###############")
    print("               ")
}
