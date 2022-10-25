#!/bin/bash

conda activate orthofinder

# Store some paths as variables to make things more legible
pgDir=/home/ubuntu/environment/software/ParGenes
pargenes=$pgDir/pargenes/pargenes.py 
msaDir=/home/ubuntu/environment/analyses/four-spp-ogs-init/TCS/og-trimmed-msas
treeDir=/home/ubuntu/environment/analyses/four-spp-ogs-init/TCS/og-starting-trees
pgOut=/home/ubuntu/environment/analyses/pargenes/EukProt_TCS_ExtremeCoreOGs

# pull out the 'core set' of orthogroups, that include all taxonomic 
# supergroups, and have at most a mean gene-copy (per species) of 2, 
# storing them in their own subdirectory
if [ ! -d ./extr-core-og-trimmed-msas ]
then
    # If we haven't done so yet, create the directories (MSAs and trees)
    mkdir extr-core-og-trimmed-msas

    # Read in the list of core orthogroups
    ogs=$(cut -f1 /home/ubuntu/environment/analyses/orthofinder/TCS/Results_EukProt_Proteins/CoreOGs_All-SupGrps_MaxMean2-GeneCount-NoHeader.tsv)
    
    # And start copying the MSAs over here. 
    for og in $ogs
    do
        cp $msaDir/$og-clipkit.fa ./extr-core-og-trimmed-msas/
    done
fi

# update the paths for the msas
msaDir=extr-core-og-trimmed-msas

$pargenes -a $msaDir -o $pgOut -d aa --seed 1234 --cores 124 -b 0 --continue \
--raxml-global-parameters-string "--model LG+G4+F --tree pars{1}"

