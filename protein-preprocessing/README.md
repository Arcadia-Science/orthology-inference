## Code in this directory is used to pre-process protein sequences download from a diversity of different sources
#### Additional lists of samples/species used by these scripts in included. 
- Note that I've made efforts to automate the process as much as possible. But, given the large number of species (244) used here, and the diversity of formats (with respect to sequence naming convention) and data sources (everything from transcriptomes with/without alternative isoforms to UniProt reference proteomes with one protein per-gene), automation was not always possible. 
- Below is a description of their scripts, and of the order in which they should be run. 

# Scripts:
## 1) GetProtLengths-Commands.txt:
  - This technically is a list of commands that calculates the length of each protein in each unfiltered dataset. This protein length information is used downstream.
  - I haven't written a script to run run, but I just used gnu-parallel to run 10 (or however many parallel threads you'd like) simultaneously
    - for example: parallel -j 10 < GetProtLengths-Commands.txt
## 2) GetIsoformLength.sh:
  - For all protein-sets derived from transcriptomes, and for which sequence names enable identification of alternative isorforms for each assembled 'gene', parses gene number, isoform number, and isoform length. 
  - This produces a table that is used in the following script. It works though the sample list "IsoformReductionList.txt", which is described below. 
## 3) ExtractLongestIsoFasta.R:
  - This script goes through, for each species we analyzed in the step above, and pulls out/writes a fasta file comprised of the longest isoform/protein product for each gene in the original, unfiltered proteomes. 
  - In the process, it excludes any sequence shorter than 20 AA long. 
## 4) CDHIT-FinalizeTranscriptomes.sh:
  - This script performs a number of functions, but in general finalizes all proteomes for downstream analyses. Steps include....
    - Running CD-HIT (global similarity threshold (-c 0.90) of 90%) on all proteomes for which we have reduced down to the longest isoform/protein product per-gene. 
    - Running CD-HIT (global similarity threshold (-c 0.90) of 90%) on all proteomes for which the original source was a transcriptome, but we were unable to parse alternative isoforms.
    - Running CD-HIT (global similarity threshold (-c 0.95) of 95%) on all non-reference (i.e. UniProt Reference) proteomes for which the original source was a genome, and we could not ensure we had only a single protein per-gene. 
    - Removal of any sequence < 20 AA long for all proteomes, including reference proteomes.
## 6) RenameUniProtProteins.R:
  - For all proteomes obtained from UniProt, renamed protein sequences to facilitate downstream use. 
  - All protein sequences follow the format of "Genus_species:UniProtAccession"
## 7) Clean_Nstella_Transcriptome.sh:
  - The script is pretty heavily annotated, and is very much so specific in its use case...
  - But, this takes the transcriptome and annotation data from the dryad repository of Gomaa et al., 2021 (https://doi.org/10.1126/sciadv.abf1586) and does a number of extensive filtering steps. 
  - First, it extracts the transcriptome assembly corresponding to the wild-caught control from the concatenated assembly (which includes 5 assemblies corresponding to different treatments). 
  - Then, sequence names are corresponded back to the original trinity sequence names, which are used to extract the longest isoform/protein product per assembled gene. 
  - All sequences < 20 AA long are removed.
  - Protein redundancy is reduced using CD-HIT, with a global similarity threshold of 0.9 (90%). 


# Sample lists:
## 1) UtilLists/IsoformReductionList.txt:
  - Two tab-separated columns. Column 1 is corresponds to a fasta file (one per species), and the second column indicates the format of the protein/transcript sequences. 
  - There were four formats that I could readily 'stereotype' to facilitate automated transcript renaming, although there are exceptions.
## 2) NonReduced-Prots-To-CD-HIT.txt:
  - Specifies the transcriptomes for which we could not distinguish alternative isoforms, but for which we need to apply CD-HIT with a global similarity threshold of 0.9. Used by "CDHIT-FinalizeTranscriptomes.sh"
## 3) SppToRemoveShortAA_GenomeDerivedProts.txt:
  - Specifies UniProt Reference proteomes for which we need to remove any amino acid < 20 AA long. Used by "CDHIT-FinalizeTranscriptomes.sh"
## 4) NonRef_GenomeProts_ToReduce.txt:
  - Specifies non-reference genome-derived proteomes for which we suspect there may be multiple protein products per gene. CD-Hit is applied to these, with a global similarty threshold of 0.95. Used by "CDHIT-FinalizeTranscriptomes.sh"
