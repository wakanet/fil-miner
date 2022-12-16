#!/bin/sh

if [ -z "$filrepo" ]; then
    echo "Not found env 'filrepo' using default"
    filrepo="/data/sdb/lotus-user-1/.lotusminer"
fi

kind=$1
if [ -z "$kind" ]; then
  kind="stderr"
fi
filc tail -f $(basename $(dirname $filrepo)) $kind
