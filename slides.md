---
marp: true
theme: default
paginate: true
---

<style>
.columns { display: flex; gap: 1em; }
.columns > div { flex: 1; }
img[alt~="center"] { display: block; margin: 0 auto; }
</style>

# Pipelining Tools for HPC Workflows

## Using Bash, Snakemake and Nextflow

Yale Center for Research Computing

---

# Agenda

- The Problem: why pipelines?
- Pipelining concepts
- Our example workflow
- Bash & Slurm
- Snakemake
- Nextflow
- NF-Core & resources

---

# Setup

- Log in to the cluster
- Clone the workshop repo

---

<!-- _class: lead -->

# The Problem

---

# Your Workflow

<div class="columns">
<div>

- Multiple steps that process input to produce output
- Some steps depend on others completing first
- It works — now you need to run it many times, scale it up, or share it

</div>
<div>

```bash
# step 1: process raw data
./clean.sh raw.dat > clean.dat

# step 2: run analysis
./analyze.sh clean.dat > results.dat

# step 3: make figures
./plot.sh results.dat > fig.png
```

</div>
</div>

---

# What Can Go Wrong

- Script versions multiply
- Data folders accumulate
- "It worked on my machine"
- A step fails halfway — is the output valid?

---

# Today's Learning Goals
- Understand key concepts for constructing data pipelines
- Build a simple workflow using bash scripts and Slurm
- Translate that workflow into Snakemake and Nextflow
- Learn how to configure Snakemake and Nextflow to run on an HPC cluster
---

<!-- _class: lead -->

# Pipelining Concepts

---

# Flowcharts and DAGs

<div class="columns">
<div>

- A workflow is a **directed acyclic graph** (DAG)
- Nodes are tasks, edges are dependencies
- No cycles — a task can't depend on its own output

</div>
<div>

![h:380](images/simple-dag.svg)

</div>
</div>

---

# Atomicity

- Every step of a pipeline should be **atomic**: it either fully succeeds, or fully fails.
- If a step fails, it should not produce partial output
- Prevents downstream steps from running on bad data

---

# Reproducibility

- **Same input** + **same options** = **same output**
- Portable: works the same on any system
- Version control your pipeline, not just your analysis
- Pipelining tools have features to log exactly what processing was run in what order, with what parameters.

---


<!-- _class: lead -->

# Our Example Workflow

---

# The Input Data

- 10 plays by William Shakespeare
- UTF-8 plaintext files
- Stand-in for your real data: genomic reads, simulation output, etc.
- Small enough to run in a workshop, but the tools scale

# The Goal

- Compute a measure of similarity between each pair of plays based on their most common words.
---

# The Workflow

1. **Clean** each play (lowercase, remove punctuation)
2. **Count** word frequencies
3. **Extract** top 100 words per play
4. **Compare** every pair of plays (Jaccard similarity)
5. **Combine** into a similarity matrix CSV

---

# The DAG

![center h:480](images/workflow-dag.png)


---

# The Bash Scripts

Our original scripts are found in the workshop repository under `examples/bash/`: 

| Script                  | Purpose                                  |
| ----------------------- | ---------------------------------------- |
| `01_analyze_play.sh`    | Clean text, count words, extract top 100 |
| `02_compare_plays.sh`   | Jaccard similarity between two plays     |
| `03_combine_results.sh` | Aggregate results into CSV               |
| `00_run_all.sh`         | Run everything in order                  |

---

# 01_analyze_play.sh — Overview

Takes one play name as input, produces its top 100 words.

```bash
# Usage: ./analyze_play.sh <play>

PLAY="$1"
INPUT="data/${PLAY}.txt"
```

Three steps: **clean** → **count** → **extract top 100**

---

# 01 — Step 1: Clean the Text

Convert to lowercase, remove punctuation, one word per line:

```bash
cat "$INPUT" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -d '[:punct:]' \
    | tr -s '[:space:]' '\n' \
    > output/${PLAY}.clean.txt
```

- `tr '[:upper:]' '[:lower:]'` — lowercase everything
- `tr -d '[:punct:]'` — delete punctuation
- `tr -s '[:space:]' '\n'` — squeeze whitespace, one word per line

---

# 01 — Step 2: Count Word Frequencies

Sort words, count unique occurrences, sort by frequency:

```bash
cat output/${PLAY}.clean.txt \
    | sort \
    | uniq -c \
    | sort -rn \
    > output/${PLAY}.counts.txt
```

Output looks like:

```
   1138 the
    674 and
    594 of
    ...
```

---

# 01 — Step 3: Extract Top 100

Keep only the 100 most frequent words, clean up intermediates:

```bash
head -100 output/${PLAY}.counts.txt > output/${PLAY}.top100.txt

rm output/${PLAY}.clean.txt
rm output/${PLAY}.counts.txt
```

- `data/hamlet.txt` → `output/hamlet.top100.txt`
- Intermediate `.clean.txt` and `.counts.txt` are deleted

---

# 02_compare_plays.sh — Overview

Takes two play names, computes their **Jaccard similarity**.

```bash
PLAY1="$1"
PLAY2="$2"
FILE1="output/${PLAY1}.top100.txt"
FILE2="output/${PLAY2}.top100.txt"
```

Jaccard = |intersection| / |union| of their top-100 word sets.

---

# 02 — Step 1: Extract Word Lists

Strip the count column, keep just the words:

```bash
awk '{print $2}' "$FILE1" > output/${PLAY1}.words.txt
awk '{print $2}' "$FILE2" > output/${PLAY2}.words.txt
```

---

# 02 — Step 2: Find Common Words

Use `comm` to find the intersection of sorted word lists:

```bash
comm -12 \
    <(sort output/${PLAY1}.words.txt) \
    <(sort output/${PLAY2}.words.txt) \
    > output/common.txt
```

- `comm -12` suppresses lines unique to either file
- Only lines common to **both** files are kept

---

# 02 — Step 3: Calculate Jaccard Similarity

```bash
COMMON=$(wc -l < output/common.txt)
TOTAL1=$(wc -l < output/${PLAY1}.words.txt)
TOTAL2=$(wc -l < output/${PLAY2}.words.txt)

UNION=$((TOTAL1 + TOTAL2 - COMMON))
SIMILARITY=$(echo "scale=3; $COMMON / $UNION" | bc)

echo "${SIMILARITY}" > output/${PLAY1}_${PLAY2}.similarity
```

- `bc` handles decimal division (bash only does integers)
- Output: a single file like `output/hamlet_macbeth.similarity`

---

# 03_combine_results.sh

Loop through all `.similarity` files, build a CSV:

```bash
echo "play1,play2,similarity" > output/similarity_matrix.csv

for file in output/*.similarity; do
    basename=$(basename "$file" .similarity)
    play1=$(echo "$basename" | cut -d'_' -f1)
    play2=$(echo "$basename" | cut -d'_' -f2-)
    similarity=$(cat "$file")

    echo "${play1},${play2},${similarity}" \
        >> output/similarity_matrix.csv
done
```

- Parses play names from the filename
- Final output: `output/similarity_matrix.csv`

---

# 00_run_all.sh — The Orchestrator

```bash
# Step 1: Analyze all plays
for play in data/*.txt; do
    name=$(basename "$play" .txt)
    ./analyze_play.sh "$name"
done

# Step 2: Compare all pairs
plays=(data/*.txt)
for ((i=0; i<${#plays[@]}; i++)); do
    for ((j=i+1; j<${#plays[@]}; j++)); do
        ./compare_plays.sh "$name1" "$name2"
    done
done

# Step 3: Combine results
./combine_results.sh
```

---

# What's Wrong With This?

- Runs everything **serially** — no parallelism
- No **dependency tracking** — if one step fails, downstream runs anyway
- No **checkpointing** — must restart from scratch on failure
- **Manual cleanup** of intermediate file

---

# Moving to Slurm

- Add `#SBATCH` directives for resources
- Add email notifications
- But still a single serial job — no parallelism

---

# Hands-On: Bash + Slurm

- Adapt `00_run_all.sh` to run as a Slurm job
- Add resource directives and email notification
- Submit and check the output

---

<!-- _class: lead -->

# Snakemake

---

# What is Snakemake?

- Python-based workflow management tool
- Define **rules** with inputs, outputs, and commands that produce output from input.
- Snakemake builds the DAG and runs tasks in the right order.
- Snakemake allows you to run shell code, or Python code in your scripts.

---

# Key Concepts

- **Snakefile**: The main file that defines the workflow
- **Rules**: Define a single step in the pipeline
  - Has an `input`, `output`, and a `shell` element.
- **Wildcards**: Create input lists from filename patterns

---

# The Default Target: `rule all`

Snakemake works **backwards** from a target. `rule all` declares what the pipeline should produce:

```python
rule all:
    input:
        "output/similarity_matrix.csv"
```

- This is always the **first rule** in the Snakefile
- Snakemake traces dependencies backwards to figure out what needs to run
- Nothing runs unless it's needed to produce this target

---

# Translating: Clean Text

<div class="columns">
<div>

**Bash**

```bash
cat "$INPUT" \
  | tr '[:upper:]' '[:lower:]' \
  | tr -d '[:punct:]' \
  | tr -s '[:space:]' '\n' \
  > output/${PLAY}.clean.txt
```

</div>
<div>

**Snakemake**

```python
rule clean_text:
    input:
        DATA_DIR + "/{play}.txt"
    output:
        temp("output/{play}.clean.txt")
    shell:
        """
        cat {input} \
          | tr '[:upper:]' '[:lower:]' \
          | tr -d '[:punct:]' \
          | tr -s '[:space:]' '\\n' \
          > {output}
        """
```

</div>
</div>

- `{play}` is a **wildcard** — one rule handles all 10 plays
- `temp()` marks the file for automatic cleanup

---

# Translating: Count Words

<div class="columns">
<div>

**Bash**

```bash
cat output/${PLAY}.clean.txt \
  | sort \
  | uniq -c \
  | sort -rn \
  > output/${PLAY}.counts.txt
```

</div>
<div>

**Snakemake**

```python
rule count_words:
    input:
        "output/{play}.clean.txt"
    output:
        temp("output/{play}.counts.txt")
    shell:
        """
        sort {input} \
          | uniq -c \
          | sort -rn > {output}
        """
```

</div>
</div>

- Snakemake knows `count_words` depends on `clean_text` because the **output of one matches the input of the other**

---

# Translating: Top 100 Words

<div class="columns">
<div>

**Bash**

```bash
head -100 \
  output/${PLAY}.counts.txt \
  > output/${PLAY}.top100.txt

rm output/${PLAY}.clean.txt
rm output/${PLAY}.counts.txt
```

</div>
<div>

**Snakemake**

```python
rule top_words:
    input:
        "output/{play}.counts.txt"
    output:
        "output/{play}.top100.txt"
    shell:
        """
        head -100 {input} > {output}
        """
```

</div>
</div>

- No manual `rm` needed — `temp()` files are cleaned up automatically
- This output is **not** `temp()` because downstream rules depend on it

---

# Translating: Compare Plays

<div class="columns">
<div>

**Bash**

```bash
comm -12 \
  <(awk '{print $2}' "$FILE1" \
    | sort) \
  <(awk '{print $2}' "$FILE2" \
    | sort) \
  > output/common.txt
# ... compute Jaccard ...
```

</div>
<div>

**Snakemake**

```python
rule compare_plays:
    input:
        top1="output/{play1}.top100.txt",
        top2="output/{play2}.top100.txt"
    output:
        "output/{play1}_{play2}.similarity"
    shell:
        """
        COMMON=$(comm -12 \
          <(awk '{{print $2}}' \
            {input.top1} | sort) \
          <(awk '{{print $2}}' \
            {input.top2} | sort) \
          | wc -l)
        ...
        """
```

</div>
</div>

- Two wildcards `{play1}` and `{play2}` handle all 45 pairs

---

# Translating: Combine Results

<div class="columns">
<div>

**Bash**

```bash
echo "play1,play2,similarity" \
  > output/similarity_matrix.csv

for file in output/*.similarity; do
  # parse filename, append CSV row
done
```

</div>
<div>

**Snakemake**

```python
rule combine_results:
    input:
        expand(
          "output/{p1}_{p2}.similarity",
          zip, p1=PLAY1S, p2=PLAY2S)
    output:
        "output/similarity_matrix.csv"
    shell:
        """
        echo "play1,play2,similarity" \
          > {output}
        for file in {input}; do
          # parse filename, append row
        done
        """
```

</div>
</div>

- `expand()` with `zip` generates all 45 input files

---

# Running Snakemake
When executing `snakemake`, it will find a `Snakefile` in the current directory.
- `snakemake -n` for a dry run
- `snakemake` to execute the pipeline
- `snakemake --dag | dot -Tpng > dag.png` to visualize

---

# What You Get for Free

- Automatic dependency resolution
- Only re-runs steps whose inputs changed
- Parallel (multiple processes) execution with `-j`
- DAG visualization
- Dry-run mode

---

# Snakemake on Slurm

- Cluster profile or `--executor slurm`
- Each rule becomes a separate Slurm job
- Snakemake monitors and schedules automatically

---

# Hands-On: Snakemake

- Run the Snakemake pipeline
- Try a dry run, then execute
- Visualize the DAG
- Compare output to the bash version

---

<!-- _class: lead -->

# Nextflow

---

# What is Nextflow?

- Groovy-based workflow management
- **Processes** and **channels**
- Built-in container support (Docker, Singularity)
- Dataflow programming model

---

# Key Concepts

- **Processes**: define tasks with inputs, outputs, scripts
- **Channels**: connect processes, data flows through them
- **Operators**: transform and combine channels

---

# Translating to Nextflow

- Each step becomes a process
- Channels wire the DAG together
- Configuration is separate from workflow logic

---

# Nextflow Configuration

- `nextflow.config` for executor, resources, containers
- Profiles for different environments (local, Slurm)
- Container support built in

---

# Execution Model

- Work directory for intermediate files
- Caching and `-resume` for re-runs
- Execution report and timeline visualization

---

<!-- _class: lead -->

# NF-Core Pipelines

---

# NF-Core

- Community-maintained Nextflow pipelines
- Focus on bioinformatics
- Best practices built in: containers, testing, documentation
- Browse available pipelines at https://nf-co.re

---

# Resources & Next Steps

- Snakemake documentation
- Nextflow documentation
- NF-Core pipeline registry
- Yale HPC documentation and office hours

---

<!-- _class: lead -->

# Questions?

Thank you!
