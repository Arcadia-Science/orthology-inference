## Code in this directory is used to pre-process protein sequences download from a diversity of different sources
#### Additional lists of samples/species used by these scripts in included. 
- Note that I've made efforts to automate the process as much as possible. But, given the large number of species (244) used here, and the diversity of formats (with respect to sequence naming convention) and data sources (everything from transcriptomes with/without alternative isoforms to UniProt reference proteomes with one protein per-gene), automation was not always possible. 
- Below is a description of their scripts, and of the order in which they should be run. 

# Scripts:

# Sample lists:
1) IsoformReductionList.txt:
  - Two tab-separated columns. Column 1 is corresponds to a fasta file (one per species), and the second column indicates the format of the protein/transcript sequences. 
  - There were four formats that I could readily 'stereotype' to facilitate automated transcript renaming, although there are exceptions.
