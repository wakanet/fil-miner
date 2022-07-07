#!/bin/sh

export IPFS_GATEWAY="https://proof-parameters.s3.cn-south-1.jdcloud-oss.com/ipfs/"
export FIL_PROOFS_USE_MULTICORE_SDR=1
export FIL_PROOFS_PARENT_CACHE="/data/cache"
export FIL_PROOFS_PARAMETER_CACHE="/data/cache/filecoin-proof-parameters/v28" 

repodir=$1
if [ -z "$repodir" ]; then
    repodir=/data/cache/.lotus
fi
mkdir -p $repodir

if [ ! -f $repodir/config.toml ]; then
    netip=$(ip a | grep -Po '(?<=inet ).*(?=\/)'|grep -E "^10\.") # only support one eth card.
    echo "Set $netip to config.toml"
    cp config-lotus.toml $repodir/config.toml
    if [ ! -z $netip ]; then
    	sed -i "s/127.0.0.1/$netip/g" $repodir/config.toml
    fi
fi


./lotus --repo=$repodir daemon --etcd="http://127.0.0.1:2379" &
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

wait "$pid"
