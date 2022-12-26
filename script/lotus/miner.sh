#!/bin/sh
export IPFS_GATEWAY="https://proof-parameters.s3.cn-south-1.jdcloud-oss.com/ipfs/"
export FIL_PROOFS_PARAMETER_CACHE="/data/cache/filecoin-proof-parameters/v28" 

if [ -z "$lotusrepo" ]; then
   . env/miner-1.sh
fi

init=0
if [ ! -d $filrepo/datastore ]; then
    init=1
    sudo mkdir -p $filrepo
fi

if [ $init -eq 1 ];then
    sudo IPFS_GATEWAY=$IPFS_GATEWAY FIL_PROOFS_PARAMETER_CACHE=$FIL_PROOFS_PARAMETER_CACHE $PRJ_ROOT/apps/lotus/lotus-miner --repo=$lotusrepo --miner-repo=$filrepo "$@"
    sudo mv $filrepo/config.toml $filrepo/config.toml.bak
    sudo cp $PRJ_ROOT/apps/lotus/config-miner-seal.toml $filrepo/config.toml
    sudo cp $PRJ_ROOT/apps/lotus/config-withdraw.toml $filrepo/withdraw.toml
    netip=$(ip a | grep -Po '(?<=inet ).*(?=\/)'|grep -E "^10\.") # only support one eth card.
    if [ ! -z $netip ]; then
        echo "Set $netip to config.toml"
        sudo sed -i "s/127.0.0.1/$netip/g" $filrepo/config.toml
    fi
else
    sudo IPFS_GATEWAY=$IPFS_GATEWAY FIL_PROOFS_PARAMETER_CACHE=$FIL_PROOFS_PARAMETER_CACHE $PRJ_ROOT/apps/lotus/lotus-miner --repo=$lotusrepo --miner-repo=$filrepo "$@"
fi
