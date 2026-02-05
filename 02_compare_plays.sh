#!/bin/bash

# Compare two plays by their top words to find similarity
# Usage: ./compare_plays.sh <play1> <play2>

PLAY1="$1"
PLAY2="$2"

if [ -z "$PLAY1" ] || [ -z "$PLAY2" ]; then
    echo "Usage: ./compare_plays.sh <play1> <play2>"
    exit 1
fi

FILE1="output/${PLAY1}.top100.txt"
FILE2="output/${PLAY2}.top100.txt"

echo "Comparing ${PLAY1} and ${PLAY2}..."

# Extract just the words (remove counts column) from each file
awk '{print $2}' "$FILE1" > output/${PLAY1}.words.txt
awk '{print $2}' "$FILE2" > output/${PLAY2}.words.txt

# Find common words
comm -12 <(sort output/${PLAY1}.words.txt) <(sort output/${PLAY2}.words.txt) > output/common.txt

# Count them
COMMON=$(wc -l < output/common.txt)
TOTAL1=$(wc -l < output/${PLAY1}.words.txt)
TOTAL2=$(wc -l < output/${PLAY2}.words.txt)

# Jaccard similarity: intersection / union
UNION=$((TOTAL1 + TOTAL2 - COMMON))
# using bc to calculate, with the scale argument to set the number of decimal places
SIMILARITY=$(echo "scale=3; $COMMON / $UNION" | bc)


# Save result
echo "${SIMILARITY}" > output/${PLAY1}_${PLAY2}.similarity
echo "Jaccard similarity between ${PLAY1} and ${PLAY2}: ${SIMILARITY}"

# Clean up
rm output/${PLAY1}.words.txt output/${PLAY2}.words.txt output/common.txt
