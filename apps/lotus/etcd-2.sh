#!/bin/sh

netname="boot2"
# need set bellow confiration to /etc/hosts
#127.0.0.1 discovery.etcd.local
#127.0.0.1 boot0.etcd.local
#127.0.0.1 boot1.etcd.local
#127.0.0.1 boot2.etcd.local

netip="`/bin/sh ./ip.sh`"

../../bin/etcd --name $netname --initial-advertise-peer-urls http://$netip:2280 \
  --data-dir=/data/zfs/etcd/${netname}.etcd \
  --listen-peer-urls http://$netip:2280 \
  --listen-client-urls http://$netip:2279,http://127.0.0.1:2279 \
  --advertise-client-urls http://$netip:2279 \
  --initial-cluster-token etcd-cluster-1 \
  --initial-cluster boot0=http://boot0.etcd.local:2080,boot1=http://boot1.etcd.local:2180,boot2=http://boot2.etcd.local:2280 \
  --initial-cluster-state new &
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
