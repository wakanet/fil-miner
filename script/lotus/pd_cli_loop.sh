#!/bin/sh

# depends on jq
# aptitude install jq

lotus_repo="/data/sdb/lotus-user-1/.lotus-proxy"
miner_repo="/data/sdb/lotus-user-1/.lotusminer"

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
            echo "count worker idle failed, idle:$idle,limit:$apLimit,disk:$diskUsed"
	    call_sleep
            continue
    fi
    if [ -z "$isAPLimit" ]; then
            echo "count worker idle failed, idle:$idle,limit:$apLimit,disk:$diskUsed"
	    call_sleep
            continue
    fi
    idleLimit=$(expr $idle - $apLimit)
    if [ $idleLimit -lt 0 ]; then
            echo "count worker idle failed, idle:$idle,limit:$apLimit,disk:$diskUsed"
	    call_sleep
            continue
    fi
    echo "idle:"$idle
    if [ $apLimit -gt 80 ]; then
            echo "count worker idle failed, idle:$idle,limit:$apLimit,disk:$diskUsed"
            call_sleep
            continue
    fi
    echo "ap-cur:"$apLimit

    if [ $diskUsed -gt 95 ]; then
            echo "count worker idle failed, idle:$idle,limit:$apLimit,disk:$diskUsed"
            call_sleep
            continue
    fi
    echo "disk-used:"$diskUsed

    echo "make propose"
    echo $(date --rfc-3339=ns)
    propose_out=$(../../bin/pd-cli propose --format json --market-scheduler-url $server_url --miner-multi-addr $miner_p2p --repo=$lotus_repo --ak-id=$ak_id --aks=$aks manual $miner)
    cid=$(echo $propose_out|/usr/bin/jq .ProposalCid|sed 's/\"//g')
    remoteUrl=$(echo $propose_out|/usr/bin/jq .RemoteUrl|sed 's/\"//g')
    if [ -z "$cid" ]; then
      echo "cid not found: $propose_out"
      call_sleep
      continue
    fi
    
    echo $(date --rfc-3339=ns)

    echo "fetch car:"$propose_out
    output="$cache_dir/$cid.car"
    ../../bin/pd-cli fetch $cid $remoteUrl $output
    if [ $? -ne 0 ]; then
      echo "fetch failed: $propose_out"
      exit
    fi
    
    echo $(date --rfc-3339=ns)

    echo "import-data:"$cid" "$output
    ../../apps/lotus/lotus-miner --repo=$lotus_repo --miner-repo=$miner_repo storage-deals import-data $cid $output
    if [ $? -ne 0 ]; then
      echo "import failed: $propose_out"
      exit
    fi

    echo $(date --rfc-3339=ns)

    echo "confirm:"$cid" "$remoteUrl
    ../../bin/pd-cli confirm $cid $remoteUrl
    if [ $? -ne 0 ]; then
      echo "confirm failed: $propose_out"
      exit
    fi

    echo "clean local:"$output
    rm $output
    echo "end"

    call_sleep
done

