#!/bin/sh

#安装gluster客户端
#```shell
#add-apt-repository -y ppa:gluster/glusterfs-7
#aptitude install glusterfs-client
#```
#
#创建用户目录
#```shell
#mkdir -p /data/tmp
#mount -t glusterfs -o backup-volfile-servers=10.1.30.3:10.1.30.4:10.1.30.5:10.1.30.6 10.1.30.7:/nas /data/tmp
#mkdir -p [用户目录]
#umount -fl /data/tmp
#```

# 填写以上的用户目录
lotus_name="lotus-market"

./miner.sh fil-storage add --kind=0 --mount-type="glusterfs" --mount-opt="-o backup-volfile-servers=10.1.30.3:10.1.30.4:10.1.30.5:10.1.30.6" --mount-signal-uri="10.1.30.7:/nas/$lotus_name" --mount-dir="/data/nfs" --max-size=-1 --sector-size=35433480192 --max-work=100
./miner.sh fil-storage add --kind=1 --mount-type="glusterfs" --mount-opt="-o backup-volfile-servers=10.1.30.3:10.1.30.4:10.1.30.5:10.1.30.6" --mount-signal-uri="10.1.30.7:/nas/$lotus_name" --mount-dir="/data/nfs" --max-size=-1 --sector-size=35433480192 --max-work=100
