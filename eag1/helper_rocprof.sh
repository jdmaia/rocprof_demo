#! /usr/bin/env bash
if [[ -n ${OMPI_COMM_WORLD_RANK+z} ]]; then
  # mpich
  export MPI_RANK=${OMPI_COMM_WORLD_RANK}
elif [[ -n ${MV2_COMM_WORLD_RANK+z} ]]; then
  # ompi
  export MPI_RANK=${MV2_COMM_WORLD_RANK}
elif [[ -n ${SLURM_LOCALID+z} ]]; then
  # mpich via srun
  export MPI_RANK=${SLURM_LOCALID}
fi
pid="$$"
outdir="slurm-${SLURM_JOBID}_rank_${pid}_${MPI_RANK}"
outfile="results-${SLURM_JOBID}_${pid}_${MPI_RANK}.csv"
eval "rocprof -d ${outdir} -o ${outdir}/${outfile} $*"
