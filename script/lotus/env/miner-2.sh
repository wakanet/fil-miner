#!/bin/sh

repodir=/data/sdb/lotus-user-2/.lotus-proxy
if [ ! -d $repodir ]; then
    repodir=/data/cache/.lotus2
fi
export lotusrepo=$repodir
export filrepo=/data/sdb/lotus-user-2/.lotusminer

echo "Change env to $lotusrepo"
echo "Change env to $filrepo"
