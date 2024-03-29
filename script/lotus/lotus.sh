#!/bin/sh

#export IPFS_GATEWAY="https://proof-parameters.s3.cn-south-1.jdcloud-oss.com/ipfs/"
export FIL_PROOFS_PARAMETER_CACHE="/data/cache/filecoin-proof-parameters/v28" 

if [ -z "$lotusrepo" ]; then
    . env/miner-1.sh
fi

sudo IPFS_GATEWAY=$IPFS_GATEWAY FIL_PROOFS_PARAMETER_CACHE=$FIL_PROOFS_PARAMETER_CACHE $PRJ_ROOT/apps/lotus/lotus --repo=$lotusrepo "$@"
