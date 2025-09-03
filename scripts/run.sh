#!/bin/bash
#SBATCH --job-name=ocr
#SBATCH --nodes=1
#SBATCH --time=00:30:00
#SBATCH --cpus-per-task=48
#SBATCH --mem=96gb
#SBATCH --output=./SLURM_logs/ocr_%j.out
#SBATCH --error=./SLURM_logs/ocr_%j.err
#SBATCH --account=rcc-staff
##SBATCH --mail-type=END
#SBATCH --mail-user=hyadav@rcc.uchicago.edu

# Print SLURM job information
echo "=========================================="
echo "SLURM Job Information"
echo "=========================================="
echo "Job ID: $SLURM_JOB_ID"
echo "Job Name: $SLURM_JOB_NAME"
echo "Node List: $SLURM_JOB_NODELIST"
echo "Number of Nodes: $SLURM_JOB_NUM_NODES"
echo "CPUs per Task: $SLURM_CPUS_PER_TASK"
echo "Memory per Node: $SLURM_MEM_PER_NODE"
echo "Partition: $SLURM_JOB_PARTITION"
JOB_TIME_LIMIT=$(squeue -j $SLURM_JOB_ID -h --Format TimeLimit)
echo "Time Limit: $JOB_TIME_LIMIT"
echo "Working Directory: $SLURM_SUBMIT_DIR"
echo "Start Time: $(date)"
echo "=========================================="
echo ""

module load python/miniforge-25.3.0
module load gcc/13.2.0

source activate kraken_env

# Set library path
export LD_LIBRARY_PATH=/project/rcc/hyadav/lipvips-8.18.0/lib64:$LD_LIBRARY_PATH

# Set pkg-config path 
export PKG_CONFIG_PATH=/project/rcc/hyadav/lipvips-8.18.0/lib64/pkgconfig:$PKG_CONFIG_PATH

MODEL_PATH="../models/dillard.mlmodel"
OUTPUT_DIR="../data/CAD/predictions"

# Extract the model name without the extension
MODEL_NAME=$(basename "$MODEL_PATH" | cut -d. -f1)

# Create a directory for each model
MODEL_PREDICTIONS_DIR="$OUTPUT_DIR/$MODEL_NAME"

# Check if the directory exists
if [ -d "$MODEL_PREDICTIONS_DIR" ]; then
  echo "Directory already exists: $MODEL_PREDICTIONS_DIR"
else
  # If it doesn't exist, create it
  mkdir -p "$MODEL_PREDICTIONS_DIR"
  echo "Created directory: $MODEL_PREDICTIONS_DIR"
fi

INPUT_DIR="/project/rcc/hyadav/CuReD/data/CAD/split_pages"

# Run kraken OCR on each page
for page in {37..43}; do
    echo "Processing page $page"
    kraken -i "$INPUT_DIR/page-$(printf "%03d" $page).png" $MODEL_PREDICTIONS_DIR/page-$(printf "%03d" $page).txt binarize segment ocr -m $MODEL_PATH
done

echo "All pages processed!"

