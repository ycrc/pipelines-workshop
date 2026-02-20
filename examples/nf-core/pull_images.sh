#!/bin/bash
# Pre-pull Apptainer images for nf-core/rnaseq (v3.14.0, test profile)
#
# Run this before the pipeline to cache all container images.
# Usage:
#   salloc --partition=day --time=00:30:00 --mem=8G
#   bash pull_images.sh

export NXF_APPTAINER_CACHEDIR="${NXF_APPTAINER_CACHEDIR:-$HOME/scratch/apptainer_cache}"
mkdir -p "$NXF_APPTAINER_CACHEDIR"

# Images from quay.io (where nf-core/rnaseq actually pulls from)
IMAGES=(
    quay.io/biocontainers/bbmap:39.01--h5c4e2a8_0
    quay.io/biocontainers/bedtools:2.30.0--hc088bd4_0
    quay.io/biocontainers/bioconductor-dupradar:1.28.0--r42hdfd78af_0
    quay.io/biocontainers/bioconductor-summarizedexperiment:1.24.0--r41hdfd78af_0
    quay.io/biocontainers/bioconductor-tximeta:1.12.0--r41hdfd78af_0
    quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0
    quay.io/biocontainers/fq:0.9.1--h9ee0642_0
    quay.io/biocontainers/mulled-v2-1fa26d1ce03c295fe2fdcf85831a92fbcbd7e8c2:1df389393721fc66f3fd8778ad938ac711951107-0
    quay.io/biocontainers/mulled-v2-8849acf39a43cdd6c839a369a74c0adc823e2f91:ab110436faf952a33575c64dd74615a84011450b-0
    quay.io/biocontainers/multiqc:1.19--pyhdfd78af_0
    quay.io/biocontainers/perl:5.26.2
    quay.io/biocontainers/picard:3.0.0--hdfd78af_1
    quay.io/biocontainers/python:3.9--1
    quay.io/biocontainers/qualimap:2.3--hdfd78af_0
    quay.io/biocontainers/rseqc:5.0.3--py39hf95cd2a_0
    quay.io/biocontainers/salmon:1.10.1--h7e5ed60_0
    quay.io/biocontainers/samtools:1.16.1--h6899075_1
    quay.io/biocontainers/samtools:1.17--h00cdaf9_0
    quay.io/biocontainers/stringtie:2.2.1--hecb563c_2
    quay.io/biocontainers/subread:2.0.1--hed695b0_0
    quay.io/biocontainers/trim-galore:0.6.7--hdfd78af_0
    quay.io/biocontainers/ucsc-bedclip:377--h0b8a92a_2
    quay.io/biocontainers/ucsc-bedgraphtobigwig:445--h954228d_0
    quay.io/nf-core/ubuntu:20.04
)

echo "Pulling ${#IMAGES[@]} images into $NXF_APPTAINER_CACHEDIR"
echo ""

FAILED=0
for img in "${IMAGES[@]}"; do
    # Convert to SIF filename matching Nextflow's naming convention
    sif_name=$(echo "$img" | sed 's|/|-|g; s|:|-|g').img
    if [ -f "$NXF_APPTAINER_CACHEDIR/$sif_name" ]; then
        echo "CACHED  $img"
        continue
    fi
    echo "PULLING $img ..."
    apptainer pull --dir "$NXF_APPTAINER_CACHEDIR" --name "$sif_name" "docker://$img"
    if [ $? -ne 0 ]; then
        echo "FAILED  $img"
        FAILED=$((FAILED + 1))
    fi
done

echo ""
echo "Done. $FAILED failures out of ${#IMAGES[@]} images."
