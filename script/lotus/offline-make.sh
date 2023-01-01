#!/bin/sh

addr=$1
if [ -z "$addr" ]; then
    echo "address not found"
else
    #./miner.sh storage-deals set-ask --price 0.0000000 --verified-price 0.0000000 --min-piece-size 256B --max-piece-size 2KiB
    ./miner.sh storage-deals offline-make --from $addr --src-max-size=2048 --pack-interval=3 /tmp/file1.txt
    ./miner.sh storage-deals pending-publish --publish-now
    ls -lt /data/sdb/lotus-user-1/.lotusminer/deal-staging
fi

