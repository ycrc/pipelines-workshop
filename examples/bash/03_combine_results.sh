#!/bin/bash

# combine_results.sh - Collate all pairwise similarity results into a CSV
# Assumes compare_plays.sh has been run for each pair

echo "play1,play2,similarity" > output/similarity_matrix.csv

for file in output/*.similarity; do
    # Extract play names from filename (e.g., hamlet_macbeth.similarity)
    basename=$(basename "$file" .similarity)
    play1=$(echo "$basename" | cut -d'_' -f1)
    play2=$(echo "$basename" | cut -d'_' -f2-)
    similarity=$(cat "$file")

    echo "${play1},${play2},${similarity}" >> output/similarity_matrix.csv
done

echo "Combined $(ls output/*.similarity | wc -l) results into output/similarity_matrix.csv"
