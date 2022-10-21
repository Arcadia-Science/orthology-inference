#!/bin/bash

# Navigate to the working directory
cd ../../../data/TNCS/

# Run CD-HIT on all of the Isoform-reduced transcriptome-derived proteomes
mkdir -p final-proteins

for p in $(ls ./iso-reduced-proteins/)
do
    spp=$(echo $p | sed "s/-IsoReduced.fasta//g")
    
    cd-hit -T 10 -l 20 -i ./iso-reduced-proteins/$p -o ./final-proteins/${spp}-clean-proteome.fasta
done

# and the lingering transcriptomes for which we couldn't remove redundant isoforms
while read spp
do
    cd-hit -T 10 -l 20 -i ./unfilt-proteins/$spp.fasta -o ./final-proteins/${spp}-clean-proteome.fasta
done < NonReduced-Prots-To-CD-HIT.txt

# Now we will work through the species for which proteomes are derived 
# from genomic data (i.e. we do not have a need to remove short isoforms, 
# nor a basis for redundancy reduction with CD-HIT) and drop out any proteins
# less than 20 AA long.

conda activate orthofinder
# Using seqkit to extract sequences of desired length
while read prots
do  
    spp=$(echo $prots | sed "s/_UniProtRefProteome//g" | sed "s/.fasta//g")
    
    echo "Working on ${spp}!"
    seqkit seq --threads 10 -t protein -m 20 ./unfilt-proteins/$prots -o ./final-proteins/$spp-clean-proteome.fasta
    echo "Done!"
done < SppToRemoveShortAA_GenomeDerivedProts.txt

# And non-reference proteomes from UniProt, or proteins downloaded from UniProtKb,
# but with a slightly relaxed threshold
# We'll throw away short sequences in the same command.  
while read spp
do
    f=$(ls ./unfilt-proteins/${spp}*)
    cd-hit -T 10 -c 0.95 -l 20 -i $f -o ./final-proteins/${spp}-clean-proteome.fasta
done < NonRef_GenomeProts_ToReduce.txt

# Move the clstr files to their own directory for everything is clean and tidy
mkdir -p cdhit-clstrs
mv ./final-proteins/*clstr cdhit-clstrs
