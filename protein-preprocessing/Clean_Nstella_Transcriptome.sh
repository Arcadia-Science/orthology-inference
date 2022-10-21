#!/bin/bash
conda activate orthofinder

# Navigate to the working directory
cd ../../../data/TNCS/

# Nonionella stella's proteome was originally derived from multiple transcriptomes, each under different experimental treatments
# This led there to be a large (massive (> 300,000) number of retained transcripts, even after filtering for redundancy. 
# So, let's focus just on the control - transcriptomes assembled from samples collected "shipside" - basically just "wild-caught" samples. 

# Pull out the info for each transcript, including the ID used in the original concatenated transcriptome file in the firstr column,
# as well as the orginal Trinity name of these transcripts - we can use this to retain the longest isoform per constructed gene.
grep "TRINITY_shipcontrol" ./Nstella_Transcriptomes/NstellaConcatTrinityAll-genecalls.txt  > ./Nstella_Transcriptomes/Control_GeneIDs_GeneCalls.txt
cut -f1 ./Nstella_Transcriptomes/Control_GeneIDs_GeneCalls.txt > ./Nstella_Transcriptomes/targets.txt

# Use the transcript start and end points to calculate the length of each transcript and add this as a column
awk 'BEGIN { OFS = "\t" } NR == 1 { $5 = "diff." } NR >= 3 { $9 = $4 - $3 } 1' < ./Nstella_Transcriptomes/Control_GeneIDs_GeneCalls.txt > tmp
mv tmp ./Nstella_Transcriptomes/Control_GeneIDs_GeneCalls.txt

# Take the trinity transcript names, strip the isoform identifier to come up with uniqe gene names, and add that as a column. 
cut -f2 ./Nstella_Transcriptomes/Control_GeneIDs_GeneCalls.txt | sed "s/_i.*//g" > ./Nstella_Transcriptomes/genes
paste ./Nstella_Transcriptomes/Control_GeneIDs_GeneCalls.txt ./Nstella_Transcriptomes/genes > ./Nstella_Transcriptomes/tmp 
mv ./Nstella_Transcriptomes/tmp ./Nstella_Transcriptomes/Control_GeneIDs_GeneCalls.txt
rm ./Nstella_Transcriptomes/genes

# Loop through genes, pulling out/retaining only the longest isoform per unique assembled gene.
for g in $(cut -f10 ./Nstella_Transcriptomes/Control_GeneIDs_GeneCalls.txt | sort -h | uniq)
do
    # Pull out the focal gene
    grep -w $g ./Nstella_Transcriptomes/Control_GeneIDs_GeneCalls.txt > ./Nstella_Transcriptomes/gene.prots

    # Sort by length, and spit out the longest protein for that gene
    sort -k9 -n ./Nstella_Transcriptomes/gene.prots | tail -1 | cut -f2 >> ./Nstella_Transcriptomes/longest.prots
    
    # clean up
    rm ./Nstella_Transcriptomes/gene.prots
done

# Build a new file of just the longest proteins (isoforms) per gene, keeping both the orginal protein identifier used in the original assembly,
# and the original trinity transcript name
grep -wf ./Nstella_Transcriptomes/longest.prots ./Nstella_Transcriptomes/Control_GeneIDs_GeneCalls.txt | cut -f1 > ./Nstella_Transcriptomes/longest.prots.ids
paste ./Nstella_Transcriptomes/longest.prots.ids ./Nstella_Transcriptomes/longest.prots > ./Nstella_Transcriptomes/genes

# Now use these to pull out the actual amino acid sequences, building a new fasta file of these peptides.
grep -A1 -f ./Nstella_Transcriptomes/longest.prots.ids ./Nstella_Transcriptomes/gene-calls-NstellaConcatTrinityAll.faa > ./Nstella_Transcriptomes/Nonionella_stella_control_transcripts.fasta
sed "s/\-\-//g" ./Nstella_Transcriptomes/Nonionella_stella_control_transcripts.fasta | sed "/^$/d" > tmp && mv tmp ./Nstella_Transcriptomes/Nonionella_stella_control_transcripts.fasta

# Rename the protein sequences to their actual transcript names, since these are more informative. 
while read line
do 
    id=$(echo $line | cut -f1 -d" ") 
    trans=$(echo $line | cut -f2 -d" ")
    sed -i "s/${id}_1/Nonionella_stella-${id}_1 $trans/g" ./Nstella_Transcriptomes/Nonionella_stella_control_transcripts.fasta
done < ./Nstella_Transcriptomes/genes

# Add the "_1" string to the protein identifier to match the ID used in the annotation table
sed -i -e 's/$/_1/g' ./Nstella_Transcriptomes/longest.prots.ids

# And use these to then pull out eggnog annotations for these longest proteins, including the header
head -n4 ./Nstella_Transcriptomes/NstellaConcat_eggnog.emapper.annotations > ./Nstella_Transcriptomes/Nonionella_stella_control_LongProt_eggnog.emapper.annotations
grep -wf ./Nstella_Transcriptomes/longest.prots.ids ./Nstella_Transcriptomes/NstellaConcat_eggnog.emapper.annotations >> ./Nstella_Transcriptomes/Nonionella_stella_control_LongProt_eggnog.emapper.annotations

# Use CD-HIT to try and reduce the (still significant) redundancy - there are still more than 80,000 proteins retained!
cd-hit -T 10 -l 20 -i ./Nstella_Transcriptomes/Nonionella_stella_control_transcripts.fasta -o ./final-proteins/Nonionella_stella-clean-proteome.fasta
mv ./final-proteins/*clstr cdhit-clstrs 

# Create a file we can use to incorporate the original eukprot IDs for these proteins
paste ../TNCS/Nstella_Transcriptomes/longest.prots ../TNCS/Nstella_Transcriptomes/longest.prots.ids > ../TNCS/Nstella_Transcriptomes/LongestProts_NameIDs.txt

# Reduce down to the ones included after using CD-HIT
grep ">" ./final-proteins/Nonionella_stella-clean-proteome.fasta | sed "s/>//g" > og.ids
grep -wf og.ids ../TNCS/Nstella_Transcriptomes/LongestProts_NameIDs.txt | cut -f2 > keep.ep.ids

# Now go ahead and pull these protein names out, building new sequence headers
grep ">" unfilt-proteins/EP01083_Nonionella_stella.fasta | sed "s/>//g" > ../TNCS/Nstella_Transcriptomes/Nstella_EP_ProtNames.txt
grep -f keep.ep.ids ../TNCS/Nstella_Transcriptomes/Nstella_EP_ProtNames.txt > ep.ids && rm keep.ep.ids
paste -d" " ep.ids og.ids > tmp && mv tmp ../TNCS/Nstella_Transcriptomes/Nstella_EP_ProtNames.txt
rm ep.ids og.ids

# Now go through and rename. Again, pretty inefficient, but it'll get the
# job done for this one instance. 
while read new 
do 
    og=$(echo $new | cut -f3 -d" ")
    sed -i "s/$og/$new/g" ./final-proteins/Nonionella_stella-clean-proteome.fasta
done < ../TNCS/Nstella_Transcriptomes/Nstella_EP_ProtNames.txt