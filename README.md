# fil-miner部署文档

fil-miner部署需要熟练掌握linux的运维知识, 本安装包本质是对各命令进行了集成再次封装。　　

文档不足的地方请善于使用--help文档，例如：lotus --help, lotus-miner --help

本二进制发布指令
```

# 已安装了fild不需再二次拉取
go install github.com/gwaycc/supd/cmd/supd@latest
mv bin/supd bin/fild

# 使用lotus-storage
go install github.com/gwaycc/bchain-storage/cmd/bchain-storage@v1.0.0

# 使用etcd
go install github.com/gwaycc/etcd/cmd/etcd@v0.0.3
go install github.com/gwaycc/etcd/cmd/etcdctl@v0.0.3

# 使用ipfs
go install github.com/ipfs/kubo/cmd/ipfs@v0.16.0
go install github.com/Kubuxu/go-ipfs-swarm-key-gen/ipfs-swarm-key-gen@master

# 发布apps/lotus，请参考开发文档使用./install.sh发布，官方的版本请参阅doc/plworker.md。

# 打包
. env.sh
./publish.sh
cd publish
tar -czf fil-miner-linux-amd64-mainnet-v1.xx.xx.tar.gz
```

fstar部署
```
doc/0_instr.md
doc/1_debug.md # 单机部署
doc/2_mainnet.md # 主备部署
```

官方版本部署
```
doc/plworker.md
```

构建2k创世节点
```
doc/devnet.md
```

多签保护SP owner地址
```
doc/msig.md
```

