#!/bin/sh

addr=$1
count=0

if [ -z "$addr" ]; then
    addr="f3rhyjgokmwicrvpzsaj3pqlorlxx56xlvx5uwiaf4ljbwostwlxh6gbzl76yd2h5lljreb6j4qzpmp3hocboq"
fi

while true
do
  echo $(date --rfc-3339=ns)
  ./miner.sh storage-deals pending-publish --publish-now
  ./miner.sh sectors batching precommit --publish-now
  ./miner.sh sectors batching commit --publish-now

  echo "sleep 100 or ctrl+c exit, count:$count"
  sleep 100
  ./lotus.sh mpool fstar-fix --only-feecap=true --rate-feecap=100000 --rate-limit=10000 --limit-feecap=0.00000001FIL --max-gas=50FIL --limit-msg=0 --really-do-it $addr 

  count=$(($count+1))
  echo "sleep 500 or ctrl+c exit, count:$count"
  sleep 500
  mpoolCur=$(./health.sh chain-mpool $addr)
  if [ $mpoolCur -gt 1 ]; then
      count=0
      echo "basefee is too hight, try rise the gas"
      ./lotus.sh mpool stat --local
      ./lotus.sh mpool fstar-fix --only-feecap=false --rate-feecap=100000 --rate-limit=10000 --limit-feecap=0.00000001FIL --max-gas=50FIL --limit-msg=0 --really-do-it $addr 
  fi
done
