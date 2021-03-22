anno_gtf=/data/CCBR_Pipeliner/db/PipeDB/Indices/GTFs/hg38/gencode.v30.annotation.gtf
anno_fa=/data/CCBR_Pipeliner/db/PipeDB/Indices/hg38_30/ref.fa
source_dir=/data/CCBR/projects/rbl3/fastq
dest_dir=/data/CCBR/projects/rbl3

module load cupcake

declare -a arr=("barcode01" "barcode02" "barcode03")
for f in "${arr[@]}"
do
    echo "processing ${f}"
    fq="${source_dir}/$f.R1.fastq.gz"
    sortedsam="${dest_dir}/sam/$f.sorted.sam"

    collapse_isoforms_by_sam.py \
        --input $fq --fq \
        -s $sortedsam \
        --dun-merge-5-shorter -o $f
done