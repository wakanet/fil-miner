#!/bin/sh

repo=$1
root=$2
authAddr=$3
httpAddr=$4
pxfsAddr=$5
if [ -z "$repo" ]; then
    repo=$PRJ_ROOT/var/lotus-storage/
fi
if [ -z "$root" ]; then
    root="/data/zfs"
fi
if [ -z "$authAddr" ]; then
    authAddr=":1330"
fi
if [ -z "$httpAddr" ]; then
    httpAddr=":1331"
fi
if [ -z "$pxfsAddr" ]; then
    pxfsAddr=":1332"
fi

../../bin/bchain-storage \
    --addr-auth="$authAddr" \
    --addr-http="$httpAddr" \
    --addr-pxfs="$pxfsAddr" \
    daemon --root=$root --repo="$repo" --export-nfs=true &
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

