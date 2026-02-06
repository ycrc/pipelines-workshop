#!/bin/bash

# Analyze a single Shakespeare play
# Usage: ./analyze_play.sh <play>

PLAY="$1"
INPUT="data/${PLAY}.txt"

# Create output directory
mkdir -p output

echo "Analyzing ${PLAY}..."

# Step 1: Clean the text
# - Convert to lowercase
# - Remove punctuation
echo "  Cleaning text..."
cat "$INPUT" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -d '[:punct:]' \
    | tr -s '[:space:]' '\n' \
    > output/${PLAY}.clean.txt

# Step 2: Count word frequencies
echo "  Counting words..."
cat output/${PLAY}.clean.txt \
    | sort \
    | uniq -c \
    | sort -rn \
    > output/${PLAY}.counts.txt

# Step 3: Get top 100 words
echo "  Extracting top words..."
head -100 output/${PLAY}.counts.txt > output/${PLAY}.top100.txt

# Step 4: Report results
echo "Wrote output to output/${PLAY}.top100.txt"

# Step 5: Clean up
rm output/${PLAY}.clean.txt
rm output/${PLAY}.counts.txt

echo "Done!"
