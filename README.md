# fil-miner部署文档

fil-miner部署需要熟练掌握linux的运维知识, 本安装包本质是对各命令进行了集成再次封装。　　

文档不足的地方请善于使用--help文档，例如：lotus --help, lotus-miner --help

按以下顺序依次深入掌握
```
doc/debug.md
doc/product.md
doc/advance.md
```

本二进制发布指令
```

# 已安装了fild不需再二次拉取
go install github.com/gwaycc/supd/cmd/supd@latest
mv bin/supd bin/fild

# 发布apps/lotus，请参考开发文档使用./install.sh发布

# 打包
. env.sh
sup publish all
cd publish
tar -czf fil-miner-linux-amd64-mainnet-v1.xx.xx.tar.gz
```

