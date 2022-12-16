#!/bin/sh
export FIL_PROOFS_PARAMETER_CACHE="/data/cache/filecoin-proof-parameters/v28" 

if [ -z "$lotusrepo" ]; then
    echo "Not found env 'lotusrepo'"
    exit 0
fi
if [ -z "$filrepo" ]; then
    echo "Not found env 'filrepo'"
    exit 0
fi

sudo $PRJ_ROOT/apps/lotus/lotus-shed --log-level=debug --repo=$lotusrepo --miner-repo=$filrepo "$@"

