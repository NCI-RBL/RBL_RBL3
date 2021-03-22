anno_gtf=/data/CCBR_Pipeliner/db/PipeDB/Indices/GTFs/hg38/gencode.v30.annotation.gtf
anno_fa=/data/CCBR_Pipeliner/db/PipeDB/Indices/hg38_30/ref.fa
source_dir=/data/CCBR/projects/rbl3/fastq
dest_dir=/data/CCBR/projects/rbl3

module load minimap2

# cupcake tutorial
#https://github.com/Magdoll/cDNA_Cupcake/wiki/Cupcake:-supporting-scripts-for-Iso-Seq-after-clustering-step

## create sam file
declare -a arr=("barcode01" "barcode02" "barcode03")
for f in "${arr[@]}"
do
    echo "processing ${f}"
    input="${source_dir}/$f.R1.fastq.gz"
    samoutput="${dest_dir}/sam/$f.sam"
    sortedoutput="${dest_dir}/sam/$f.sorted.sam"

    minimap2 \
        -ax splice -t 30 -uf --secondary=no -C5 \
        $anno_fa $input > $samoutput
    
    sort -k 3,3 -k 4,4n \
    $samoutput > $sortedoutput
done

#collapse unique reads