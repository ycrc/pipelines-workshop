#!/bin/bash

# run_all.sh - Run the full analysis pipeline on all plays

# Step 1: Analyze all plays
echo "=== Analyzing all plays ==="
for play in data/*.txt; do
    name=$(basename "$play" .txt)
    ./analyze_play.sh "$name"
done

# Step 2: Compare all pairs
echo ""
echo "=== Comparing all pairs ==="
plays=(data/*.txt)
for ((i=0; i<${#plays[@]}; i++)); do
    for ((j=i+1; j<${#plays[@]}; j++)); do
        name1=$(basename "${plays[$i]}" .txt)
        name2=$(basename "${plays[$j]}" .txt)
        ./compare_plays.sh "$name1" "$name2"
    done
done

# Step 3: Combine results
echo ""
echo "=== Combining results ==="
./combine_results.sh

echo ""
echo "=== Pipeline complete ==="
