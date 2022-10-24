#!/bin/bash
# The following script will, for each species in the new comparative set for 
# which proteins are derived from transcriptomic sequences and for which
# we may distinguish alternative isoforms:
# 1) pull out the fields relevant to gene and constituent protein/isoform name
# 2) spit these out to a file

# Subsequently we will work through these, using an R script to extract the 
# names of these proteins to retain, and then use these to extract the 
# protein sequences, spitting them into a new fasta file. 

# Because there a bunch of different formats of transcript/protein names,
# we unfortunately have to do these in batches, using a bit of trickery for each. 
# In several cases, we can generalize this so as to find what we need from 
# the bespoke sequence name formats, and strip away everything else.

# Navigate to the working directory
cd ../../../data/TNCS/

# Make a directory to hold the isoform-reduced proteomes
mkdir -p ProteinFilteringIntermediates

# Lets begin. Well work though a file that lists species (first column) 
# and the format we'll use to extract the longest isoform (second column).
while read species
do 
    spp=$(echo $species | cut -f1 -d" ")
    format=$(echo $species | cut -f2 -d" ")
    
    if [ "$format" == "Trinity" ]; then
        grep ">" ./unfilt-proteins/${spp}.fasta | cut -f2 -d' ' | cut -f3 -d":" | sed "s/_Nuclearia.*//g" | sed "s/_m.*//g" > prots
        sed "s/_[^_]*$//g" prots | sed "s/.p.*//g" > genes

    elif [ "$format" == "TransDecoder" ]; then
        grep ">" ./unfilt-proteins/${spp}.fasta | sed "s/.*comp/comp/g" | sed "s/:.*//g" > prots
        sed "s/_[^_]*$//g" prots > genes
    
    elif [ "$format" == "PipeSeparated" ]; then
        grep ">" ./unfilt-proteins/${spp}.fasta | cut -f2,3 -d"|" | cut -f1 -d" " > prots
        sed "s/.[^.]*$//g" prots > genes
        
    elif [ "$format" == "MMETS" ]; then
        grep ">" ./unfilt-proteins/${spp}.fasta | cut -f2 -d"=" | cut -f1 -d" " > prots
        sed "s/_[^_]*$//g" prots > genes

    fi
    
    # Combine
    paste ProtLengths/$spp-ProtLengths.txt genes prots > ProteinFilteringIntermediates/$spp-ProtLens.txt
    rm prots genes
done < IsoformReductionList.txt

# Now deal with the odds and ends that don't match the patterns above
grep ">" ./unfilt-proteins/EP00126_Sphaerothecum_destruens.fasta | cut -f2 -d" " | sed 's/\(.*\)m.*/\1/' > prots
sed "s/_seq.*//g" prots > genes
paste ProtLengths/EP00126_Sphaerothecum_destruens-ProtLengths.txt genes prots > ProteinFilteringIntermediates/EP00126_Sphaerothecum_destruens-ProtLens.txt
rm prots genes
    
grep ">" ./unfilt-proteins/EP00762_Andalucia_godoyi.fasta | cut -f2 -d" " > prots
sed "s/\..*//g" prots > genes
paste ProtLengths/EP00762_Andalucia_godoyi-ProtLengths.txt genes prots > ProteinFilteringIntermediates/EP00762_Andalucia_godoyi-ProtLens.txt
rm prots genes
    
grep ">" ./unfilt-proteins/EP00770_Monocercomonoides_exilis.fasta | cut -f2 -d"|" | sed "s/ //g" | sed "s/transcript=//g" > prots
sed "s/\..*//g" prots > genes
paste ProtLengths/EP00770_Monocercomonoides_exilis-ProtLengths.txt genes prots > ProteinFilteringIntermediates/EP00770_Monocercomonoides_exilis-ProtLens.txt
rm prots genes

grep ">" ./unfilt-proteins/EP00820_Chromera_velia.fasta | cut -f2 -d"|" | sed "s/ //g" | sed "s/transcript=//g" > prots
sed "s/\..*//g" prots > genes
paste ProtLengths/EP00820_Chromera_velia-ProtLengths.txt genes prots > ProteinFilteringIntermediates/EP00820_Chromera_velia-ProtLens.txt
rm prots genes

grep ">" ./unfilt-proteins/EP00873_Tetraselmis_striata.fasta | cut -f4 -d"|" > prots
sed "s/.t.*//g" prots > genes 
paste ProtLengths/EP00873_Tetraselmis_striata-ProtLengths.txt genes prots > ProteinFilteringIntermediates/EP00873_Tetraselmis_striata-ProtLens.txt
rm prots genes

grep ">" ./unfilt-proteins/EP00158_Paraphelidium_tribonemae.fasta | cut -f2 -d" " > prots
sed "s/_i.*//g" prots > genes
paste ProtLengths/EP00158_Paraphelidium_tribonemae-ProtLengths.txt genes prots > ProteinFilteringIntermediates/EP00158_Paraphelidium_tribonemae-ProtLens.txt
rm prots genes

grep ">" ./unfilt-proteins/EP00741_Cyanophora_paradoxa.fasta | cut -f2 -d" " > prots 
sed "s/.t.*//g" prots > genes
paste ProtLengths/EP00741_Cyanophora_paradoxa-ProtLengths.txt genes prots > ProteinFilteringIntermediates/EP00741_Cyanophora_paradoxa-ProtLens.txt
rm prots genes
