# Pipelining Tools: Using Bash, Snakemake and Nextflow to Craft Reproducible HPC Workflows

A workshop introducing HPC users to workflow automation tools. We build the same example pipeline — comparing Shakespeare plays by word frequency — in Bash, Snakemake, and Nextflow, then run an nf-core pipeline on real bioinformatics data.

**Slides:** Slides are written in Markdown using the [Marp](https://marp.app/) framework, which allows for easy formatting and conversion to HTML or PDF.  
Source: `slides.md`  
PDF: `slides.pdf`

## Examples

```
examples/
├── data/                  # 10 Shakespeare plays (UTF-8 plaintext)
├── bash/                  # Bash scripts + Slurm job wrappers
│   ├── 00_run_all.sh
│   ├── 01_analyze_play.sh
│   ├── 02_compare_plays.sh
│   ├── 03_combine_results.sh
│   ├── run_pipeline.sh          # Starter (blank SBATCH header)
│   └── run_pipeline_solution.sh # Solution (complete Slurm script)
├── snakemake/
│   └── Snakefile
├── nextflow/
│   └── main.nf
└── nf-core/
    ├── pull_images.sh     # Pre-pull Apptainer images for rnaseq
    └── README.md          # Hands-on guide for nf-core/rnaseq
```
