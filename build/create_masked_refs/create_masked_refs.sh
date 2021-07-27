#!/bin/bash

#handle arguments
helpFunction()
{
   echo ""
   echo "Usage: $0 -g genelist"
   echo -e "\t-g Text file location of single gene or multiple genes separated by rows"
   exit 1 # Exit script after printing help
}

while getopts "g:b:c:" opt
do
   case "$opt" in
      g ) genelist="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$genelist" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

#parse through gene list
mapfile -t myArray < $genelist

#create gene name
if [[ ${#myArray[@]} > "1" ]]
then
    function join { local IFS="$1"; shift; echo "$*"; }
    gene_name=$(join _ ${myArray[@]})
else
    gene_name=${myArray[0]}
fi
echo $gene_name

#load requirements
module load bedops bedtools samtools

#set dependency folder
dep_dir="/data/RBL_NCI/Pipelines/Talon_Flair/dependencies"

#set input files
fa_file="${dep_dir}/hg38_cleanheader.fa"
gtf_file="${dep_dir}/gencode.v30.annotation.gtf"

#set output files
genome_file="${dep_dir}/masked/${gene_name}/hg38_cleanheader.genome"
masked_gtf="${dep_dir}/masked/${gene_name}/${gene_name}.gtf"
masked_bed="${dep_dir}/masked/${gene_name}/${gene_name}.bed"
masked_comp_bed="${dep_dir}/masked/${gene_name}/${gene_name}_complement.bed"
masked_fa="${dep_dir}/masked/${gene_name}/${gene_name}.fa"

#params
create_genome="Y"
create_gene_gtf="Y"
create_gene_bed="Y"
create_complement="Y"
create_masked="Y"

#create dir if it doesnt exist
if [ -d "${dep_dir}/masked/${gene_name}" ]
then
    echo "Existing output dir to be used: ${dep_dir}/masked/${gene_name}"
    echo
else
    echo "Creating new dir ${dep_dir}/masked/${gene_name}"
    echo
    mkdir "${dep_dir}/masked/${gene_name}"
fi

# create genomefile if absent
if [ ! -f "$genome_file" ] && [ "$create_genome" == "Y" ];then
	echo "Creating genome file"
    echo
    samtools faidx $fa_file
	cut -f1-2 ${fa_file}.fai > $genome_file
fi

# create gene gtf file
if [ ! -f "$masked_gtf" ] && [ "$create_gene_gtf" == "Y" ]; then
    echo "Creating ${gene_name} masked gtf file"
    echo
    touch $masked_gtf
    
    grep_gene=${gene_name/_/\"\|gene_name \"}
    grep_gene="gene_name \"${grep_gene}\""

    grep -E """$grep_gene""" $gtf_file >> $masked_gtf
fi

#create bed file for gene DGCR8
if [ ! -f "$masked_bed" ] && [ "$create_gene_bed" = "Y" ]; then
    echo "Creating ${gene_name} bed file"
	awk -F"\t" -v OFS="\t" '{if ($3=="gene"){print $1,$4-2000,$5+2000}}' $masked_gtf > $masked_bed
fi

#create complement of everything but gene
#https://bedtools.readthedocs.io/en/latest/content/tools/complement.html
if [ ! -f "$masked_comp_bed" ] && [ "$create_complement" = "Y" ]; then
    echo "Creating complement to ${gene_name} bed file"
    bedtools complement -i $masked_bed -g $genome_file > $masked_comp_bed
fi

#create masked file for gene
#https://bedtools.readthedocs.io/en/latest/content/tools/maskfasta.html
if [ ! -f "$masked_fa" ] && [ "$create_masked" = "Y" ]; then
    echo "Creating masked hg38 fa file for all but ${gene_name}"
    bedtools maskfasta -fi $fa_file -bed $masked_comp_bed -fo $masked_fa
fi
