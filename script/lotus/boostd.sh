#!/bin/sh

export PUBLISH_STORAGE_DEALS_WALLET="t3tbuojwaiecgcossdmryev7aih7auhvcm7ixh5mdqum755d32nwplew2sagva4dfovouxjolcwpsttg2rajha"
export COLLAT_WALLET="t3q73kgku2hzfai4lrf3svp6qwk2qnkxn6n5sqr7ajbe2gkjfzx3s5bvgihk3a5w6wr64woult4tc4zfrhobwa"

export FULLNODE_API_INFO="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBbGxvdyI6WyJyZWFkIiwid3JpdGUiLCJzaWduIiwiYWRtaW4iXX0.c9hsAqtdK3kgJMetPeWsWC_jaTq6gNieoDeZ_K-zPUw:/ip4/127.0.0.1/tcp/11234/http"
export MINER_API_INFO="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBbGxvdyI6WyJyZWFkIiwid3JpdGUiLCJzaWduIiwiYWRtaW4iXX0.NRXKhX3LeI9sVyy8ifCCKanSghNuLrla-FAeK4KwtCk:/ip4/127.0.0.1/tcp/2356/http"

export APISEALER=`echo $MINER_API_INFO`
export APISECTORINDEX=`echo $MINER_API_INFO`

#boostd --vv migrate-monolith \
#       --import-miner-repo=/data/sdb/lotus-user-1/.lotusminer \
#       --api-sealer=$APISEALER \
#       --api-sector-index=$APISECTORINDEX \
#       --wallet-publish-storage-deals=$PUBLISH_STORAGE_DEALS_WALLET \
#       --wallet-deal-collateral=$COLLAT_WALLET \
#       --max-staging-deals-bytes=50000000000

boostd --vv run

export BOOST_API_INFO=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBbGxvdyI6WyJyZWFkIiwid3JpdGUiLCJzaWduIiwiYWRtaW4iXX0.NRXKhX3LeI9sVyy8ifCCKanSghNuLrla-FAeK4KwtCk:/ip4/127.0.0.1/tcp/1288/http
