# 存储市场密封

## 涉及节点
```
* 发单机
* miner服务机
* worker机
* 存储机
```

## 配置miner机

启动链
```
* 启动lotus-daemon-1, 并导入对应的worker钱包地址
```

配置与启动miner服务(fil-miner/app/lotus/config-miner.toml)

miner端需要打开路由器穿透，要能访问到miner的libp2p端口
编辑$MINER-REPO/config.toml声明外部接入的miner的libp2p位置，打开路由器穿透，重启miner
```
#/data/sdb/lotus-user-1/.lotusminer/config.toml
[Libp2p]
ListenAddresses = ["/ip4/0.0.0.0/tcp/4359", "/ip6/::/tcp/4359"]
AnnounceAddresses = ["/ip4/公网/tcp/4359]
#  NoAnnounceAddresses = []
#  ConnMgrLow = 150
#  ConnMgrHigh = 180
#  ConnMgrGrace = "20s"
#

# 配置授权密钥(https://github.com/wakanet/lotus-grant.git)
[MinerEnv]
SN = ""
SectorHead = "s-t" # 配置扇区使用的前缀

[Subsystems]
EnableWnPoSt = false
EnableWdPoSt = false

# 编辑配置miner打包订单进行密封的的条件
[Dealmaking]
  ExpectedSealDuration = "72h0m0s"
  PublishMsgPeriod = "0h15m0s"
  MaxDealsPerPublishMsg = 8
  StartEpochSealingBuffer = 1440 # 12hours when epoch is 30s

[Sealing]
MaxWaitDealsSectors = 0
MaxSealingSectors = 0
MaxSealingSectorsForDeals = 0
MaxDealsPerSector = 1
WaitDealsDelay = "12h0m0s"
BatchPreCommits = true
MaxPreCommitBatch = 200
MinPreCommitBatch = 1
PreCommitBatchWait = "0h15m0s"
PreCommitBatchSlack = "0h15m0s"
AggregateCommits = true
MaxCommitBatch = 200
MinCommitBatch = 1
CommitBatchWait = "0h15m0s"
CommitBatchSlack = "0h15m0s"
CollateralFromMinerBalance = true # 启动miner质押

[Storage]
RemoteWorkerSeal = true
RemoteWorkerWnPoSt = 2
RemoteWorkerWdPoSt = 2
ForceRemoteWdPoSt = false
ForceRemoteWdPostPart=4
AllowAddPiece=false
AllowPreCommit1 = false
AllowPreCommit2 = false
AllowCommit = false
AllowUnseal = false
AllowReplicaUpdate = false
AllowProveReplicaUpdate2 = false
AllowRegenSectorKey = false
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

## 启动worker机
```
mkdir -p /data/sdb/lotus-user-1/.lotusminer
从miner上$MINERREPO拷贝以下两个文件到上述目录worker_api, worker_token
filc start lotus-worker-t24-2 # PC1机双卡24任务
filc start lotus-worker-t24-1 # PC1机单卡24任务
filc start lotus-worker-c2-0 # C2第一张卡
filc start lotus-worker-c2-1 # C2第二张卡
filc start lotus-worker-c2-2 # C2第三张卡
filc start lotus-worker-c2-3 # C2第四张卡
```

## 导入存储(详见script/lotus/init-storage-dev.sh)
```
/init-storage-dev.sh staging pb-storage # 此存储ID 1, 此模式要注意修改PC1机器下的fil-miner/apps/lotus/pb-cli.sh，实现car文件拉取和删除操作
/init-storage-dev.sh unsealed custom # 此模式要在PC1机器手动挂载存储到/data/lotus-push/2下, 此存储ID 2
/init-storage-dev.sh sealed custom # 此模式要在PC1机器手动挂载存储到/data/lotus-push/3下, 此存储ID 3
```

## 发单
根据发单机的订单接口进行调用, 详见fil-miner/script/lotus/deal-import-http.sh, deal-import-db.sh

## 启动定时发布密封消息
定时发布密封消息与处理消息池, 详见fil-miner/script/lotus/publish_seal_loop.sh
