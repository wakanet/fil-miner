## 部署etcd集群
需要依赖于etcd集群  
*注意* etcd集群设计考虑为集群内使用，考虑性能问题并未设计鉴权接口，注意使用iptables防护

etcd集群用于分布式集群的配置或状态保存，  
详情请考阅官方文档：https://github.com/etcd-io/etcd/tree/release-3.4


### 部署节点


部署方式一:  
单机部署,  在同一台上启动etcd-0, etcd-1, etcd-2 
*注意*：此部署省硬件, 存在单机故障问题

部署方式二：  
集群部署，分别将etcd-0, etcd-1, etcd-2部署在三台不同的机器上。  
*注意*：此部署为最佳部署，但允许节点故障数不能超过一台。

部署方式一主备实现:  
*在miner机(10.0.20.2)上启动etcd*
```
## 在10.0.20.1上
# 配置/etc/hosts，  
10.0.20.2 boot0.etcd.local # 跟fil-miner/apps/lotus/etcd-0.sh有关
10.0.20.2 boot1.etcd.local # 跟fil-miner/apps/lotus/etcd-1.sh有关
10.0.20.2 boot2.etcd.local # 跟fil-miner/apps/lotus/etcd-2.sh有关

## 在10.0.20.2上
# 配置/etc/hosts，  
10.0.20.2 boot0.etcd.local # 跟fil-miner/apps/lotus/etcd-0.sh有关
10.0.20.2 boot1.etcd.local # 跟fil-miner/apps/lotus/etcd-1.sh有关
10.0.20.2 boot2.etcd.local # 跟fil-miner/apps/lotus/etcd-2.sh有关

# fil-miner
sudo zfs create data-zfs/etcd # 对两节点主份来说，实际上无法建立etcd集群，注意将数据放在miner的/data/zfs里以便提高数据可靠性
cd ~/fil-miner
. env.sh
cp ~/fil-miner/etc/fild/apps/tpl/etcd-0.ini fil-miner/etc/fild/apps/
cp ~/fil-miner/etc/fild/apps/tpl/etcd-1.ini fil-miner/etc/fild/apps/
cp ~/fil-miner/etc/fild/apps/tpl/etcd-2.ini fil-miner/etc/fild/apps/
filc reload
filc status
filc start etcd-0
filc start etcd-1
filc start etcd-2
```

部署方式二多节点实现:  
启动etcd
```
## 在10.0.20.1上
# 配置/etc/hosts，  
10.0.20.1 boot0.etcd.local # 跟fil-miner/apps/lotus/etcd-0.sh有关
10.0.20.2 boot1.etcd.local # 跟fil-miner/apps/lotus/etcd-1.sh有关
10.0.20.3 boot2.etcd.local # 跟fil-miner/apps/lotus/etcd-2.sh有关

cd ~/fil-miner
. env.sh
cp ~/fil-miner/etc/fild/apps/tpl/etcd-0.ini fil-miner/etc/fild/apps/
filc reload
filc status
filc start etcd-0

## 在10.0.20.2上
# 配置/etc/hosts，  
10.0.20.1 boot0.etcd.local # 跟fil-miner/apps/lotus/etcd-0.sh有关
10.0.20.2 boot1.etcd.local # 跟fil-miner/apps/lotus/etcd-1.sh有关
10.0.20.3 boot2.etcd.local # 跟fil-miner/apps/lotus/etcd-2.sh有关

cd ~/fil-miner
. env.sh
cp ~/fil-miner/etc/fild/apps/tpl/etcd-1.ini fil-miner/etc/fild/apps/
filc reload
filc status
filc start etcd-1

## 在10.0.20.3上
# 配置/etc/hosts，  
10.0.20.1 boot0.etcd.local # 跟fil-miner/apps/lotus/etcd-0.sh有关
10.0.20.2 boot1.etcd.local # 跟fil-miner/apps/lotus/etcd-1.sh有关
10.0.20.3 boot2.etcd.local # 跟fil-miner/apps/lotus/etcd-2.sh有关

cd ~/fil-miner
. env.sh
cp ~/fil-miner/etc/fild/apps/tpl/etcd-1.ini fil-miner/etc/fild/apps/
filc reload
filc status
filc start etcd-2
```

## 部署etcd网关
在需要使用etcd的机器上部署负载网关，本地通过网关方式接入到集群。
```shell
## 注意校验/etc/hosts配置是否已指向正确
#10.0.20.1 boot0.etcd.local # 跟fil-miner/apps/lotus/etcd-0.sh有关
#10.0.20.2 boot1.etcd.local # 跟fil-miner/apps/lotus/etcd-1.sh有关
#10.0.20.3 boot2.etcd.local # 跟fil-miner/apps/lotus/etcd-2.sh有关

cd ~/fil-miner
. env.sh
filc status

# 启动etcd网关
cp ~/fil-miner/etc/fild/apps/tpl/etcd-gw.ini fil-miner/etc/fild/apps/
filc reload
filc start etcd-gw # 链集群接入需要使用
cd ~/fil-miner/script/lotus/lotus-user
./etcdctl.sh endpoint status --cluster # 校验etcd集群是否都正常工作
```

## etcd灾难恢复
以下假定etcd-0为故障节点

方式一, 通过迁移方式恢复, 适用于数据未损坏的情况
```shell
# 注意修改所有节点的/etc/hosts

# 将/data/zfs/etcd/boot0.etcd复制到需要恢复新节点上, 重新启动即可
fild start etcd-0

# 在网关(etcd-gw)上校验
# 注意修改所有节点的/etc/hosts
cd ~/fil-miner/scripts/lotus/lotus-user/
./etcdctl.sh member list # 查etcd节点成员列表
./etcdctl.sh endpoint --cluster status # 同步成功时各endpoint的数据一致。
```

方式二，通过新建方式恢复，适用于数据已损坏的情况
```shell
# 注意修改所有节点的/etc/hosts

# 在网关(etcd-gw)上操作
cd ~/fil-miner/scripts/lotus/lotus-user/
./etcdctl.sh member list # 查询出原节点ID, 需要进行删除
./etcdctl.sh member remove [id]

sudo zfs create data-zfs/etcd # 数据会放在/data/zfs/etcd下，若未配置zfs可跳过这一步
sudo rm -r /data/zfs/etcd/boot0.etcd # 注意确认数据是否删除的

# 修改启动文件参数
vim ~/fil-miner/apps/lotus/etcd-0.sh
# 将其中的
# --initial-cluster-state new &
# 改为
# --initial-cluster-state existing &
fild start etcd-0

# 在网关(etcd-gw)上操作
./etcdctl.sh member list # 再次查询成员列表
./etcdctl.sh member add boot0 --peer-urls="http://boot0.etcd.local:2080" #peer-urls值等于当前节点的值
./etcdctl.sh member list # 查询到成功未启动(unstarted)
./etcdctl.sh member list # 查询到成员已启动(started)
./etcdctl.sh endpoint --cluster status # 查看数据同步，若未自动同步，需要分析日志
```

方式三，通过新建所有节点方式恢复，适用于etcd集群已不可用
重新构建etcd集群需要业务端自行修复数据
```shell
# 停止所有etcd-*服务
# 删除所有节点上的/data/zfs/etcd/boot*，若有。
# 重新启动所有etcd-*服务
```
