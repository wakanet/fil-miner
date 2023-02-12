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

从lotus客户端存入文件数据
```
./lotus.sh client query-ask [miner] # 验证miner是否可接单
./lotus.sh client import [文件] # 导入文件到本地链得到dataCid
./lotus.sh cilent dataCid, miner, price, duration # 提交交易
./lotus.sh client retrieve --provider=[minerID] [dataCid outputPath] # 检索完成存储的订单

# 更多请使用
./lotus.sh client --help
```
