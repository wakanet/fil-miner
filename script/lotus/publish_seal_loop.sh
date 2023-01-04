#!/bin/sh

addr="f3vxtiecaaydmjjqmvp5wbwxledzhauatgz5ciuuyn2kb3vjnrp6precafblqpv3vro4mlqzovbftgr5w7or2a"

while true
do
  echo $(date --rfc-3339=ns)
  ./miner.sh sectors batching precommit --publish-now
  ./miner.sh sectors batching commit --publish-now
  echo "sleep 600"
  sleep 600
  mpoolCur=$(./health.sh chain-mpool)
  if [ $mpoolCur -gt 30 ]; then
     echo "basefee is too hight, try rise the gas"
     ./lotus.sh mpool stat --local
     ./lotus.sh mpool fstar-fix --limit-msg=30 $addr
  fi
done
