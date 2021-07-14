# RBL3 Pipeline Overview
## Workflow
* Adapters are trimmed from FASTQ files with [Porechop](https://github.com/rrwick/Porechop)
* Alignment is performed with [minimap2](https://github.com/lh3/minimap2)
* An option to clean-up SAM files is provided in config. If selected SAM files are corrected for mismatches, microindels, and noncanonical splice junctions that have been mapped to the genome,  using [TranscriptClean](https://github.com/mortazavilab/TranscriptClean) when **clean_transcript** flag is turned on
* QC is performed on FASTQ files with [FASTQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) and on BAM files with [SAMTOOLS](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
* Two workflows are completed for transcipt identification and annotation:
  > [TALON](https://github.com/mortazavilab/TALON) workflow is performed including read priming, abundance counts of transcripts, filtering transcripts and summarizing transcripts before and after filtering. See output summary below.
  > [FLAIR](https://github.com/BrooksLabUCSC/flair#modules) workflow is performed. See output summary below.
* DEG Analysis is completed based on user-provided input of comparison groups via [FLAIR](https://github.com/BrooksLabUCSC/flair#diffExp) count matrices
![Alt text](resources/workflow.png?raw=true "Workflow")

## Output Summary
* Intermediate files are defined in [Wiki](https://github.com/RBL-NCI/RBL_RBL3/wiki/Overview)
* QC_report provides summaries of the sequencing alignment, by read length
* MultiQC_report provides summaries of the FASTQ and BAM files quality
* Summary_report provides overview of parameters included within the workflow run, summaries of both the TALON and FLAIR workflows, comparisons between the outputs, and a DEG summary, if included.

## Getting Started
Review the wiki page for a [tutorial]((https://github.com/RBL-NCI/RBL_RBL3/wiki/Pipeline-Tutorial)) and [general information](https://github.com/RBL-NCI/RBL_RBL3/wiki/Overview) on running the pipeline.