#!/bin/bash

#SBATCH --mem-per-cpu=16000
#SBATCH --time=1-00:00:00
#SBATCH -e AF_%x_err.txt
#SBATCH -o AF_%x_out.txt
#SBATCH --cpus-per-task=32
#SBATCH -p gpu
#SBATCH -C gpu=A100
#SBATCH --gres=gpu:1

if [ -z ${max_recycles+x} ]; then max_recycles=3; fi
if [ -z ${homooligomer+x} ]; then homooligomer=1; fi
if [ -z ${msa_method+x} ]; then msa_method='mmseqs2'; fi
if [ -z ${pair_mode+x} ]; then pair_mode='unpaired'; fi

echo $jobprefix
if [[ "${fasta}" ]]; then
    echo $fasta
elif [[ "${fastas}" ]]; then
    #remove double quotes
    fastas="${fastas%\"}"
    fastas="${fastas#\"}"
    echo $fastas
fi

echo $max_recycles
echo $homooligomer
echo $msa_method
echo $pair_mode
echo $ranges

module load AlphaFold/2.1.1-fosscuda-2020b
module load matplotlib/3.3.3-fosscuda-2020b IPython/7.18.1-GCCcore-10.2.0 tqdm/4.60.0-GCCcore-10.2.0 #required modules compatible with fosscuda-2020b

if [[ "${fasta}" ]]; then
    time PYTHONPATH=/g/kosinski/kosinski/devel/alphafold:$PYTHONPATH \
    TF_FORCE_UNIFIED_MEMORY='1' XLA_PYTHON_CLIENT_MEM_FRACTION='4.0' \
    python /g/kosinski/kosinski/devel/alphafold/sokrypton_alphafold2_advanced.py \
        --fasta $fasta --jobprefix $jobprefix --max_recycles $max_recycles --homooligomer $homooligomer --msa_method $msa_method --pair_mode $pair_mode --ranges $ranges
elif [[ "${fastas}" ]]; then
    time PYTHONPATH=/g/kosinski/kosinski/devel/alphafold:$PYTHONPATH \
    TF_FORCE_UNIFIED_MEMORY='1' XLA_PYTHON_CLIENT_MEM_FRACTION='4.0' \
    python /g/kosinski/kosinski/devel/alphafold/sokrypton_alphafold2_advanced.py \
        --fastas $fastas --jobprefix $jobprefix --max_recycles $max_recycles --homooligomer $homooligomer --msa_method $msa_method --pair_mode $pair_mode --ranges $ranges
fi

