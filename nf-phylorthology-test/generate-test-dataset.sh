#!/bin/bash

# This script generates a very pared down dataset to test out/workshop the 
# nextflow workflow. 
# It will be comprised of a handful (9) of species broadly sampled across the 
# eukaryotic tree of life and one Lokiarchaeota, and include genes from gene 
# families known to be shared across this broad range. Additionally 100 random
# genes will be sampled.

# Initialize directories
mkdir -p ../../../data/nf-test/
mkdir -p ../../../data/nf-test/final-proteins/

# Now pull out our focal species
cd ../../../data/nf-test/final-proteins/

# Begin by making a list of these species.
spp="Diacronema_lutheri Entamoeba_histolytica Giardia_intestinalis Loa_loa Lokiarchaeota_archaeon Porphyridium_purpureum Saccharomyces_cerevisiae Thecamonas_trahens Toxoplasma_gondii"

# Now create new fastas that include these. 
# Note that these matches won't be perfect/completely precise - that's 
# okay, even good for our purpose here.
for f in $spp
do 
    grep ">" ../../TNCS/final-proteins/${f}* | grep --ignore-case "elf" > tmp
    grep -A1 -f tmp ../../TNCS/final-proteins/${f}* >> ${f}-test-proteome.fasta
    
    grep ">" ../../TNCS/final-proteins/${f}* | grep --ignore-case "actin" > tmp
    grep -A1 -f tmp ../../TNCS/final-proteins/${f}* >> ${f}-test-proteome.fasta
    
    grep ">" ../../TNCS/final-proteins/${f}* | grep --ignore-case "RPC" > tmp
    grep -A1 -f tmp ../../TNCS/final-proteins/${f}* >> ${f}-test-proteome.fasta
    
    grep ">" ../../TNCS/final-proteins/${f}* | grep --ignore-case "RPB" > tmp
    grep -A1 -f tmp ../../TNCS/final-proteins/${f}* >> ${f}-test-proteome.fasta
    
    grep ">" ../../TNCS/final-proteins/${f}* | grep --ignore-case "gelsolin" > tmp
    grep -A1 -f tmp ../../TNCS/final-proteins/${f}* >> ${f}-test-proteome.fasta
    
    grep ">" ../../TNCS/final-proteins/${f}* | grep --ignore-case "ESCRT" > tmp
    grep -A1 -f tmp ../../TNCS/final-proteins/${f}* >> ${f}-test-proteome.fasta
    
    grep ">" ../../TNCS/final-proteins/${f}* | grep --ignore-case "gtpase" > tmp
    grep -A1 -f tmp ../../TNCS/final-proteins/${f}* >> ${f}-test-proteome.fasta

    grep ">" ../../TNCS/final-proteins/${f}* | grep --ignore-case "zinc finger" > tmp
    grep -A1 -f tmp ../../TNCS/final-proteins/${f}* >> ${f}-test-proteome.fasta
    
    grep ">" ../../TNCS/final-proteins/${f}* | grep --ignore-case "ubiquitin-like" > tmp
    grep -A1 -f tmp ../../TNCS/final-proteins/${f}* >> ${f}-test-proteome.fasta
    
    grep ">" ../../TNCS/final-proteins/${f}* | grep --ignore-case "ATP-binding" > tmp
    grep -A1 -f tmp ../../TNCS/final-proteins/${f}* >> ${f}-test-proteome.fasta
    
    # And remove the "--" that get introduced by grep
    sed -i '/\-\-/d' ${f}-test-proteome.fasta
    rm tmp
done