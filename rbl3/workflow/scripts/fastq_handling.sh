#copy files from source
source_dir=/data/RBL_NCI/Gu/chunmei/nanopore/fastq_pass
dest_dir=/data/sevillas2/RBL3/fastq

barcode_list=(barcode01)

for f in $barcode_list
do
    input="${source_dir}/$f/*.fastq"
    output="${dest_dir}/$f.fastq"
    cat $input > $output
done