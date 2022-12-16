#!/bin/sh

mounted=$(mount -l|grep "/data/nfs/"|cut -d " " -f 3)

for m in $mounted
do
    echo "umount "$m
    sudo umount -fl $m
done
