#!/bin/sh

repodir=/data/sdb/lotus-user-1/.lotus-proxy
if [ ! -d $repodir ]; then
    repodir=/data/cache/.lotus
fi
export lotusrepo=$repodir
export filrepo=/data/sdb/lotus-user-1/.lotusminer

echo "Change env to $lotusrepo"
echo "Change env to $filrepo"
