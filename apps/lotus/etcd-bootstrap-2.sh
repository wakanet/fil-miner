#!/bin/sh

netname="bootstrap2"
# need set bellow confiration to /etc/hosts
#127.0.0.1 discovery.etcd.com
#127.0.0.1 bootstrap0.etcd.com
#127.0.0.1 bootstrap1.etcd.com
#127.0.0.1 bootstrap2.etcd.com

netip=$(ip a | grep -Po '(?<=inet ).*(?=\/)'|grep -E "^10\.") # only support one eth card.
if [ -z $netip ]; then
    netip="127.0.0.1"
fi

./etcd --name $netname --initial-advertise-peer-urls http://$netip:2280 \
  --data-dir=/data/zfs/etcd/${netname}.etcd \
  --listen-peer-urls http://$netip:2280 \
  --listen-client-urls http://$netip:2279,http://127.0.0.1:2279 \
  --advertise-client-urls http://$netip:2279 \
  --initial-cluster-token etcd-cluster-1 \
  --initial-cluster bootstrap0=http://bootstrap0.etcd.com:2080,bootstrap1=http://bootstrap1.etcd.com:2180,bootstrap2=http://bootstrap2.etcd.com:2280 \
  --initial-cluster-state new &
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
