#!/bin/sh

# about nfs option
# http://blog.sina.com.cn/s/blog_605f5b4f0102uwy7.html
# https://qastack.cn/unix/31979/stop-broken-nfs-mounts-from-locking-a-directory
# soft,timeo=5,retrans=5,actimeo=10,retry=5 实测为6秒超时
# soft,timeo=7,retrans=5,actimeo=10,retry=5 实测为12秒超时
# soft,timeo=7,retrans=10,actimeo=10 实测为18秒超时
# soft,timeo=7,retrans=15,actimeo=10 实测有的5分钟超时

# 1GB: 1073741824
# 32GB: 34359738368
# 33GB: 35433480192
# 100GB: 107374182400
# 1TB: 1099511627776
# 8TB: 8796093022208
# 15TB: 163674416640
# 1PB: 1125899906842624

#./bchain-storage.sh --passwd="" sys adduser lotus-sealed-1
#./bchain-storage.sh --passwd="" sys adduser lotus-unseal-1
# 或者
#./bchain-storage.sh --passwd="" sys reset-passwd lotus-sealed-1
#./bchain-storage.sh --passwd="" sys reset-passwd lotus-unseal-1
sealedAuth="lotus-sealed-1:F4824A8F75194DFCD9C6CE2A8424C07C"
unsealAuth="lotus-unseal-1:180817a19ef76cb20c61e6116481d3a9"

# for local, 1TB limit, when need to scale, see ./miner.sh fstar-storage scale --help
netip=$(ip a | grep -Po '(?<=inet ).*(?=\/)'|grep -E "^10\.") # only support one eth card.
if [ -z $netip ]; then
    netip=127.0.0.1
fi
#netip=10.68.1.18

## add unsealed storage, kind for custom, nfs, fstar-storage
#./miner.sh fstar-storage add --kind=1 --mount-type="custom" --mount-dir="/data/nfs" --mount-signal-uri="-" --max-size=1125899906842624 --sector-size=35433480192 --max-work=100000

#./miner.sh fstar-storage add --kind=1 --mount-type="nfs" --mount-opt="-o vers=3,rw,nolock,intr,proto=tcp,rsize=1048576,wsize=1048576,hard,timeo=7,retrans=10,actimeo=10,retry=5" --mount-signal-uri="$netip:/data/zfs" --mount-transf-uri="$netip:/data/zfs" --mount-dir="/data/nfs" --max-size=1125899906842624 --sector-size=35433480192 --max-work=100

./miner.sh fstar-storage add --kind=1 --mount-type="fstar-storage" --mount-signal-uri="$netip:/data/zfs/lotus-user-1" --mount-transf-uri="$netip:1331" --mount-dir="/data/nfs/lotus-user-1" --mount-auth-uri="$netip:1330" --max-size=-1 --sector-size=35433480192 --max-work=100 --mount-auth=$unsealAuth

## add sealed storage, kind for custom, nfs, fstar-storage
# 1PB capacity
#./miner.sh fstar-storage add --kind=0 --mount-type="custom" --mount-dir="/data/nfs" --mount-signal-uri="-" --max-size=1125899906842624 --sector-size=35433480192 --max-work=100000

#./miner.sh fstar-storage add --kind=0 --mount-type="nfs" --mount-opt="-o vers=3,rw,nolock,intr,proto=tcp,rsize=1048576,wsize=1048576,hard,timeo=7,retrans=10,actimeo=10,retry=5" --mount-signal-uri="$netip:/data/zfs" --mount-transf-uri="$netip:/data/zfs" --mount-dir="/data/nfs" --max-size=1125899906842624 --sector-size=35433480192 --max-work=100

## lotus-storage-0
./miner.sh fstar-storage add --kind=0 --mount-type="fstar-storage" --mount-signal-uri="$netip:/data/zfs/lotus-user-1" --mount-transf-uri="$netip:1331" --mount-dir="/data/nfs/lotus-user-1" --mount-auth-uri="$netip:1330" --max-size=-1 --sector-size=35433480192 --max-work=100 --mount-auth=$sealedAuth
## lotus-storage-1 
#./miner.sh fstar-storage add --kind=0 --mount-type="fstar-storage" --mount-signal-uri="$netip:/data/zfs1" --mount-transf-uri="$netip:1341" --mount-dir="/data/nfs" --mount-auth-uri="$netip:1340" --max-size=354334801920 --sector-size=35433480192 --max-work=100 # for lotus-storage-1
## lotus-storage-2
#./miner.sh fstar-storage add --kind=0 --mount-type="fstar-storage" --mount-signal-uri="$netip:/data/zfs2" --mount-transf-uri="$netip:1351" --mount-dir="/data/nfs" --mount-auth-uri="$netip:1350" --max-size=354334801920 --sector-size=35433480192 --max-work=100 # fro lotus-storage-2

./miner.sh fstar-storage scale --storage-id=1 --max-size=1125899906842624
./miner.sh fstar-storage scale --storage-id=2 --max-size=1125899906842624
