#!/bin/bash

module load bedops bedtools

#set dependency folder
dep_dir="/data/CCBR/projects/rbl3/dependencies"

#set input files
gtf_file="${dep_dir}/gencode.v30.annotation.gtf"
fa_file="${dep_dir}/hg38_cleanheader.fa"

#set output files
hgbed_file="${dep_dir}/masked_dgcr8/gencode.v30.annotation.bed"
dgcr8_bed="${dep_dir}/masked_dgcr8/DGCR8.bed"
dgcr8_comp_bed="${dep_dir}/masked_dgcr8/DGCR8_complement.bed"
dgcr8_fa="${dep_dir}/masked_dgcr8/DGCR8.fa"

#params
create_hg_bed="Y"
create_gene_bed="Y"
create_complement="Y"
create_masked="Y"

#create bed for hg38
#older versions of gencode do nto have the transcript_id field; must be added before gtf2bed will work
#https://www.biostars.org/p/206342/
if [ "$create_hg_bed" = "Y" ]; then
    echo "Creating hg38 bed file"
    awk '{ if ($0 ~ "transcript_id") print $0; else print $0" transcript_id \"\";"; }' $gtf_file | gtf2bed - > $hgbed_file
fi

#create bed file for gene DGCR8
#https://www.genecards.org/cgi-bin/carddisp.pl?gene=DGCR8
#chr22:20,080,232-20,111,877
#moving 1KB upstream and 1KB downstream
if [ "$create_gene_bed" = "Y" ]; then
    echo "Creating DGCR8 bed file"
    touch $dgcr8_bed
    echo -e "chr22\t20079232\t20112877" > $dgcr8_bed
fi

#create complement of everything but gene
#https://bedtools.readthedocs.io/en/latest/content/tools/complement.html
if [ "$create_complement" = "Y" ]; then
    echo "Creating complement to DGCR8 bed file"
    bedtools complement -i $dgcr8_bed -g $hgbed_file > $dgcr8_comp_bed
fi

#create masked file for gene
if [ "$create_masked" = "Y" ]; then
    echo "Creating masked hg38 fa file for all but DGCR8"
    bedtools maskfasta -fi $fa_file -bed $dgcr8_comp_bed -fo $dgcr8_fa
fi
