#!/bin/bash
#$ -o job$TASK_ID
#$ -l h_rt=23:00:00,h_data=4G
#$ -pe shared 18
usage() { echo "Usage: bash $0 -c case -s sample -o output_directory" 1>&2; exit 1; }

while getopts ":i:c:r:o:p:b:g:" o; do
    case "${o}" in
        i)  cell_table=${OPTARG};;
	g)  genes_file=${OPTARG};;
	c)  chrom_sizes_file=${OPTARG};;
#        r)  resolution=${OPTARG};;
	o)  out_file_path=${OPTARG};;
#	b)  cell_id=${OPTARG};;
        *)
            usage;;
    esac
done


export NUMEXPR_MAX_THREADS=8
export PATH="/u/home/h/heffel/.local/bin:$PATH"
#echo $PATH


#use sample index instead of sample when running with array jobs
sampleIndex=$(($SGE_TASK_ID))

echo "output directory: $out_dir"

# echo job info on joblog:
echo "Job $JOB_ID started on:   " `hostname -s`
echo "Job $JOB_ID started on:   " `date `
echo " "

# load the job environment:
. /u/local/Modules/default/init/modules.sh
## Edit the line below as needed:
#module load python/3.7.2
module load anaconda3/2023.03
conda activate schicluster_env
## substitute the command to run your code
## in the two lines below:
echo "$in_file $resolution $cell_id $out_dir $chrom_file"
#python3 gnomadToPickle.py gnomad.genomes.r3.0.sites.vcf.bgz test_gnomad_output.pickle
command time hicluster gene-score --cell_table_path $cell_table \
    --chrom_size_path $chrom_sizes_file \
    --gene_meta_path $genes_file \
    --output_hdf_path $out_file_path --resolution 25000 --cpu 12 --mode impute
echo "icluster gene-score --cell_table_path $cell_table \
    --chrom_size_path $chrom_sizes_file \
    --gene_meta_path $genes_file \
    --output_hdf_path $out_file_path --resolution 25000 --cpu 12 --mode impute"

# echo job info on joblog:
echo "Job $JOB_ID ended on:   " `hostname -s`
echo "Job $JOB_ID ended on:   " `date `
echo "Done"

