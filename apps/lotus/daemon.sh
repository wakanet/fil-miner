#!/bin/sh

export IPFS_GATEWAY="https://proof-parameters.s3.cn-south-1.jdcloud-oss.com/ipfs/"
export FIL_PROOFS_USE_MULTICORE_SDR=1
export FIL_PROOFS_PARENT_CACHE="/data/cache/filecoin-parents"
export FIL_PROOFS_PARAMETER_CACHE="/data/cache/filecoin-proof-parameters/v28" 
export TRUST_PARAMS=1 # using lotus fetch-params <SectorSize> with manu check when installing

mkdir -p $FIL_PROOFS_PARENT_CACHE
mkdir -p $FIL_PROOFS_PARAMETER_CACHE 

repodir=$1
if [ -z "$repodir" ]; then
    repodir=/data/cache/.lotus
fi
mkdir -p $repodir

netip="`/bin/sh ./ip.sh`"
if [ ! -f $repodir/config.toml ]; then
    echo "Set $netip to config.toml"
    cp config-lotus.toml $repodir/config.toml
    sed -i "s/127.0.0.1/$netip/g" $repodir/config.toml
fi


./lotus --repo=$repodir daemon &
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
