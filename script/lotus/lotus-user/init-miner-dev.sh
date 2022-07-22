#!/bin/sh

#host="http://120.78.167.238:7777"
host="http://127.0.0.1:7777"
size=2048
#size=536870912 # 512MB
#size=34359738368 # 32G

walletAddr=$(./lotus.sh wallet new --encode=false bls)
echo $walletAddr
./lotus.sh sync wait

resp=$(curl -s $host"/send?address="$walletAddr)
./lotus.sh state wait-msg $resp
if [ $? -ne 0 ]; then
    echo "request failed: " $resp
    exit
fi
echo lotus-miner init --nosync --owner=$walletAddr --sector-size=$size
./miner.sh init --owner=$walletAddr --sector-size=$size
