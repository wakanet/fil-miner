#!/bin/sh

for i in `seq 1 200`
do
    echo "/data/nfs/$i"
    cd /data/nfs/$i
done
