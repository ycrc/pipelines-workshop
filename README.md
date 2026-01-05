# Pipelining Tools: Using Bash, Snakemake and Nextflow to Craft Reproducible HPC Workflows

This workshop will introduce HPC users to the different tools available on Yale clusters to automate frequently used workflows in a manageable and reproducible way. Hands-on examples will guide attendees through the implementation of a realistic example workflow in each tool, highlighting the strengths and differences of each. Attendees will leave the workshop with the ability to turn ad-hoc scripts into reproducible pipelines using the most appropriate pipelining tool for the job or their preferences.

- A workshop that introduces cluster users to different options for automating their cluster pipelines. 
- We will have a contrived workflow example that we will implement in each tool to highlight the differences.
- The workshop starts with a simple Python or Bash script, and makes it more reproducible and manageable using pipelining tools. 


## Outline

- The Problem
  - You have a workflow that processes some input to produce some output. 
  - The workflow may contain many steps, some of which depend on other steps to complete before executing. 
  - Now that it works, you're going to need to run this workflow a lot, or make sure it's reproducible for your paper.
    - How do we avoid making a mess of multiple script versions, countless data folders, etc?
- Pipelining Concepts
  - Flowchart -> DAG
  - What is "reproducible"?
- Introducing our Example
- Bash & Make
- Snakemake
- Nextflow
- NF-Core Pipelines for Bioinformatics