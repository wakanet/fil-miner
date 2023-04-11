#!/bin/sh

src_dir=$1
if [ -z "$src_dir" ]; then
    src_dir="/data/lotus-datacap/src-dir"
fi
cache_pack=$2
if [ -z "$cache_pack" ]; then
    cache_pack="/data/lotus-datacap/cache-pack"
fi
cache_tar=$3
if [ -z "$cache_tar" ]; then
    cache_tar="/data/lotus-datacap/cache-tar"
fi
tar_dir=$4
if [ -z "$tar_dir" ]; then
    tar_dir="/data/lotus-datacap/tar-dir"
fi
encrypt_key_file=$5

mkdir -p $src_dir
mkdir -p $cache_pack
mkdir -p $cache_tar
mkdir -p $tar_dir

./lotus-datacap pack-srv \
	--src-dir=$src_dir \
	--cache-pack=$cache_pack \
	--cache-tar=$cache_tar \
	--tar-dir=$tar_dir \
	--tar-parallel=6 \
	--tar-random=10000 \
	--tar-min-size=16GiB \
	--tar-encrypt-file=$encrypt_key_file &
pid=$!
taskset -pc 0-29 $pid

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
