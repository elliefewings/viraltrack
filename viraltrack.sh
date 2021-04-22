#!/bin/bash


# Set abort function
abort()
{
    echo "Uh oh. An error occurred."
    echo ""
    echo "Exiting..."
    exit 2
}

trap 'abort' SIGINT SIGTERM

set -e

# Set help function
helpFunction()
{
  echo ""
  echo "Program: Viraltrack"
  echo ""
  echo "Version: 0.1"
  echo ""
  echo "Usage: ./viraltrack.sh -f <R1 input fastq> -r <R2 input fastq> -p <parameters.txt> -b <cellranger barcodes file> -c <conda environment> -o <output location>[optional] -h <help>"
  echo ""
  echo "Options:"
      echo -e "\t-f\tFastq1: R1 input fastq file [required]"
      echo -e "\t-r\tFastq2: R2 input fastq file [required]"
      echo -e "\t-p\tParamters file: parameters file for viraltrack (see viraltrack documentation) [required]"
      echo -e "\t-b\tBarcodes file: cellranger barcodes.tsv.gz file [required]"
      echo -e "\t-c\tConda environment: Conda environment containing viraltrack dependencies [required]"
      echo -e "\t-o\tOutput directory: Path to output directory [default=$HOME]"
      echo -e "\t-h\tHelp: Does what it says on the tin"
  echo ""
}

# Set default output location
output="$HOME"

# Accept arguments specified by user
while getopts "f:r:p:b:c:o:h" opt; do
  case $opt in
    f ) f1="$OPTARG"
    ;;
    r ) f2="$OPTARG"
    ;;
    p ) params="$OPTARG"
    ;;
    b ) barcodes="$OPTARG"
    ;;
    c ) conda="$OPTARG"
    ;;
    o ) output="$OPTARG"
    ;;
    h ) helpFunction ; exit 0
    ;;
    * ) echo "Incorrect arguments" ; helpFunction ; abort
    ;;
  esac
done

# Check minimum number of arguments
if [ $# -lt 4 ]; then
  echo "Not enough arguments"
  helpFunction
  abort
fi

# Create directory for log and output
if [[ -z ${output} ]]; then
    outdir="${HOME}/viraltrack_output_$(date +%Y%m%d)"
else
    outdir="${output}/viraltrack_output_$(date +%Y%m%d)"
fi

# Make output dir
mkdir -p ${outdir}

# Set log
log="${outdir}/viraltrack.log.txt"

# Find R scripts
base=$(dirname "$0")

#Submit to cluster
sbatch --export=f1=${f1},f2=${f2},params=${params},barcodes=${barcodes},outdir=${outdir},log=${log},conda=${conda},base=${base} "${base}/slurm/slurm_viraltrack.sh"
