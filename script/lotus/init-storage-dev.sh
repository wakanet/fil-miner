#!/bin/sh

kind=$1
if [ -z "$kind" ]; then
    echo "need input first argument 'staging' or 'unsealed' or 'sealed'" for kind
    exit
fi
mode=$2
if [ -z "$mode" ]; then
    echo "need input second argument 'custom' or 'nfs' or 'fstar'" or 'pb-storage' for mode
    exit
fi

# about nfs option
# http://blog.sina.com.cn/s/blog_605f5b4f0102uwy7.html
# https://qastack.cn/unix/31979/stop-broken-nfs-mounts-from-locking-a-directory
# soft,timeo=5,retrans=5,actimeo=10,retry=5 实测为6秒超时
# soft,timeo=7,retrans=5,actimeo=10,retry=5 实测为12秒超时
# soft,timeo=7,retrans=10,actimeo=10 实测为18秒超时
# soft,timeo=7,retrans=15,actimeo=10 实测有的5分钟超时
### 配置/etc/exports(可选)
#lotus-storage会自动配置此值，但若已配置过时，lotus-storage不会再配置，因此若手工配置过，仍需手工配置
#
#只读手工配置如下, 默认启动lotus-storage后会自动配置
#```
#/data/zfs *(ro,sync,insecure,no_root_squash)
##/data/zfs1 *(ro,sync,insecure,no_root_squash)
##/data/zfs2 *(ro,sync,insecure,no_root_squash)
#```
#
#可写配置如下，注意可写时无有效的安全删除防护, 启用lotus-storage后已不再使用以下nfs配置
#```
#/data/zfs *(rw,sync,insecure,no_root_squash)
#```

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
sealedAuth="lotus-sealed-1:BC894282F3131961E80584784D2D6A41"
unsealAuth="lotus-unseal-1:9B903B22392EF60AE4FB04A1B299972A"

sudo mkdir -p /data/zfs/lotus-user-1/sealed
sudo mkdir -p /data/zfs/lotus-user-1/unseal
sudo mkdir -p /data/zfs/lotus-user-1/staging
sudo mkdir -p /data/nfs/lotus-user-1

# for local, 1TB limit, when need to scale, see ./miner.sh fstar-storage scale --help
netip=$(ip a | grep -Po '(?<=inet ).*(?=\/)'|grep -E "^10\.") # only support one eth card.
for ip in $netip
do
    netip=$ip
    break
done
if [ -z $netip ]; then
    netip=127.0.0.1
fi
#netip=10.68.1.18

case $kind in
    "staging")
        ## add staging storage, kind for custom, nfs, fstar-storage
        ## need make a ln -s $MINER_REPO/staging/deal-staging $MOUNT_PATH/deal-staging
        ##========================================================##
        case $mode in
            "custom")
            ./miner.sh fstar-storage add --kind=2 --mount-type="custom" --mount-dir="/data/nfs/lotus-user-1" --mount-signal-uri="custom" --max-size=112589990684262400 --sector-size=35433480192 --max-work=100000
            echo "success."
            echo "for miner, need 'ln -s [the mount point] /data/nfs/lotus-user-1/[storage-id]' by manually"
            echo "for worker, need 'ln -s [the mount point] /data/lotus-push/[storage-id]' by manually"
            ;;
        
            "nfs")
            ./miner.sh fstar-storage add --kind=2 --mount-type="nfs" --mount-opt="-o vers=3,rw,nolock,intr,proto=tcp,rsize=1048576,wsize=1048576,hard,timeo=7,retrans=10,actimeo=10,retry=5" --mount-signal-uri="$netip:/data/zfs/lotus-user-1/staging" --mount-transf-uri="$netip:/data/zfs/lotus-user-1/staging" --mount-dir="/data/nfs/lotus-user-1" --max-size=112589990684262400 --sector-size=35433480192 --max-work=100
            ;;
        
            "fstar")
            ./miner.sh fstar-storage add --kind=2 --mount-type="fstar-storage" --mount-signal-uri="$netip:/data/zfs/lotus-user-1/staging" --mount-transf-uri="$netip:1331" --mount-dir="/data/nfs/lotus-user-1" --mount-auth-uri="$netip:1330" --max-size=-1 --sector-size=35433480192 --max-work=100 --mount-auth=$unsealAuth
            ;;
            "pb-storage")
            ./miner.sh fstar-storage add --kind=2 --mount-type="pb-storage" --mount-signal-uri="pb-storage" --mount-dir="/data/nfs/lotus-user-1" --mount-auth="username=b&token=d" --max-size=112589990684262400 --sector-size=35433480192 --max-work=100
            ;;
            "*")
                echo "only support 'custom','nfs','fstar','pb-storage' mode for staging"
            ;;
        esac
        ;;
    "unsealed")
        ## add unsealed storage, kind for custom, nfs, fstar-storage
        ##========================================================##
        case $mode in
            "custom")
            ./miner.sh fstar-storage add --kind=1 --mount-type="custom" --mount-dir="/data/nfs/lotus-user-1" --mount-signal-uri="custom" --max-size=112589990684262400 --sector-size=35433480192 --max-work=100000
            echo "success."
            echo "for miner, need 'ln -s [the mount point] /data/nfs/lotus-user-1/[storage-id]' by manually"
            echo "for worker, need 'ln -s [the mount point] /data/lotus-push/[storage-id]' by manually"
            ;;
        
            "nfs")
            ./miner.sh fstar-storage add --kind=1 --mount-type="nfs" --mount-opt="-o vers=3,rw,nolock,intr,proto=tcp,rsize=1048576,wsize=1048576,hard,timeo=7,retrans=10,actimeo=10,retry=5" --mount-signal-uri="$netip:/data/zfs/lotus-user-1/unseal" --mount-transf-uri="$netip:/data/zfs/lotus-user-1/unseal" --mount-dir="/data/nfs/lotus-user-1" --max-size=112589990684262400 --sector-size=35433480192 --max-work=100
            ;;
        
            "fstar")
            ./miner.sh fstar-storage add --kind=1 --mount-type="fstar-storage" --mount-signal-uri="$netip:/data/zfs/lotus-user-1/unseal" --mount-transf-uri="$netip:1331" --mount-dir="/data/nfs/lotus-user-1" --mount-auth-uri="$netip:1330" --max-size=-1 --sector-size=35433480192 --max-work=100 --mount-auth=$unsealAuth
            ;;
            "*")
                echo "only support 'custom','nfs','fstar' mode for staging"
            ;;
        esac
        ;;
    "sealed")
        ## add sealed storage, kind for custom, nfs, fstar-storage
        ##========================================================##
        # 1PB capacity
        case $mode in
            "custom")
            ./miner.sh fstar-storage add --kind=0 --mount-type="custom" --mount-dir="/data/nfs/lotus-user-1" --mount-signal-uri="custom" --max-size=112589990684262400 --sector-size=35433480192 --max-work=100000
            echo "success."
            echo "for miner, need 'ln -s [the mount point] /data/nfs/lotus-user-1/[storage-id]' by manually"
            echo "for worker, need 'ln -s [the mount point] /data/lotus-push/[storage-id]' by manually"
            ;;
        
            "nfs")
            ./miner.sh fstar-storage add --kind=0 --mount-type="nfs" --mount-opt="-o vers=3,rw,nolock,intr,proto=tcp,rsize=1048576,wsize=1048576,hard,timeo=7,retrans=10,actimeo=10,retry=5" --mount-signal-uri="$netip:/data/zfs/lotus-user-1/sealed" --mount-transf-uri="$netip:/data/zfs/lotus-user-1/sealed" --mount-dir="/data/nfs/lotus-user-1" --max-size=112589990684262400 --sector-size=35433480192 --max-work=100
            ;;
        
        ## lotus-storage-0
            "fstar")
            ./miner.sh fstar-storage add --kind=0 --mount-type="fstar-storage" --mount-signal-uri="$netip:/data/zfs/lotus-user-1/sealed" --mount-transf-uri="$netip:1331" --mount-dir="/data/nfs/lotus-user-1" --mount-auth-uri="$netip:1330" --max-size=-1 --sector-size=35433480192 --max-work=100 --mount-auth=$sealedAuth
            ## lotus-storage-1 
            #./miner.sh fstar-storage add --kind=0 --mount-type="fstar-storage" --mount-signal-uri="$netip:/data/zfs1" --mount-transf-uri="$netip:1341" --mount-dir="/data/nfs" --mount-auth-uri="$netip:1340" --max-size=354334801920 --sector-size=35433480192 --max-work=100 # for lotus-storage-1
            ## lotus-storage-2
            #./miner.sh fstar-storage add --kind=0 --mount-type="fstar-storage" --mount-signal-uri="$netip:/data/zfs2" --mount-transf-uri="$netip:1351" --mount-dir="/data/nfs" --mount-auth-uri="$netip:1350" --max-size=354334801920 --sector-size=35433480192 --max-work=100 # fro lotus-storage-2
            ;;
            "*")
                echo "only support 'custom','nfs','fstar' mode for staging"
            ;;
        esac
        ;;
esac

#./miner.sh fstar-storage scale --storage-id=1 --max-size=1125899906842624
#./miner.sh fstar-storage scale --storage-id=2 --max-size=1125899906842624
