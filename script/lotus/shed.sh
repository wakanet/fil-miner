#!/bin/sh
export FIL_PROOFS_PARAMETER_CACHE="/data/cache/filecoin-proof-parameters/v28" 

sudo $PRJ_ROOT/apps/lotus/lotus-shed --log-level=debug "$@"

