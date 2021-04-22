#!/bin/bash

# Job Name
#SBATCH --job-name=viraltrack
# Resources, ... and one node with 4 processors:
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=64000
#SBATCH --time=12:00:00
#SBATCH --mail-user=eleanor.fewings@bioquant.uni-heidelberg.de


################
## Find tools ##
################

# Source bashrc
source ~/.bashrc

# Load conda environment and look for snaptools and bwa
if [[ ! -z ${conda}  ]]; then
  conda activate ${conda}
else
  echo "Please supply a conda environment with -c flag."
  helpFunction
  abort
fi

r1="${base}/Viral_Track_scanning_modified3.R"
r2="${base}/Viral_Track_transcript_assembly.R"
r3="${base}/Viral_Track_cell_demultiplexing.R"

############################
## Extract from whitelist ##
############################

# Create whitelist
gunzip -c ${barcodes} | sed 's/-1//g' > "${outdir}/whitelist.tsv"

# Set new fastq names
f1out=$(basename $(echo ${f1} | sed 's+.fastq.gz+.extracted.fastq.gz+'))
f2out=$(basename $(echo ${f2} | sed 's+.fastq.gz+.extracted.fastq.gz+'))

# Extract
umi_tools extract --bc-pattern=CCCCCCCCCCCCCCCCNNNNNNNNNNNN --stdin=${f1} --stdout=${outdir}/${f1out} --read2-in=${f2} --read2-out=${outdir}/${f2out} --filter-cell-barcode --whitelist="${outdir}/whitelist.tsv" &>> ${log}

#Write new to 'files to process' file
echo "${outdir}/${f2out}" > "${outdir}/files_to_process.txt"

####################
## Run Viraltrack ##
####################

#Run viral track scanning
Rscript ${r1} ${params} "${outdir}/files_to_process.txt" &>> ${log}

#Align data
Rscript ${r2} ${params} "${outdir}/files_to_process.txt" &>> ${log}

#Demultiplex
Rscript ${r3} ${params} "${outdir}/files_to_process.txt" &>> ${log}


