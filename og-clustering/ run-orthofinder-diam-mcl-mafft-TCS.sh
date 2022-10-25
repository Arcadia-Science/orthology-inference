#!/bin/bash
conda activate orthofinder
export PATH="/home/ubuntu/miniconda3/envs/orthofinder/bin/:$PATH"

# Run inital parts of the orthofinder pipeline, taking proteome sequences, conducting 
# all-v-all sequence comparisons using diamond ultra sensitive, clustering proteins 
# into orthogroups using MCL, inferring multiple sequence alignments with MAFFT,
# and stopping there (specified by the "oa" flag) 

orthofinder -t 62 -a 16 -oa  \
-S diamond_ultra_sens -M msa -n EukProt_Proteins \
-f ~/environment/data/EukProt/TCS/data/proteins/ \
-o ~/environment/analyses/orthofinder/TCS/

# Now, once orthofinder has finished running, whether successfully or otherwise,
# stop (not terminate!) the instance. Because we need to run this for a long,
# but indeterminate length of time, we can't specify a period of inactivity after
# which to stop the instance. So, we're going to hard-code a stop. With any
# luck, this should mean that we can run orthofinder for however long it takes
# to finish, and then stop the instance afterwards, so we're not needlessly 
# spending money on compute. 

# To do so, we first need to get the instance ID - do so with the following 
# command to store as a variable:
id=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)

# Now stop the instance
echo "Stopping the instance - hopefully orthofinder finished running without error!"
aws ec2 stop-instances --instance-ids $id

