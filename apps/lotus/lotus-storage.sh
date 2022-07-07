#!/bin/sh

root=$1
repo=$2
authAddr=$3
httpAddr=$4
pxfsAddr=$5
if [ -z "$root" ]; then
    root=$PRJ_ROOT/var/lotus-storage/
fi
if [ -z "$repo" ]; then
    repo="/data/zfs"
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

./lotus-storage --storage-root=$root \
    --addr-auth="$authAddr" \
    --addr-http="$httpAddr" \
    --addr-pxfs="$pxfsAddr" \
    daemon --storage-repo="$repo" &
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

