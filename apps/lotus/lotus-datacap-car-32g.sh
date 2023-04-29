#!/bin/sh

tar_dir=$1
if [ -z "$tar_dir" ]; then
    tar_dir="/data/lotus-datacap/tar-dir"
fi
car_dir=$2
if [ -z "$car_dir" ]; then
    car_dir="/data/lotus-datacap/car-dir"
fi
dbfile=$3
if [ -z "$dbfile" ]; then
    dbfile="/data/lotus-datacap/sqlite.db"
fi
remote_url="http://$(./ip.sh):9080"

./lotus-datacap car-srv \
    --tar-dir=$tar_dir \
    --car-dir=$car_dir \
    --gen-parallel=30 \
    --dbfile=$dbfile \
    --remote-url=$remote_url &
pid=$!
taskset -pc 30-95 $pid

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
