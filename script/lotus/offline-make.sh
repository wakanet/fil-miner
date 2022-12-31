#!/bin/sh

addr="t1onitgabiphogjh6mg4b4pc2pg5cr42ayqfr5l7i"

#./miner.sh storage-deals set-ask --price 0.0000000 --verified-price 0.0000000 --min-piece-size 256B --max-piece-size 2KiB
./miner.sh storage-deals offline-make --from $addr --src-max-size=2048 --pack-interval=3 /tmp/file1.txt
./miner.sh storage-deals pending-publish --publish-now
