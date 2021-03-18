#tutorial
#https://github.com/mortazavilab/TALON/tree/master/example

#create dir tutorial_0310
#had to edit config to match test directory location
module load bedtools

#set dirs
out_dir=/data/CCBR/projects/rbl3/tutorial
input_dir=/data/CCBR/projects/rbl3/dependencies/TALON-master/example
anno_id="SIRV_annot"
build_id="SIRV"
maxFracA="0.5"
minCount="5"
minDatasets="2"

#move into TALON dir
cd $input_dir 

#remove previous runs
rm_cmd="rm -r ${out_dir}/*"
$rm_cmd

#initialize db
talon_initialize_database \
        --f "${input_dir}/SIRV_annotation.gtf" \
        --a $anno_id \
        --g $build_id \
        --o "${out_dir}/example_talon"

#create label dir for annotation
mkdir -p "${out_dir}/labeled"

#interal primiing - how likely each read si will be used as an internal priming product
#labeling only - no reads are removed
search_sams="${input_dir}/aligned_reads/*.sam"

for filename in $search_sams
do
    #split filename, remove .sam
    IFS='/' read -r -a strarr <<< "$filename"
    sample_name=${strarr[-1]}
    sample_name=${sample_name%".sam"}

    talon_label_reads --f $filename \
       --g "${input_dir}/SIRV.fa"  \
       --t 1 \
       --ar 20 \
       --deleteTmp \
       --o "${out_dir}/labeled/${sample_name}"
done

#annotate and quantify reads; modify db
talon \
       --f "${input_dir}/config.csv" \
       --db "${out_dir}/example_talon.db" \
       --build $build_id \
       --t 1 \
       --o "${out_dir}/example"

#summarize how many transcripts before filtering
talon_summarize \
       --db "${out_dir}/example_talon.db" \
       --v \
       --o "${out_dir}/example"

#abundance matrix (for comp gene expression) without filtering
talon_abundance \
       --db "${out_dir}/example_talon.db" \
       -a $anno_id \
       --build $build_id \
       --o "${out_dir}/example"

#repeat with TALON filters
talon_filter_transcripts \
       --db "${out_dir}/example_talon.db" \
       -a $anno_id \
       --maxFracA $maxFracA \
       --minCount $minCount \
       --minDatasets $minDatasets \
       --o "${out_dir}/filtered_transcripts.csv"

#repeat abundance summaryon filtered transcripts
talon_abundance \
       --db "${out_dir}/example_talon.db" \
       --whitelist "${out_dir}/filtered_transcripts.csv" \
       -a $anno_id \
       --build $build_id \
       --o "${out_dir}/example"

#create custom GTF of filtered transcripts
talon_create_GTF \
       --db "${out_dir}/example_talon.db" \
       --whitelist "${out_dir}/filtered_transcripts.csv" \
       -a $anno_id \
       --build $build_id \
       --o "${out_dir}/example"