#!/bin/sh

repodir=/data/sdb/lotus-user-3/.lotus-proxy
if [ ! -d $repodir ]; then
    repodir=/data/cache/.lotus3
fi
export lotusrepo=$repodir
export filrepo=/data/sdb/lotus-user-3/.lotusminer

echo "Change env to $lotusrepo"
echo "Change env to $filrepo"
