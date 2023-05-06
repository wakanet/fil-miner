#!/bin/sh

# depends on jq
# aptitude install jq

lotus_repo="/data/sdb/lotus-user-1/.lotus-proxy"
miner_repo="/data/sdb/lotus-user-1/.lotusminer"

client_addr="f1csetl7nor3qie2cehx7axf2ai3nedmowj53xwsa"
server_url="http://10.72.88.63:10022"
miner_p2p="/ip4/10.72.88.71/tcp/12358"
ak_id="580ebae7-bbbe-4a05-a015-0efd3605d246"
aks="b0fc29dc-20c3-46d5-a05f-a344836027d2"
miner="f01983521"
cache_dir="/data/cache/dc-tmp"
sleep_sec=10

mkdir -p $cache_dir

call_sleep(){
  echo "sleep "$sleep_sec
  sleep $sleep_sec
}

while true
do
    echo $(date --rfc-3339=ns)

    idle=$(./miner.sh fstar-worker producer-idle)
    isIdle=$(echo "$idle"|sed -n "/^[0-9][0-9]*$/p")
    apLimit=$(./miner.sh pledge-sector get-limit-ap-cur)
    isAPLimit=$(echo "$apLimit"|sed -n "/^[0-9][0-9]*$/p")
    diskUsed=$(df /data --output=pcent|sed '1d'|sed 's/%//g'|awk '{printf $1}')

    if [ -z "$isIdle" ];then
            echo "idle failed, idle:$idle,limit:$apLimit,disk:$diskUsed"
	    call_sleep
            continue
    fi
    if [ $idle -lt 1 ]; then
            echo "no idle, idle:$idle,limit:$apLimit,disk:$diskUsed"
	    call_sleep
            continue
    fi
    if [ $diskUsed -gt 97 ]; then
            echo "disk failed, idle:$idle,limit:$apLimit,disk:$diskUsed"
            call_sleep
            continue
    fi
    if [ -z "$isAPLimit" ];then
            echo "ap limit not a number, idle:$idle,limit:$apLimit,disk:$diskUsed"
	    call_sleep
            continue
    fi
    idleLimit=$(expr $idle - $apLimit)
    if [ $idleLimit -lt 0 ]; then
            echo "apLimit more then the idles, idle:$idle,limit:$apLimit,disk:$diskUsed"
            call_sleep
            continue
    fi

    echo "make propose, idle:$idle,limit:$apLimit,disk:$diskUsed"
    echo $(date --rfc-3339=ns)
    propose_out=$(../../bin/pd-cli propose --format json --market-scheduler-url $server_url --miner-multi-addr $miner_p2p --repo=$lotus_repo --ak-id=$ak_id --aks=$aks manual $miner)
    propCid=$(echo $propose_out|/usr/bin/jq .ProposalCid|sed 's/\"//g')
    rootCid=$(echo $propose_out|/usr/bin/jq .RootCid|sed 's/\"//g')
    pieceCid=$(echo $propose_out|/usr/bin/jq .PieceCid|sed 's/\"//g')
    pieceSize=$(echo $propose_out|/usr/bin/jq .PieceSize|sed 's/\"//g')
    remoteUrl=$(echo $propose_out|/usr/bin/jq .RemoteUrl|sed 's/\"//g')
    if [ -z "$propCid" ]; then
      echo "cid not found: $propose_out"
      call_sleep
      continue
    fi
    
    echo "fetch car:"$propose_out
    echo $(date --rfc-3339=ns)
    output=$(./miner.sh fstar-market new-fstmp --really-do-it)
    ../../bin/pd-cli fetch $propCid $remoteUrl $output
    if [ $? -ne 0 ]; then
      echo "fetch failed: $propose_out"
      exit
    fi

    echo "record-deal:"$propCid" "$output
    echo $(date --rfc-3339=ns)
    ./miner.sh fstar-market record-deal $propCid $rootCid $pieceCid $pieceSize $client_addr $output
    
    echo "import-data:"$propCid" "$output
    echo $(date --rfc-3339=ns)
    ../../apps/lotus/lotus-miner --repo=$lotus_repo --miner-repo=$miner_repo storage-deals import-data $propCid $output
    if [ $? -ne 0 ]; then
      echo "import failed: $propose_out"
      exit
    fi

    echo "confirm:"$propCid" "$remoteUrl
    echo $(date --rfc-3339=ns)
    ../../bin/pd-cli confirm $propCid $remoteUrl
    if [ $? -ne 0 ]; then
      echo "confirm failed: $propose_out"
      exit
    fi

    echo "end"

    call_sleep
done
