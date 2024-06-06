#!/bin/sh
export ROCM_PATH=/opt/rocm
export MPICH_DIR=/opt/ompi-5.0.3
export PATH=$PATH:$MPICH_DIR/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MPICH_DIR/lib


export GMX_DIR=~/Repo/benchmark-gromacs/Gromacs-mpi/build-mpi
export OMP_NUM_THREADS=6
export NODES=1
export TUNEPME=no
export GPUIDS=0123
export NSTEPS=1000

export MPICH_GPU_SUPPORT_ENABLED=1
export GMX_ENABLE_DIRECT_GPU_COMM=1
export AMD_DIRECT_DISPATCH=1
export GMX_GPU_PME_DECOMPOSITION=1
export GMX_FORCE_CUDA_AWARE_MPI=1
export GMX_GPU_DD_COMMS=true
export GMX_GPU_PME_PP_COMMS=true
export GMX_FORCE_GPU_AWARE_MPI=true

export ROCPROF_ARGS="./helper_rocprof.sh --hip-trace --roctx-trace"

mpirun --mca pml ucx -np 4 $ROCPROF_ARGS $GMX_DIR/bin/gmx_mpi mdrun -v -s topol.tpr -stepout 1000 -nsteps $NSTEPS -maxh 1.0 -noconfout -ntomp $OMP_NUM_THREADS -nb gpu -bonded gpu -pme gpu -update cpu -dlb auto -tunepme $TUNEPME -gpu_id $GPUIDS -nstlist 80 -dds 0.7 -npme 1 ${CPT} -pin on -pinoffset 0 -pinstride 4
$ROCM_PATH/libexec/rocprofiler/merge_traces.sh -o prof_eag_merged slurm-*
wait
tar -czvf merged.tar.gz prof_eag_merged/ slurm-*
rm -rf prof_eag_merged/
rm -rf slurm*
