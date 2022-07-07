# fil-miner部署文档

fil-miner部署依次阅读
```
doc/debug.md
doc/product.md
doc/advance.md
```

fild构建
```
go install github.com/gwaycc/supd/cmd/supd
mv bin/supd bin/fild
```

二进制发布
```
. env.sh
sup publish all
cd publish
tar -czf fil-miner-linux-amd64-mainnet-v1.xx.xx.tar.gz
```

lotus构建请阅读lotus源码中的开发文档
