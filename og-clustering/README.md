# Orthogroup Clustering
### Scripts herein cluster proteins into orthogroups using MCL, based on all-v-all diamond-based e-value scores that are normalized to account for varying phylogenetic relatedness among species with Orthofinder. 
These scripts are presently drafts and were previously applied (in one form or another) to "The Comparative Set" of the EukProt database (V3: https://github.com/beaplab/EukProt).
I am currently in the process of updating these scripts for application to a revised dataset of 244 species of Eukaryotes.
Eventually we seek to build these components into a next-flow workflow to facilitate efficient distribution of computational demands/expenses across EC2 spot instances where possible. 

### A brief description of scripts is listed below. 
#### 1) TestMCL-InflationParams-orthofinder.sh:
  -  This will likely be reworked into nexflow, but the goal here is to cluster proteins into orthogroups using a bunch of different MCL inflation parameters. 
  -  Then, we will (this part has not been written/done yet) assess how well each inflation parameter seems to perform, based on taxonomic inclusion of orthogroups, gene ontology conservation within orthogroups, correspondance to known orthology, etc. 
