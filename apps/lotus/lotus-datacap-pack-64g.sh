#!/bin/sh

src_dir=$1
if [ -z "$src_dir" ]; then
    src_dir="/data/lotus-datacap/src-dir"
fi
tar_dir=$2
if [ -z "$tar_dir" ]; then
    tar_dir="/data/lotus-datacap/tar-dir"
fi
encrypt_key_file=$3

mkdir -p $src_dir
mkdir -p $tar_dir

./lotus-datacap pack-srv \
	--src-dir=$src_dir \
	--tar-dir=$tar_dir \
	--tar-parallel=6 \
	--tar-random=10000 \
    --tar-min-size=17GiB \
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
