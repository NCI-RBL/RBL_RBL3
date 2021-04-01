pipeline=$1
PIPELINE_HOME=$(readlink -f $(dirname "$0"))
SINGULARITY_BINDS="-B $PIPELINE_HOME:$PIPELINE_HOME"
SINGULARITY_BINDS="$SINGULARITY_BINDS -B /data/CCBR_Pipeliner/:/data/CCBR_Pipeliner/"

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

#clean config_output_dir
output_dir=${config_output_dir}
SINGULARITY_BINDS="$SINGULARITY_BINDS -B $output_dir:$output_dir"

#Run pipeline on cluster or locally
if [[ $pipeline = "cluster" ]] || [[ $pipeline = "local" ]]; then

  #create log dir
  if [ -d "${output_dir}/log" ]
  then
    echo
    echo "Pipeline re-run, jobid:"
  else
    mkdir "${output_dir}/log"
    echo
    echo "Pipeline initial run, jobid:"
  fi

  # copy config inputs for ref
  files_save=('config/snakemake_config.yaml' 'config/cluster_config.yml' ${config_sample_manifest})

  for f in ${files_save[@]}; do
    IFS='/' read -r -a strarr <<< "$f"
    cp $f "${output_dir}/log/${log_time}_00_${strarr[-1]}"
  done

  # copy workflow dir for archiving
  if [ -d "${output_dir}/workflow" ]
  then
    echo "Using previously generated RBL3 pipeline"
  else
    mkdir "${output_dir}/workflow"
    cp -r "${source_dir}/workflow/" "${output_dir}/"
  fi

  #submit jobs to cluster
  if [[ $pipeline = "cluster" ]]; then
    sbatch --job-name="RBL3" --gres=lscratch:200 --time=120:00:00 --output=${output_dir}/log/${log_time}_00_%j_%x.out --mail-type=BEGIN,END,FAIL \
    snakemake \
    --use-envmodules \
    --rerun-incomplete \
    --latency-wait 120 \
    -s ${output_dir}/workflow/Snakefile \
    --configfile ${output_dir}/log/${log_time}_00_snakemake_config.yaml \
    --printshellcmds \
    --cluster-config ${output_dir}/log/${log_time}_00_cluster_config.yml \
    --keep-going \
    --restart-times 1 \
    --cluster "sbatch --gres {cluster.gres} --cpus-per-task {cluster.threads} \
    -p {cluster.partition} -t {cluster.time} --mem {cluster.mem} \
    --job-name={params.rname} --output=${output_dir}/log/${log_time}_{params.rname}.out" \
    -j 500 --rerun-incomplete \
    --use-singularity \
    --singularity-args "$SINGULARITY_BINDS"

  #submit jobs locally
  else
    snakemake \
      -s ${output_dir}/workflow/Snakefile \
      --use-envmodules \
      --configfile ${output_dir}/log/${log_time}_00_snakemake_config.yaml \
      --printshellcmds \
      --cluster-config ${output_dir}/log/${log_time}_00_cluster_config.yml \
      --cores 8 \
      --use-singularity \
      --rerun-incomplete \
      --singularity-args "$SINGULARITY_BINDS"
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
  #run snakemake
  snakemake -s workflow/Snakefile --configfile config/snakemake_config.yaml \
  --printshellcmds --cluster-config config/cluster_config.yml -npr
fi