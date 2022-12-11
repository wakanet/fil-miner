#!/bin/sh

repo=$1
if [ -z "$repo" ]; then
    repo=/data/cache/.ipfs
fi 

if [ ! -d "$repo" ]; then
    mkdir -p $repo
    IPFS_PATH=$repo ../../bin/ipfs init -e
    cp ipfs-swarm.key $repo/swarm.key
    IPFS_PATH=$repo ../../bin/ipfs config --json "Bootstrap" null
    if [ "$repo" = "/data/cache/.ipfs" ]; then
        IPFS_PATH=$repo ../../bin/ipfs config --json "Addresses.API" '"/ip4/127.0.0.1/tcp/15001"'
        IPFS_PATH=$repo ../../bin/ipfs config --json "Addresses.Gateway" '"/ip4/127.0.0.1/tcp/18080"'
        IPFS_PATH=$repo ../../bin/ipfs config --json "Addresses.Swarm" '["/ip4/0.0.0.0/tcp/14001","/ip6/::/tcp/14001","/ip4/0.0.0.0/udp/14001/quic","/ip6/::/udp/14001/quic"]'
    fi
fi

IPFS_PATH=$repo LIBP2P_FORCE_PNET=1 ../../bin/ipfs daemon &
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
