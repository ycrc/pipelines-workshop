#!/bin/bash

# =============================================================================
# Slurm Job Script for the Analysis Pipeline
#
# Add your #SBATCH directives below to request resources from Slurm.
# Refer to the slide for a list of common directives.
# =============================================================================

# --- Add your #SBATCH directives here ---


# --- Pipeline starts here (no changes needed below) ---

cd $SLURM_SUBMIT_DIR

# Step 1: Analyze all plays
echo "=== Analyzing all plays ==="
for play in ../data/*.txt; do
    name=$(basename "$play" .txt)
    ./01_analyze_play.sh "$name"
done

# Step 2: Compare all pairs
echo ""
echo "=== Comparing all pairs ==="
plays=(../data/*.txt)
for ((i=0; i<${#plays[@]}; i++)); do
    for ((j=i+1; j<${#plays[@]}; j++)); do
        name1=$(basename "${plays[$i]}" .txt)
        name2=$(basename "${plays[$j]}" .txt)
        ./02_compare_plays.sh "$name1" "$name2"
    done
done

# Step 3: Combine results
echo ""
echo "=== Combining results ==="
./03_combine_results.sh

echo ""
echo "=== Pipeline complete ==="
