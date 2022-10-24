#!/bin/bash
conda activate orthofinder
export PATH="/home/ubuntu/miniconda3/envs/orthofinder/bin/:$PATH"

# Test the impact of different MCL inflation parameter (-I) 
# values on orthogroup size/membership. Just run the analyses. 
# Summarize elsewhere. 
blastDir=/home/ubuntu/environment/analyses/orthofinder/TCS/Results_EukProt_Proteins/WorkingDirectory/
baseOut=/home/ubuntu/environment/analyses/orthofinder/TCS/MCL_OG_Tests

cd $baseOut && orthofinder -b $blastDir -t 92 -a 92 -I 0.50 -n Inflation_0.50 -og 
cd $baseOut && orthofinder -b $blastDir -t 92 -a 92 -I 0.70 -n Inflation_0.70 -og
cd $baseOut && orthofinder -b $blastDir -t 92 -a 92 -I 0.90 -n Inflation_0.90 -og
cd $baseOut && orthofinder -b $blastDir -t 92 -a 92 -I 1.10 -n Inflation_1.10 -og
cd $baseOut && orthofinder -b $blastDir -t 92 -a 92 -I 1.30 -n Inflation_1.30 -og
cd $baseOut && orthofinder -b $blastDir -t 92 -a 92 -I 1.70 -n Inflation_1.70 -og
cd $baseOut && orthofinder -b $blastDir -t 92 -a 92 -I 1.90 -n Inflation_1.90 -og
cd $baseOut && orthofinder -b $blastDir -t 92 -a 92 -I 2.10 -n Inflation_2.10 -og
cd $baseOut && orthofinder -b $blastDir -t 92 -a 92 -I 2.30 -n Inflation_2.30 -og
cd $baseOut && orthofinder -b $blastDir -t 92 -a 92 -I 2.50 -n Inflation_2.50 -og

mv $blastDir/Orthofinder/Results_Inflation_0.50 .
mv $blastDir/Orthofinder/Results_Inflation_0.70 .
mv $blastDir/Orthofinder/Results_Inflation_0.90 .
mv $blastDir/Orthofinder/Results_Inflation_1.10 .
mv $blastDir/Orthofinder/Results_Inflation_1.30 .
mv $blastDir/Orthofinder/Results_Inflation_1.70 .
mv $blastDir/Orthofinder/Results_Inflation_1.90 .
mv $blastDir/Orthofinder/Results_Inflation_2.10 .
mv $blastDir/Orthofinder/Results_Inflation_2.30 .
mv $blastDir/Orthofinder/Results_Inflation_2.50 .


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
