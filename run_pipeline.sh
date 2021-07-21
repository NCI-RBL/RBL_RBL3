pipeline=$1


#handle yaml file
parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

#adds config_ to each config variable
eval $(parse_yaml config/snakemake_config.yaml "config_")

# set timestamp
log_time=`date +"%Y%m%d_%H%M"`
s_time=`date +"%Y%m%d_%H%M%S"`

#remove trailing / on directories
output_dir=$(echo $config_output_dir | sed 's:/*$::')
source_dir=$(echo $config_source_dir | sed 's:/*$::')


#Run pipeline on cluster or locally
if [[ $pipeline = "cluster" ]] || [[ $pipeline = "local" ]]; then
  #create output dir
  if [ -d "${output_dir}" ]
    then
      echo
      echo "Output dir: ${output_dir}"
    else
      mkdir "${output_dir}"
      echo
      echo "Creating output dir: ${output_dir}"
    fi

  #create log dir
  if [ -d "${output_dir}/log" ]
  then
    mkdir "${output_dir}/log/${log_time}"
    echo
    echo "Pipeline re-run, jobid:"
  else
    mkdir "${output_dir}/log"
    mkdir "${output_dir}/log/${log_time}"
    echo
    echo "Pipeline initial run, jobid:"
  fi

  # copy config inputs for ref
  files_save=('config/snakemake_config.yaml' 'config/cluster_config.yml' ${config_sample_manifest} 'workflow/Snakefile' 'workflow/scripts/check_for_errors.sh')

  for f in ${files_save[@]}; do
    IFS='/' read -r -a strarr <<< "$f"
    cp $f "${output_dir}/log/${log_time}/00_${strarr[-1]}"
  done

  #submit jobs to cluster
  if [[ $pipeline = "cluster" ]]; then
    sbatch --job-name="RBL3" --gres=lscratch:200 --time=120:00:00 --output=${output_dir}/log/${log_time}/00_%j_%x.out --mail-type=BEGIN,END,FAIL \
    snakemake \
    --use-envmodules \
    --rerun-incomplete \
    --latency-wait 120 \
    --keep-going \
    --restart-times 1 \
    --printshellcmds \
    -s ${output_dir}/workflow/${log_time}/00_Snakefile \
    --configfile ${output_dir}/log/${log_time}/00_snakemake_config.yaml \
    --cluster-config ${output_dir}/log/${log_time}/00_cluster_config.yml \
    --cluster "sbatch --gres {cluster.gres} --cpus-per-task {cluster.threads} \
    -p {cluster.partition} -t {cluster.time} --mem {cluster.mem} \
    --job-name={params.rname} --output=${output_dir}/log/${log_time}/{params.rname}.out" \
    -j 500

  #submit jobs locally
  else
    snakemake \
      --use-envmodules \
      --rerun-incomplete \
      --printshellcmds \
      --cores 8 \
      -s ${output_dir}/workflow/${log_time}/00_Snakefile \
      --configfile ${output_dir}/log/${log_time}/00_snakemake_config.yaml \
      --cluster-config ${output_dir}/log/${log_time}/00_cluster_config.yml
  fi
#Unlock pipeline
elif [[ $pipeline = "unlock" ]]; then
  snakemake -s workflow/Snakefile --use-envmodules --unlock --cores 8 --configfile config/snakemake_config.yaml
#Run github actions
elif [[ $pipeline = "test" ]]; then
  snakemake -s workflow/Snakefile --configfile .tests/snakemake_config.yaml \
  --printshellcmds --cluster-config config/cluster_config.yml -npr
#Dry-run pipeline
else
  snakemake -s workflow/Snakefile --configfile config/snakemake_config.yaml \
  --printshellcmds --cluster-config config/cluster_config.yml -npr
fi
