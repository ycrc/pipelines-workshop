# Pipelining Tools: Using Bash, Snakemake and Nextflow to Craft Reproducible HPC Workflows

This workshop will introduce HPC users to the different tools available on Yale clusters to automate frequently used workflows in a manageable and reproducible way. Hands-on examples will guide attendees through the implementation of a realistic example workflow in each tool, highlighting the strengths and differences of each. Attendees will leave the workshop with the ability to turn ad-hoc scripts into reproducible pipelines using the most appropriate pipelining tool for the job or their preferences.

- A workshop that introduces cluster users to different options for automating their cluster pipelines. 
- We will have a contrived workflow example that we will implement in each tool to highlight the differences.
- The workshop starts with a simple Python or Bash script, and makes it more reproducible and manageable using pipelining tools. 

`data/` contains the input data for the example workflow, which is a set of 10 plays by William Shakespeare in UTF-8 encoded plaintext. The output of the workflow is a similarity matrix comparing the top-100 words in each play to each other play.

`examples/bash/` contains the scripts for the example workflow implemented in bash. `examples/snakemake/` and `examples/nextflow/` contain the same workflow implemented in Snakemake and Nextflow, respectively. `examples/nf-core/` contains a hands-on guide for running the nf-core/rnaseq pipeline with its built-in test dataset.

## GenAI Rules
- Any generated content needs to be simplistic for instruction and not the typical verbosity of a LLM. Much review by human required.

## Outline
- Room Setup
  - Way to do dual monitors where I have the presentation on one and the terminal/ide on the other? Driven from my laptop?
- Prerequisites
  - what do you need to know to follow through this workshop?
- Attendee Setup
  - Log in to a cluster
  - Clone the repo
  - Should we set up a cluster reservation for this?
- The Problem (1-2 slides)
  - You have a workflow that processes some input to produce some output. 
  - The workflow may contain many steps, some of which depend on other steps to complete before executing. 
  - Now that it works, you're going to need to run this workflow a lot, or make sure it's reproducible for your paper and colleagues.
    - How do we avoid making a mess of multiple script versions, countless data folders, etc?
- Pipelining Concepts (3-4 slides)
  - Flowchart -> DAG
  - What if we showed a hand sketch process of the flowchart first?
  - What is "reproducible"?
    - Same input + Same options = Same output
    - Portable: works the same on any system
  - Atomicity: if a step fails, it should not produce partial output that could be mistaken for a successful run.
  - Review Luigi?Airflow? docs for some of this good theory background.
- Introducing our Example 
  - Input data: 10 plays of William Shakespeare, in UTF-8 encoded plaintext. 
  - Maybe your data is genomic reads, or a physics simulation, output from an instrument, etc.
  - The data here is sized to run quickly in a workshop setting, but the point of using pipelining tools is that they can scale to much larger datasets while keeping your workflow manageable and reproducible.
  - Output data: similarity matrix comparing the top-100 words in each play to each other play.
  - Flowchart in `workflow.md`
    - Talk about DAG, dependencies, etc.
  - 
- Bash & Make
  - We start with simple bash:
    - One script analyzes a play to produce the top-100 list
    - One script analyzes two top-100 lists to produce a similarity score
    - Third script combines the similarity scores into a matrix once we've run on each play-play pair.
  - Walking through the scripts in detail to start so the class understands each step we're trying to automate.
  - We show the `00_run_all.sh` script that runs all the steps in the right order, but it's not very robust or reproducible. 
  - Maybe touch on Makefiles here? 
  - We walk through adapting the run_all script into a Slurm job. Now we can run our pipeline with Slurm and get an email when it finishes, but it's still not very robust or reproducible.
  - HANDS ON: Attendees adapt the run_all script to run on Slurm.
    - Add resource directives, add email notification, etc.
    - Run the script and wait for it to finish.
- Snakemake (10 slides?)
  - First way we introduce concrete concepts of pipelines, actually defining dependencies and outputs for each step.
  - Need to create the snakemake conversion of the bash scripts. Ideally this is very minimal. 
  - We now walk through the bash scripts in more detail as we are translating into Snakemake rules. Maybe most detail in the first script, and then a "prebaked" version of the Snakemake rules for the rest of the workflow.
  - Once we have a snakemake pipeline, we introduce what we need to run it on Slurm. Configs, commands, etc.
  - Execution model: how does it know what tasks to run next, where does it run them, how does it monitor them, etc?
  - Good time to show off the stuff you "get for free" with these tools; if snakemake has visualization or monitoring we show them here. Maybe after attendees try themselves.
  - HANDS ON: Attendees adapt the Snakemake pipeline to run on Slurm
  - Reference any available resources, e.g. a snakemake cookbook if that exists, documentation, etc. for attendees to learn more on their own.
  - TODO: containers?
- Nextflow (10 slides?)
  - Same thing, translating the bash scripts into Nextflow processes and defining the workflow.
  - Config will be more involved here, talk about containerization
  - Need to develop a good answer for "which is better" or which do I use?
    - Snakemake is simpler and more pythonic, Nextflow has more built-in support for more complex things... but this increases its baseline complexity.
  - Execution model: how does it know what tasks to run next, where does it run them, how does it monitor them, etc?
  - Show off DAG viz, execution report, etc. Live dashboard of some sort? How does that work with slurm?
- NF-Core Pipelines for Bioinformatics
  - Introduce as a resource for bio pipelines: best practices already implemented, community support, etc.


## Feedback from Team Review

- For Nextflow portion, focus on running preexisting nf-core pipelines rather than re-implementing the same workflow.
  - Using nf-core/rnaseq with test profile (yeast, ~50K reads). Runs in ~10 min on 4 cores/16GB. See `examples/nf-core/README.md`.