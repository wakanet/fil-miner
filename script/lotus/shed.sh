#!/bin/sh
export FIL_PROOFS_PARAMETER_CACHE="/data/cache/filecoin-proof-parameters/v28" 

sudo LOTUS_PATH=$lotusrepo $PRJ_ROOT/apps/lotus/lotus-shed --miner-repo=$filrepo --log-level=debug "$@"

