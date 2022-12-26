#!/bin/sh

addr="t12n3tcxv4gsnpkfdq5qnbleje4gsmrmfwpfp4nia"

#./miner.sh storage-deals set-ask --price 0.0000000 --verified-price 0.0000000 --min-piece-size 256B --max-piece-size 2KiB
./miner.sh storage-deals offline-make --from $addr /tmp/files1.txt
