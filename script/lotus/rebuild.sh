#!/bin/sh

export FIL_PROOFS_USE_GPU_COLUMN_BUILDER=0
export FIL_PROOFS_USE_GPU_TREE_BUILDER=0
export FIL_PROOFS_MAXIMIZE_CACHING=1  # open cache for 32GB or 64GB
export FIL_PROOFS_USE_MULTICORE_SDR=1
export FIL_PROOFS_PARENT_CACHE="/data/cache/filecoin-parents"
export FIL_PROOFS_PARAMETER_CACHE="/data/cache/filecoin-proof-parameters/v28" 
export TMPDIR=/data/cache/tmp
export worker_repo="/data/cache/rebuild"
export sector_size="2048"
export sector_head="s-f"

mkdir -p $TMPDIR

if [ -z "FIL_PROOFS_GPU_MODE" ]; then
    export FIL_PROOFS_GPU_MODE="auto"
fi

mkdir -p $FIL_PROOFS_PARENT_CACHE
mkdir -p $FIL_PROOFS_PARAMETER_CACHE 

# checking gpu
gpu=""
type nvidia-smi
if [ $? -eq 0 ]; then
    gpu=$(nvidia-smi --query-gpu=name --format=csv,noheader|head -n 1)
    # TODO: more gpu provider
fi
if [ ! -z "$gpu" ]; then
    FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1
    FIL_PROOFS_USE_GPU_TREE_BUILDER=1
    #"NVIDIA Quadro RTX 6000:4608, NVIDIA TITAN RTX:4608, NVIDIA Tesla V100:5120, NVIDIA Tesla P100:3584, NVIDIA Tesla T4:2560, NVIDIA Quadro M5000:2048, NVIDIA GeForce RTX 3090:10496, NVIDIA GeForce RTX 3080:8704, NVIDIA GeForce RTX 3070:5888, NVIDIA GeForce RTX 2080 Ti:4352, NVIDIA GeForce RTX 2080 SUPER:3072, NVIDIA GeForce RTX 2080:2944, NVIDIA GeForce RTX 2070 SUPER:2560, NVIDIA GeForce GTX 1080 Ti:3584, NVIDIA GeForce GTX 1080:2560, NVIDIA GeForce GTX 2060:1920, NVIDIA GeForce GTX 1660 Ti:1536, NVIDIA GeForce GTX 1060:1280, NVIDIA GeForce GTX 1650 SUPER:1280, NVIDIA GeForce GTX 1650:896"
    case $gpu in
        *"GeForce RTX 3090"):
            export RUST_GPU_TOOLS_CUSTOM_GPU="$gpu:10496"
        ;;
        *"GeForce RTX 3080"):
            export RUST_GPU_TOOLS_CUSTOM_GPU="$gpu:8704"
        ;;
        *"GeForce RTX 3070"):
            export RUST_GPU_TOOLS_CUSTOM_GPU="$gpu:5888"
        ;;
        *"GeForce RTX 2080 Ti"):
            export RUST_GPU_TOOLS_CUSTOM_GPU="$gpu:4352"
        ;;
        *"GeForce RTX 2080 SUPER"):
            export RUST_GPU_TOOLS_CUSTOM_GPU="$gpu:3072"
        ;;
        #TODO: more match
    esac
fi

cpu_bind=$($PRJ_ROOT/apps/lotus/lotus-worker pledge --cpu-bind)
cpu_num=$($PRJ_ROOT/apps/lotus/lotus-worker pledge --cpu-num)
export LOTUS_P2_L3_NUM=2
RUST_LOG=info RUST_BACKTRACE=1 GOMAXPROCS=$cpu_num $PRJ_ROOT/apps/lotus/lotus-worker --worker-repo=$worker_repo rebuild --sector-size=$sector_size --sector-head=$sector_head ./rebuild.txt &
pid=$!
taskset -pc $cpu_bind $pid

# set ulimit for process
nropen=$(cat /proc/sys/fs/nr_open)
echo "max nofile limit:"$nropen
echo "current nofile of $pid limit:"$(cat /proc/$pid/limits|grep "open files")
prlimit -p $pid --nofile=655350
if [ $? -eq 0 ]; then
    echo "new nofile of $pid limit:"$(cat /proc/$pid/limits|grep "open files")
else
    echo "set prlimit failed, command:prlimit -p $pid --nofile=655350"
    exit 0
fi

if [ ! -z "$pid" ]; then
    wait "$pid"
fi
