#!/bin/bash
#SBATCH --partition=admintest
#SBATCH --time=00:10:00
#SBATCH --mem=1G
#SBATCH --output=pipeline.out

module load snakemake
snakemake -j2 \
  --executor slurm \
  --latency-wait 30 \
  --default-resources slurm_partition=admintest \
  mem_mb=1000 \
  cpus_per_task=1 \
  runtime=5