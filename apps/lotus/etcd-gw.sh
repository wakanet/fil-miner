#!/bin/sh

../../bin/etcd gateway start --listen-addr=127.0.0.1:2379 --endpoints=boot0.etcd.local:2079,boot1.etcd.local:2179,boot2.etcd.local:2279 &
pid=$!

# set ulimit for process
nropen=$(cat /proc/sys/fs/nr_open)
echo "max nofile limit:"$nropen
echo "current nofile of $pid limit:"$(cat /proc/$pid/limits|grep "open files")
#prlimit -p $pid --nofile=$nropen
prlimit -p $pid --nofile=655350
if [ $? -eq 0 ]; then
    echo "new nofile of $pid limit:"$(cat /proc/$pid/limits|grep "open files")
else
    echo "set prlimit failed, command:prlimit -p $pid --nofile=$nropen"
    exit 0
fi

wait "$pid"
