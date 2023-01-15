#!/bin/sh

src="/data/sdb/lotus-user-1/.lotusminer"
dest="/data/nfs/lotus-user-1/bak" # need mount the remote storage by manually
while true
do
    echo $(date --rfc-3339=ns)
    rsync -Pat --exclude="deal-staging" --exclude="dagstore" --exclude="journal" $src $dest
    echo $(date --rfc-3339=ns)
    echo "sleep 60"
    sleep 60
done

