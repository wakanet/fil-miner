#!/bin/sh

if [ -z "$lotusrepo" ]; then
   . env/miner-1.sh
fi

sudo $PRJ_ROOT/apps/lotus/lotus-health --repo=$lotusrepo --miner-repo=$filrepo "$@"
