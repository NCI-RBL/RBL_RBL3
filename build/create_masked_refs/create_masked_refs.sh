#!/bin/bash

module load bedops bedtools samtools

#set dependency folder
dep_dir="/data/CCBR_Pipeliner/Talon_Flair/dependencies"

#set input files
gtf_file="${dep_dir}/gencode.v30.annotation.gtf"
fa_file="${dep_dir}/hg38_cleanheader.fa"

#set output files
hgbed_file="${dep_dir}/masked_dgcr8/gencode.v30.annotation.bed"
genome_file="${dep_dir}/masked_dgcr8/hg38_cleanheader.genome"
dgcr8_bed="${dep_dir}/masked_dgcr8/DGCR8.bed"
dgcr8_comp_bed="${dep_dir}/masked_dgcr8/DGCR8_complement.bed"
dgcr8_fa="${dep_dir}/masked_dgcr8/DGCR8.fa"
dgcr8_gtf="${dep_dir}/masked_dgcr8/DGCR8.gtf"

#params
create_hg_bed="Y"
create_gene_gtf="Y"
create_gene_bed="Y"
create_complement="Y"
create_masked="Y"

# create genomefile if absent
if [ ! -f "$genome_file" ];then
	samtools faidx $fa_file
	cut -f1-2 ${fa_file}.fai > $genome_file
fi

# create gene gtf file
if [ "$create_gene_gtf" == "Y" ];then
	grep "gene_name \"DGCR8\"" $gtf_file > $dgcr8_gtf
fi

#create bed file for gene DGCR8
if [ "$create_gene_bed" = "Y" ]; then
    echo "Creating DGCR8 bed file"
	awk -F"\t" -v OFS="\t" '{if ($3=="gene"){print $1,$4-2000,$5+2000}}' $dgcr8_gtf > $dgcr8_bed
fi

#create complement of everything but gene
#https://bedtools.readthedocs.io/en/latest/content/tools/complement.html
if [ "$create_complement" = "Y" ]; then
    echo "Creating complement to DGCR8 bed file"
    bedtools complement -i $dgcr8_bed -g $genome_file > $dgcr8_comp_bed
fi

#create masked file for gene
#https://bedtools.readthedocs.io/en/latest/content/tools/maskfasta.html
if [ "$create_masked" = "Y" ]; then
    echo "Creating masked hg38 fa file for all but DGCR8"
    bedtools maskfasta -fi $fa_file -bed $dgcr8_comp_bed -fo $dgcr8_fa
fi
