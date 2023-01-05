#!/bin/sh
export IPFS_GATEWAY="https://proof-parameters.s3.cn-south-1.jdcloud-oss.com/ipfs/"
# Note that FIL_PROOFS_USE_GPU_TREE_BUILDER=1 is for tree_r_last building and FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1 is for tree_c.  
# So be sure to use both if you want both built on the GPU
export FIL_PROOFS_USE_GPU_COLUMN_BUILDER=0
export FIL_PROOFS_USE_GPU_TREE_BUILDER=0
export FIL_PROOFS_MAXIMIZE_CACHING=1  # open cache for 32GB or 64GB
export FIL_PROOFS_USE_MULTICORE_SDR=1
export FIL_PROOFS_PARENT_CACHE="/data/cache/filecoin-parents"
export FIL_PROOFS_PARAMETER_CACHE="/data/cache/filecoin-proof-parameters/v28" 
#export worker_id_file="~/.lotusworker/worker-1t.id"
export TMPDIR=/data/cache/tmp

mkdir -p $TMPDIR

if [ -z "FIL_PROOFS_GPU_MODE" ]; then
    export FIL_PROOFS_GPU_MODE="force"
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
        *"GeForce RTX 3060"):
            export RUST_GPU_TOOLS_CUSTOM_GPU="$gpu:3584"
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


miner_repo=$1 # miner_repo of go-filecoin


if [ -z "$miner_repo" ]; then
    miner_repo=/data/sdb/lotus-user-1/.lotusminer
fi

worker_repo=$2
if [ -z "$worker_repo" ]; then
    worker_repo=/data/cache/.lotusworker 
fi
storage_repo=$3
if [ -z "$storage_repo" ]; then
    storage_repo="/data/lotus-push" # 密封结果存放
fi

mkdir -p $worker_repo
mkdir -p $miner_repo
mkdir -p $storage_repo

netip="`/bin/sh ./ip.sh`"
cpu_bind=$(./lotus-worker pledge --cpu-bind 0)
cpu_num=$(./lotus-worker pledge --cpu-num 0)
export LOTUS_P2_L3_NUM=2
# ssd size = 12TB, cores L3 group 32, core thread x2
RUST_LOG=info RUST_BACKTRACE=1 NETIP=$netip GOMAXPROCS=$cpu_num ./lotus-worker --worker-repo=$worker_repo --miner-repo=$miner_repo --storage-repo=$storage_repo run --id-file="$worker_id_file" --max-tasks=28 --transfer-buffer=2 --parallel-pledge=14 --parallel-precommit1=14 --parallel-precommit2=1 --parallel-commit=0 &
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
