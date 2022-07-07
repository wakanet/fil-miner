#!/bin/sh

backup_num=10 # 保留10份快照数据

bwlimit=$1
if [ -z "$bwlimit" ]; then
    bwlimit=61400
fi
echo "bwlimit set(KB/s): "$bwlimit 

while [ 1 ]
do
    echo "backup start: "$(date --rfc-3339=ns)
    #mkdir -p /data/lotus-backup

    # no backup for chain
    #if mountpoint -q /data/lotus-backup/.lotus
    #then
    #    rsync -Pat --delete-after --bwlimit=$bwlimit /data/cache/.lotus/ /data/lotus-backup/.lotus
    #else
    #    echo "/data/louts-backup/.lotus not mounted"
    #fi
    
    # mirror miner metadata.
    if mountpoint -q /data/lotus-backup/.lotusminer
    then
        rsync -Pat --delete-after --bwlimit=$bwlimit --exclude="unsealed" /data/sdb/lotus-user-1/.lotusminer/ /data/lotus-backup/.lotusminer
    else
        echo "/data/louts-backup/.lotusminer not mounted"
    fi

    # checksum snapshot
    type zfs 2>&1 >/dev/null
    if [ $? -eq 0 ]; then
        total=0
        snapname="auto-snap-"$(date --rfc-3339=date)
        exist_snap=""
        src=`zfs list -t snapshot|grep "lotusminer@auto-snap-"|cut -f 1 -d " "`
        for s in $src
        do
            total=$(($total+1))
            if [ -z $exist_snap ]; then
                exist_snap=`echo $s|grep "$snapname"`
            fi
        done
        # clean snapshot
        sub=$(($total-$backup_num))
        for s in $src
        do
            if [ $sub -lt 1 ]; then
                break
            fi
            sub=$(($sub-1))
    
            echo "delete $s"
            zfs destroy $s
        done
        # backup snapshot
        if [ -z "$exist_snap" ]; then
            src=$(zfs list -o name -t filesystem|grep "lotusminer")
            for s in $src
            do
                # 1天备份一次
                echo "backup "$s
                zfs snap $s@$snapname
                zfs list -o name,creation,used,refer,mountpoint
            done
        fi
    fi    

    echo "backup done: "$(date --rfc-3339=ns)
    sleep 60
done
