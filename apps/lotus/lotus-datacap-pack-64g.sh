#!/bin/sh

src_dir=$1
if [ -z "$src_dir" ]; then
    src_dir="/data/lotus-datacap/src-dir"
fi
cache_dir=$2
if [ -z "$cache_dir" ]; then
    cache_dir="/data/lotus-datacap/cache-dir"
fi
tar_dir=$3
if [ -z "$tar_dir" ]; then
    tar_dir="/data/lotus-datacap/tar-dir"
fi
encrypt_key=$4

mkdir -p $src_dir
mkdir -p $cache_dir
mkdir -p $tar_dir

./lotus-datacap pack-srv --src-dir=$src_dir --cache-dir=$cache_dir --tar-dir=$tar_dir --tar-random=100 --tar-min-size=32GiB --tar-encrypt=$encrypt_key &
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
