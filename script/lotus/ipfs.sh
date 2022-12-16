#!/bin/sh

if [ -z "$ipfsrepo" ]; then
    . env/ipfs-local.sh
fi

sudo IPFS_PATH=$ipfsrepo $PRJ_ROOT/bin/ipfs $@
