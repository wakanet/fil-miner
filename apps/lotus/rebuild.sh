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

if [ -z "FIL_PROOFS_GPU_MODE" ]; then
    export FIL_PROOFS_GPU_MODE="force"
fi

mkdir -p $FIL_PROOFS_PARENT_CACHE
mkdir -p $FIL_PROOFS_PARAMETER_CACHE 

# checking gpu
gpu=""
type nvidia-smi
if [ $? -eq 0 ]; then
    gpu=$(nvidia-smi -L|grep "GPU")
fi
if [ ! -z "$gpu" ]; then
    FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1
    FIL_PROOFS_USE_GPU_TREE_BUILDER=1
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

netip=$(ip a | grep -Po '(?<=inet ).*(?=\/)'|grep -E "^10\.") # only support one eth card.
if [ -z $netip ]; then
    netip="127.0.0.1"
fi
RUST_LOG=info RUST_BACKTRACE=1 NETIP=$netip GOMAXPROCS=$cpu_num ./lotus-worker --worker-repo=$worker_repo rebuild --miner-id=80868
pid=$!

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
