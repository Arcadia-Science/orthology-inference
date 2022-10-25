# Phylogenetic Inference (gene-family and species trees) 
### As with elsewhere, these scripts can be considered preliminary first drafts, although their core will be reimplemented into a full workflow.

## Scripts include:
1) IdentifyCoreOGs_All-SupGrps_MaxMean2-GeneCount.R:
    - Identifies orthogroups that include members of all Eukaryotic supergroups, and have at most a maximum mean gene-copy of 2.
    - Details of this are going to change, but some similar form of filtering will take place 
 
2) RunParGenes_ExtremeCoreGenes_RaxML.sh:
    - This uses ParGenes to parallelize the distribution of RAxML runs (tree inference) for all gene trees. 
    - This can probably be done better with nexflow, and I believe there are modules to do exactly that. Plus, I actually would prefer to use IQ-tree for gene-family tree inference (for reasons including increased inference speed).

3) RunSpeciesRax_ExtremeCoreOGs.sh:
    - Runs the species rax model, taking MSAs and the set of inferred gene trees above to infer a species tree, and then reconcile gene trees with that inferred species tree under a model of gene family gain, loss, and transfer. 
    - As is, the software infers the species tree without much parallelization at all, and then goes on to gene-tree species-tree reconciliation (for thousands of trees) with the same parallelization settings. 
    - So, I think we can run the species tree inference separately of gene-tree reconciliation, and do the latter in a high-throughput manner. 
