# 本地构建一个2k创世节点

安装lotus前置编译依赖

## 部署2k创世节点
```
cd ~
git clone https://github.com/free1139/lotus.git
cd lotus
git checkout devnet

./install.sh # 首次编译调用

./init-bootstrap.sh # 初始化创世数据

tail -f bootstrap-init.log # 直至显示'init done. using deploy-bootstrap.sh to deploy the daemons'

ctrl+c

./deploy-bootstrap.sh # 启动创世节点, 若失败，./clean-bootstrap.sh, 从./init-bootstrap.sh开始

sudo lotus sync status # 确认水龙头节点正常, 若失败，./clean-bootstrap.sh, 从./init-bootstrap.sh开始
sudo lotus wallet list # 确认水龙头节点有钱, 若失败，./clean-bootstrap.sh, 从./init-bootstrap.sh开始

# 得到以下两个devnet文件，
# 替换掉build/bootstrap与build/genesis下的相关文件重新编译lotus即可接入到devnet
#scripts/devnet.car
#scripts/devnet.pi

./install.sh debug # 得到devnet网络的lotus二进制文件(通过fil-miner部署)

```

