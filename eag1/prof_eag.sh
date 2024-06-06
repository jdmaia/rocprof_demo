#!/bin/sh
#SBATCH --time 10:00
#SBATCH -N 2
#SBATCH -n 16
#SBATCH --output gmx_slurmout.log
#SBATCH --error gmx_slurmerr.log

export GMX_DIR=~/Repo/Gromacs_AMD/build-mpi
#export ROCR_VISIBLE_DEVICES=0,1,2,3,4,5,6,7
export OMP_NUM_THREADS=16
export NODES=1
#export NODES=4 # (PROCS-1) / NODES should be == 8 as each mpi rink binds to a gpu
export TUNEPME=no
#export GPUIDS=01234567
export GPUIDS=01234567
export NSTEPS=1000
export GMX_ENABLE_DIRECT_GPU_COMM=1
export AMD_DIRECT_DISPATCH=1
export GMX_GPU_DD_COMMS=1
export GMX_GPU_PME_PP_COMMS=1
export ROCPROF_ARGS="./helper_rocprof.sh --hip-trace --roctx-trace"

mpirun -np 8 $ROCPROF_ARGS $GMX_DIR/bin/gmx_mpi mdrun -v -s topol.tpr -stepout 1000 -nsteps $NSTEPS -maxh 1.0 -noconfout -ntomp $OMP_NUM_THREADS -nb gpu -bonded gpu -pme gpu -update cpu -dlb auto -tunepme $TUNEPME -gpu_id $GPUIDS -nstlist 80 -dds 0.7 -npme 1 ${CPT} -pin on -pinoffset 0 -pinstride 4
$ROCM_PATH/libexec/rocprofiler/merge_traces.sh -o prof_eag_merged slurm-*
wait
tar -czvf merged.tar.gz prof_eag_merged/ slurm-*
rm -rf prof_eag_merged/
rm -rf slurm*
