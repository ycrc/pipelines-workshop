# Pipelining Tools: Using Bash, Snakemake and Nextflow to Craft Reproducible HPC Workflows

https://github.com/ycrc/pipelines-workshop.git

A workshop introducing HPC users to workflow automation tools. We build the same example pipeline in Bash, Snakemake, and Nextflow, then run an nf-core pipeline on real bioinformatics data.

**Slides:** Slides are written in Markdown using the [Marp](https://marp.app/) framework, which allows for easy formatting and conversion to HTML or PDF.  
Source: `slides.md`  
PDF: `slides.pdf`  

## Examples

```
examples/
├── data/
├── bash/
│   ├── 01_analyze_play.sh
│   ├── 02_compare_plays.sh
│   ├── 03_combine_results.sh
│   ├── 00_run_all.sh
│   ├── run_pipeline.sh
│   └── run_pipeline_solution.sh
├── snakemake/
│   └── Snakefile
└── nextflow/
    ├── shakespeare/
    │   └── main.nf
    └── nf-core/
        ├── run_rnaseq_slurm.sh
        └── nextflow.config
```
