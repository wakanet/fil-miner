#!/bin/sh

repo=$1
if [ -z "$repo" ]; then
    repo=/data/cache/.ipfs
fi

if [ ! -d "$epo" ]; then
    # TODO: init port
    ../../bin/ipfs --repo-dir=$repo init
    cp ipfs-swarm.key $repo/swarm.key
fi

LIBP2P_FORCE_PNET=1 ../../bin/ipfs --repo-dir=$repo daemon &
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

echo "waiting the daemon up"
sleep 10
../../bin/ipfs --repo-dir=$repo bootstrap rm all

if [ ! -z "$pid" ]; then
    wait "$pid"
fi
