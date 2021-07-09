# RBL3 Pipeline Overview
* Sam files are corrected for mismatches, microindels, and noncanonical splice junctions in long reads that have been mapped to the genome with [TranscriptClean](https://github.com/mortazavilab/TranscriptClean)
* QC is performed on FASTQ files with [FASTQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) and on BAM files with [SAMTOOLS](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
* [TALON](https://github.com/mortazavilab/TALON) workflow is performed including read priming, abundance counts of transcripts, filtering transcripts and summarizing transcripts before and after filtering. See output summaries below.
* [FLAIR](https://github.com/BrooksLabUCSC/flair#modules) workflow is performed. See partial summaries below, complete pipeline still in progress.

## Workflow
* Adapters are trimmed from FASTQ files with [Porechop](https://github.com/rrwick/Porechop)
* Sam files are corrected for mismatches, microindels, and noncanonical splice junctions in long reads that have been mapped to the genome with [TranscriptClean](https://github.com/mortazavilab/TranscriptClean) when **clean_transcript** flag is turned on
* QC is performed on FASTQ files with [FASTQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) and on BAM files with [SAMTOOLS](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
* [TALON](https://github.com/mortazavilab/TALON) workflow is performed including read priming, abundance counts of transcripts, filtering transcripts and summarizing transcripts before and after filtering. See output summary below.
* [FLAIR](https://github.com/BrooksLabUCSC/flair#modules) workflow is performed. See output summary below.
* QC Reports are generated (QC_report, MultiQC_report). See output summary below

## Output Summary
* QC_report provides summaries of the sequencing alignment, by read length
* MultiQC_report provides summaries of the FASTQ and BAM files quality
* Summary_report provides summaries of both the TALON and FLAIR workflows

## Getting Started
1.1 Download the workflow
Please clone this repository to your local filesystem using the following command:

```bash
# Clone Repository from Github
git clone https://github.com/RBL-NCI/iCLIP.git
# Change your working directory to the iCLIP repo
cd iCLIP/
```

1.2 Add snakemake to PATH
Please make sure that snakemake>=5.19 is in your $PATH. If you are in Biowulf, please load the following environment module:

```bash
# Recommend running snakemake>=5.19
module load snakemake/5.24.1
```

1.3 Configure workflow
Configure the workflow according to your needs via editing the files in the config/ folder. Adjust snakemake_config.yaml to configure the workflow execution and cluster_config.yml to configure the cluster settings. Create sample.tsv and deg.tsv files to specify your sample setup, or edit the example manifests in the manifest/ folder.

1.4 Dry-run the workflow
Run the following command to dry-run the snakemake pipeline:

```bash
sh run_snakemake.sh dry-run
```
Review the log to ensure there are no workflow errors.

2. Usage
```bash
#Submit master job to the cluster:
sh run_snakemake.sh cluster

#Submit master job locally:
sh run_snakemake.sh local
```