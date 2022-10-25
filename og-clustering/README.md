# Orthogroup Clustering
### Scripts herein cluster proteins into orthogroups using MCL, based on all-v-all diamond-based e-value scores that are normalized to account for varying phylogenetic relatedness among species with Orthofinder. 
These scripts are presently drafts and were previously applied (in one form or another) to "The Comparative Set" of the EukProt database (V3: https://github.com/beaplab/EukProt).
I am currently in the process of updating these scripts for application to a revised dataset of 244 species of Eukaryotes.
Eventually we seek to build these components into a next-flow workflow to facilitate efficient distribution of computational demands/expenses across EC2 spot instances where possible. 

### A brief description of scripts is listed below. 
#### 1) run-orthofinder-diam-mcl-mafft-TCS.sh:
   -  This script was originally used to go from protein sequences -> all-v-all diamond -> orthogroups -> MSAs
   -  I intend to break this up, using nextflow to run the all-v-all comparisons, as nf-core modules exist that can implement this, and will likely make things happen much more quickly, and cost significantly less through the use of spot instances. 
    
#### 2) TestMCL-InflationParams-orthofinder.sh:
   -  This script was not extentively used previously.
   -  This will likely be reworked entirely into nexflow, but the goal here is to cluster proteins into orthogroups using a bunch of different MCL inflation parameters. 
   -  Then, we will (this part has not been written/done yet) assess how well each inflation parameter seems to perform, based on taxonomic inclusion of orthogroups, gene ontology conservation within orthogroups, correspondance to known orthology, etc. 

### How I envision the workflow for the process of clustering sequences into orthogroups and assessing their quality....
#### 1) nf-core diamond module:
   -  Distribute all pairwise (among species) all-v-all (among proteins) comparisons with diamond across spot-instances. 
   -  Output of these comparisons will be stored following the convention of OrthoFinder in a directory called "WorkingDirectory" with files named along the lines of "Blast0_0.txt.gz", "Blast0_1.txt.gz", etc. 
#### 2) nextflow custom module for mcl-clustering using different inflation parameters:
   - For computational and time efficiency (and to facilitate use of software described in the section below), this may just be applied to those species for which we downloaded proteins/proteomes from UniProt. 
   - I think we'll need to build this ourselves, as we're not just using MCL, but specifically the implementation in orthofinder that normalizes blast similarity scores to account for varying relatedness among species. 
   - So, some of the one-liner orthofinder commands from TestMCL-InflationParams-orthofinder.sh will be used here, and we can set the inflation parameter as a variable (as well as output name of course) - we will specify as input the directory containing the all-v-all diamond results.
   - You can specify the name of an output directory, but it will output inferred orthogroups to a subdirectory of the diamond output to the effect of "Orthofinder/Results_${SPECIFIED_OUTPUT}"
#### 3) Quantication/ranking performance of the inflation parameters:
   - This is less clearly worked out, but I suspect this will involve the use of either the R package "cogeqc" (https://almeidasilvaf.github.io/cogeqc/articles/vignette_02_assessing_orthogroup_inference.html), orthobench (https://github.com/davidemms/Open_Orthobench), or the Quest for Orthologs benchmarking service (https://orthology.benchmarkservice.org/proxy/).
   - Unfortunately the latter is probably our best bet, as it ties in neatly with our UniProt data, and is extensively curated. 
     - It's unfortunate only because I don't (at least yet) see a clear way to tie this into a nextflow workflow. 
