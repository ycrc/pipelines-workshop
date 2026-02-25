#!/usr/bin/env nextflow

// To run this pipeline:
//   cd examples/nextflow
//   module load Nextflow
//   nextflow run main.nf            // run the pipeline
//   nextflow run main.nf -resume    // re-run, skipping completed steps
//   nextflow clean -f               // clean up the work directory

// Path to input data
params.data_dir = "${projectDir}/../../data"

// Collect all play text files into a channel
plays_ch = Channel.fromPath("${params.data_dir}/*.txt")

// Step 1a: Clean text — lowercase, remove punctuation, one word per line
process clean_text {
    input:
    path play

    output:
    tuple val(play.baseName), path("${play.baseName}.clean.txt")

    script:
    """
    cat ${play} \
        | tr '[:upper:]' '[:lower:]' \
        | tr -d '[:punct:]' \
        | tr -s '[:space:]' '\\n' \
        > ${play.baseName}.clean.txt
    """
}

// Step 1b: Count word frequencies
process count_words {
    input:
    tuple val(name), path(clean)

    output:
    tuple val(name), path("${name}.counts.txt")

    script:
    """
    sort ${clean} | uniq -c | sort -rn > ${name}.counts.txt
    """
}

// Step 1c: Extract top 100 most frequent words
process top_words {
    publishDir "output", mode: 'copy'

    input:
    tuple val(name), path(counts)

    output:
    tuple val(name), path("${name}.top100.txt")

    script:
    """
    head -100 ${counts} > ${name}.top100.txt
    """
}

// Step 2: Compare two plays using Jaccard similarity of their top words
process compare_plays {
    input:
    tuple val(name1), path(top1), val(name2), path(top2)

    output:
    path "${name1}_${name2}.similarity"

    script:
    """
    COMMON=\$(comm -12 \
        <(awk '{print \$2}' ${top1} | sort) \
        <(awk '{print \$2}' ${top2} | sort) \
        | wc -l)
    TOTAL1=\$(wc -l < ${top1})
    TOTAL2=\$(wc -l < ${top2})
    UNION=\$((TOTAL1 + TOTAL2 - COMMON))
    echo "scale=3; \$COMMON / \$UNION" | bc > ${name1}_${name2}.similarity
    """
}

// Step 3: Combine all pairwise results into a CSV matrix
process combine_results {
    publishDir "output", mode: 'copy'

    input:
    path similarities

    output:
    path "similarity_matrix.csv"

    script:
    """
    echo "play1,play2,similarity" > similarity_matrix.csv
    for file in *.similarity; do
        basename=\$(basename "\$file" .similarity)
        play1=\$(echo "\$basename" | cut -d'_' -f1)
        play2=\$(echo "\$basename" | cut -d'_' -f2-)
        similarity=\$(cat "\$file")
        echo "\${play1},\${play2},\${similarity}" >> similarity_matrix.csv
    done
    """
}

// Wire together the workflow
workflow {
    // Step 1: analyze each play
    cleaned  = clean_text(plays_ch)
    counted  = count_words(cleaned)
    top100   = top_words(counted)

    // Step 2: generate all unique pairs and compare
    pairs_ch = top100
        .combine(top100)
        .filter { name1, top1, name2, top2 -> name1 < name2 }
        .map { name1, top1, name2, top2 -> tuple(name1, top1, name2, top2) }

    similarities = compare_plays(pairs_ch)

    // Step 3: collect all similarity files and combine
    combine_results(similarities.collect())
}
