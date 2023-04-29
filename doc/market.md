# 设定存储市场接单

miner端需要打开路由器穿透，要能访问到miner的libp2p端口

编辑config.toml声明外部接入的miner的libp2p位置，打开路由器穿透，重启miner
```
#/data/sdb/lotus-user-1/.lotusminer/config.toml
[Libp2p]
ListenAddresses = ["/ip4/0.0.0.0/tcp/4359", "/ip6/::/tcp/4359"]
#  AnnounceAddresses = []
#  NoAnnounceAddresses = []
#  ConnMgrLow = 150
#  ConnMgrHigh = 180
#  ConnMgrGrace = "20s"
#
```

编辑配置miner打包订单进行密封的的条件
```
#/data/sdb/lotus-user-1/.lotusminer/config.toml
[Dealmaking]
MaxDealsPerPublishMsg = 1
[Sealing]
MaxWaitDealsSectors = 0 # 不启用官方配置
MaxSealingSectors = 0 # 不启用官方配置
MaxSealingSectorsForDeals = 0 # 不启用官方配置

# 每扇区可存的订单数，达到此值或扇区已满时触发扇区打包
MaxDealsPerSector = 1 

# 若订单数长时间填不满一个扇区，超时后自动打包，不打开此配置默认为1小时
#  WaitDealsDelay = "0h15m0s"
```

向网络公开libp2p位置
```
./miner.sh net connect --bootstrap

./miner.sh actor set-addrs /ip4/外网ip/tcp/外网端口
```

验证miner libp2p端口是否可以访问
```
telnet ip port
```

# 从lotus客户端存入文件数据
```
./lotus.sh client query-ask [miner] # 验证miner是否可接单
./lotus.sh client import [文件] # 导入文件到本地链得到dataCid
./lotus.sh cilent dataCid, miner, price, duration # 提交交易
./lotus.sh client retrieve --provider=[minerID] [dataCid outputPath] # 检索完成存储的订单

# 更多请使用
./lotus.sh client --help
```

# 从fil-market导入数据

## WorkerSpace
```
src-dir/src -- the source file directory. BE CAREFUL, it will auto remove file by the program
src-dir/cache -- the packing cache directory, it will fetch data from src-dir
src-dir/src.lock -- src download lock file, can't pack when value is '1'
tar-dir/pack -- the packing result directory, it will remove the file after pack.
tar-dir/cache -- the tar file swapping directory, it will remove the file after swapped.
car-dir -- the car file directory, it generate car from tar-dir, and remove the cache-dir file when done. and support the car file for download.
sqlite.db -- the api server database, it record the download transcation.
```

## Deployment
```shell
lotus-datacap pack-srv # run then pack service to packing src files
lotus-datacap car-srv # run the car service to gen car files and support car api service

touch src/src.lock
echo -ne "1" > src/src.lock # lock the src dir when download data by manually
# download ...
echo -ne "0" > src/src.lock # after unlock the src.lock, the pack-srv and car-srv will auto run.

# SPEC:
# restart car-srv
# stop the car-srv
# mv tar-dir/cache/* tar-dir/pack
# start car-srv

```

## Client API

### make propose
Request
```
Uri: /deal/propose
Method: POST
Content-Type: application/x-www-form-urlencoded
BasicAuth:token=md5(ak-id)
Form: 
transfer-type=manual # only support manual type current
minerAddr=f01001 # miner id for deal propose
clientAddr=t1xxx # client address
```

Response(code 200)
```
Content-Type: application/json
Body:
{
  "ProposalCid":"",
  "RootCid":"",
  "PieceCid":"",
  "PieceSize":"",
  "RemoteUrl":"", // the download url
}
```

Response(code not 200)
```
Content-Type: text/plain
Body:
the message
```

Example
```shell
aptitude install jq

propose_out=$(`curl -s -d "transfer-type=manual&minerAddr=t01004&clientAddr=t1xxx&epochDur=1575360" http://127.0.0.1:9080/deal/propose`)
propCid=$(echo $propose_out|/usr/bin/jq .ProposalCid|sed 's/\"//g')
rootCid=$(echo $propose_out|/usr/bin/jq .RootCid|sed 's/\"//g')
pieceCid=$(echo $propose_out|/usr/bin/jq .PieceCid|sed 's/\"//g')
pieceSize=$(echo $propose_out|/usr/bin/jq .PieceSize|sed 's/\"//g')
remoteUrl=$(echo $propose_out|/usr/bin/jq .RemoteUrl|sed 's/\"//g')
if [ -z "$propCid" ]; then
  echo "cid not found: $propose_out"
  exit
fi
```


### Car file download
Request
```
Uri: /uuid.car
Method: GET
BasicAuth: md5(ak-id)
```
Respose(code 200)
```
Content-Type: application/octet-stream
```

Example
```shell
curl $remoteUrl -o tmp.car
```

### Confirm propose
Confirm the propose will done the request and release the car file.

Request
```
Uri: /deal/confirm
Method: POST
Content-Type: application/x-www-form-urlencoded
BasicAuth:token=md5(ak-id)
Form: 
propCid=xxx
remoteUrl=xxxx
```

Response(code 200)
```
ok
```

Example
```shell
curl -d "propCid=xxx&remoteUrl=xxx" "http://127.0.0.1:9080/deal/confirm"
```

## Sign API
call chain api
```
Uri: /chain/api
Method: POST
Content-Type: application/x-www-form-urlencoded
BasicAuth:token=md5(ak-id)
Form:
method=ClientStatelessDeal
params=urlencode # a serial json urlencode
```
support methods
```
ClientStatelessDeal -- Response {"PropCid":"","Verified":true}
```

## Example
```
run `lotus-datacap chain-srv`
run `lotus-datacap pack-srv`
run `lotus-datacap car-srv`

# make a propose
curl -s -d "minerAddr=t01005&clientAddr=t1j3qjyaauzhvtohwc4ztqrpw5qg2zdlyv7qlvffq&epochDur=518400" "http://127.0.0.1:9080/deal/propose"

# download car file
curl -o /tmp/tmp.car http://10.202.216.33:9080/40321968-bd38-44fa-9a6b-d74aa5794583.car

# import car file
lotus-miner storage-deals import-data bafyreift7dvqu4umhwwkemxj7lqoczwiqc7k6i3iqxzxdjx5jvm3cunkqa /tmp/tmp.car ""

# publish deals
lotus-miner storage-deals pending-publish

# confirm and delete car file
curl -d "propCid=bafyreift7dvqu4umhwwkemxj7lqoczwiqc7k6i3iqxzxdjx5jvm3cunkqa&remoteUrl=http://127.0.0.1:9080/40321968-bd38-44fa-9a6b-d74aa5794583.car" "http://127.0.0.1:9080/deal/confirm"
```
