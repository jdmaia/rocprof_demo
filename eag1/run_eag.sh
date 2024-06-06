#!/bin/sh
export GMX_DIR=~/Repo/Gromacs_AMD/build-mpi
export ROCR_VISIBLE_DEVICES=0,1,2,3,4,5,6,7
#export ROCR_VISIBLE_DEVICES=4,5,2,3,6,7,0,1
export OMP_NUM_THREADS=16
#export NODES=2
export NODES=1 # (PROCS-1) / NODES should be == 8 as each mpi rink binds to a gpu
export PROCS=8
export NPME=1
export PME=gpu
export TUNEPME=no
export GPUIDS=01234567
export NSTEPS=1000
#export CPT="-cpt 0.5 -cpo 32GPU.cpt"
export ROCPROF_ARGS=
export GMX_ENABLE_DIRECT_GPU_COMM=1
export AMD_DIRECT_DISPATCH=1
export GMX_GPU_DD_COMMS=1
export GMX_GPU_PME_PP_COMMS=1
export GMX_FOP
export ROCPROF_ARGS="./helper_rocprof.sh --hip-trace --roctx-trace"

mpirun -np $PROCS $GMX_DIR/bin/gmx_mpi mdrun -v -s topol.tpr \
    -stepout 5000 -nsteps $NSTEPS -maxh 1.0 -resethway \
    -noconfout -ntomp $OMP_NUM_THREADS -nb gpu -bonded gpu \
    -update cpu -pme $PME -dlb auto -tunepme $TUNEPME -gpu_id $GPUIDS \
    -nstlist 80 -dds 0.7 -npme $NPME ${CPT} -pin on -pinoffset 0 -pinstride 4

