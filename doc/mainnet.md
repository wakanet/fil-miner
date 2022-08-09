# 生产主备部署

此为生产环境下使用的部署，使用此文档前应掌握debug.md文档部署.

# 目录
- [硬件要求](#硬件要求)
- [软件安装](#软件安装)
- [运行主节点](#运行主节点)
- [运行备节点](#运行备节点)
- [生成链快照](#生成链快照)
- [主备切换](#主备切换)
  - [主备链切换](##主备链切换)
  - [主备机切换](##主备机切换)
  - [存储机替换](##存储机替换)
- [升级节点](#升级节点)
- [灾难恢复](#灾难恢复)
  - [重建miner](#重建miner)
- [运行密封工人](#运行密封工人)

## 硬件要求
**此为32GB, 64GB扇区要求，模拟环境2KB扇区同debug.md的硬件要求**
```
两台真实miner主机, 配置：

CPU: AMD或Intel支持sha256运算的CPU, 最小核要求当前未验证，官方至少应4核以上

内存: 官方要求64GB以上，这里推荐256GB内存;

显卡: NVIDIA RTX 2080 TI, NVIDIA RTX 3080, NVIDIA RTX 3090都可以

SSD: 至少4T空间

存储机自定义, 支持nfs, fuse, CUSTOM模式
nfs, fuse会自动管理挂载, CUSTOM需要人工挂载，具体需要开发支持

密封机器自定义，应P1P2与C2分离
```

## 软件安装
**不需要root，但需要sudo权限**

### 通用依赖安装
```
sudo aptitude install rsync chrony make mesa-opencl-icd ocl-icd-opencl-dev gcc bzr jq pkg-config curl clang build-essential libhwloc-dev
```

### 显卡驱动安装
**2k环境不需要安装此显卡要求**

#### 在线安装
sudo aptitude install nvidia-driver-510-server

#### 本地安装
因此当前版本要求使用CUDA进行算法运算，需要安装测试过的显卡驱动包.  
显卡驱动Nouveau安装失败的问题  
https://ld246.com/article/1378012262086
```
sudo su -
cd ~
# 内网或通过官方下载驱动包, 以下是官方地址
wget https://developer.nvidia.cn/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=20.04&target_type=runfile_local

# 禁用nouveau, 不然显卡重启动会起不来。
cp /etc/modprobe.d/nvidia-installer-disable-nouveau.conf ~/nvidia-installer-disable-nouveau.conf
echo "blacklist nouveau">/etc/modprobe.d/nvidia-installer-disable-nouveau.conf
echo "options nouveau modeset=0">/etc/modprobe.d/nvidia-installer-disable-nouveau.conf
update-initramfs -u
#update-grub

./cuda_11.6.2_510.47.03_linux.run # 建议本nvidia官方包中的显卡驱动以便cuda尽可以兼容
# 或静默安装 ./cuda_11.6.2_510.47.03_linux.run --silent --driver --toolkit

nvidia-sm -L # 确认安装成功

# 如果还不能装，重启后再装
```


配置CUDA环境变量(/etc/profile)
```
export PATH=/usr/local/cuda-11.6/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-11.6/lib64:$LD_LIBRARY_PATH
```

### 下载主网的fil-miner
**2KB模拟环境不需要再下载此包，需要注意产生与模拟环境一个是mainnet版本，一个是debug版本。**
```
# 下载release版的fil-miner-linux-amd64-mainnet-xxx.tar.gz
# 在https://github.com/wakanet/fil-miner/release/找到下载包
tar -xzf fil-miner-linux-amd64-mainnet-xxx.tar.gz
cd ~/fil-miner
. env.sh # 加载全局环境变量
./install.sh install
```

## 运行主节点

准备以下数据
```
/data/cache/filecoin-proof-parameters/v28/ # 需事先下载, 2KB模拟环境可自动下载, 32GB, 64GB需要很大的参数包。
```

运行程序
```
cd ~/fil-miner
. env.sh # 加载全局环境变量

rm etc/supd/apps/*.ini # 清除需要启动的进程
cp etc/supd/apps/tpl/lotus-daemon-1.ini etc/supd/apps # 准备lotus链进程
cp etc/supd/apps/tpl/lotus-user-1.ini etc/supd/apps # 准备miner进程
cp etc/supd/apps/tpl/lotus-user-wnpost.ini etc/supd/apps # 准备wnpost进程
cp etc/supd/apps/tpl/lotus-user-wdpost.ini etc/supd/apps # 准备wdpost进程

# 将以上配置文件加载到fil-miner中管理
filc reload
filc status # 确认有lotus-daemon-1, lotus-user-1, lotus-worker-wnpost, lotus-worker-wdpost

cd script/lotus/lotus-user
. env/miner-1.sh
filc start lotus-daemon-1
./tailf-lotus.sh # 确认日志正常
./lotus.sh sync status # 确认链同步正常
./lotus.sh wallet list # 确认钱包正常，没有就需要导入

# 通过快照裁剪链(若链已正常，可跳过此步)
filc stop lotus-daemon-1
filc status # 确认链已关闭
mv /data/cache/.lotus/datastore /data/cache/.lotus/datastore.bak # 备份原链数据
./lotus.sh daemon --import-snapshot ./lotus_chain_20220705.car --halt-after-import # 导入快照, 参考`cat ./export-chain.sh`
filc start lotus-daemon-1 # 启动链
filc status # 确认链已启动

# 启动lotus-user-1进程
# 启动前需确认是新miner还是老miner
# 新miner需要参考debug.md文档进行./miner.sh init操作
# 老miner若有/data/sdb/lotus-user-1/.lotusminer的数据，复制过来到相同的目录下;
# 老miner若若没有.lotusminer目录的数据，则走后面章节的灾难重建流程
filc start lotus-user-1 # 注意启动此进程前已有.lotusminer目录的数据
./tailf-miner.sh # 确认miner正常启动，需要几分钟校验参数包数据
./miner.sh info # 确认miner启动成功

# 启动单独的wnpost工人, 当worker不存在时，lotus-user-1会使用内置的wnpost进行计算
filc start lotus-worker-wnpost 

filc status
 # 此时lotus-daemon-1, lotus-user-1, lotus-worker-wnpost正常运行中
 # lotus-worker-wdpost停止运行中，后面主备切换用到
```

## 运行备节点

准备以下数据
```
/data/cache/filecoin-proof-parameters/v28/ # 从主节点上复制过来或从专用下载机复制过来
```

运行程序
```
cd ~/fil-miner
. env.sh # 加载全局环境变量

rm etc/supd/apps/*.ini # 清除需要启动的进程
cp etc/supd/apps/tpl/lotus-daemon-1.ini etc/supd/apps # 准备lotus链进程
cp etc/supd/apps/tpl/lotus-user-1.ini etc/supd/apps # 准备miner进程
cp etc/supd/apps/tpl/lotus-user-wnpost.ini etc/supd/apps # 准备wnpost进程
cp etc/supd/apps/tpl/lotus-user-wdpost.ini etc/supd/apps # 准备wdpost进程

# 将以上配置文件加载到fil-miner中管理
filc reload
filc status # 确认有lotus-daemon-1, lotus-user-1, lotus-worker-wnpost, lotus-worker-wdpost

cd script/lotus/lotus-user
. env/miner-1.sh
filc start lotus-daemon-1
./tailf-lotus.sh # 确认日志正常
./lotus.sh sync status # 确认链同步正常
./lotus.sh wallet list # 确认钱包正常，没有就需要导入

# 通过快照裁剪链(若链已正常，可跳过此步)
filc stop lotus-daemon-1
filc status # 确认链已关闭
mv /data/cache/.lotus/datastore /data/cache/.lotus/datastore.bak # 备份原链数据
./lotus.sh daemon --import-snapshot ./lotus_chain_20220705.car --halt-after-import # 导入快照, 参考`cat ./export-chain.sh`
filc start lotus-daemon-1 # 启动链
filc status # 确认链已启动


# 构建/data/sdb/lotus-user-1/.lotusminer目录
# 方式一：
# 从主节点同步过来，这是常用方式一
# 方式二:
# 灾难重建，详见后面章节点的灾难重建


# 不需启动lotus-user-1，但要事先确认以下配置是正确的
# /data/sdb/lotus-user-1/.lotusminer/config.toml
# [API]
# listen: 地址指向本机

# 修改worker_api 指向主节点
vim /data/sdb/lotus-user-1/.lotusminer/worker_api

filc start lotus-worker-wdpost # 连接主节点进行wdpost计算，当备机异常时，主节点的lotus-user-1会自动承担起计算

filc status 
# lotus-daemon-1, lotus-worker-wdpost 运行中
# lotus-user-1, lotus-worker-wnpost 停止中备用中
```

## 生成链快照
因产生的链数据大，应找一台专用链机器，用于日常快照生成  

```
cd ~/fil-miner
. env.sh
cd script/lotus/lotus-user
. env/lotus-1.sh # 注意repo的路径
./export-chain.sh执行快照导出, 

#或参考./export-chain.sh生成新的脚本注意修改lotus可执行程序的位置指向
/root/fil-miner/apps/lotus/lotus --repo=/data/cache/.lotus chain export --recent-stateroots=900 --skip-old-msgs=true /data/download/lotus_chain_tmp.car
```

自动每天02点执行快照导出
```
crontab -e
0 14 * * * sh -x /data/download/export-chain.sh >>/data/download/export-chain.log # 注意改export-chain.sh里的为绝对路径
```

链快照裁剪
```
# 下载链快照
wget -c http://10.202.89.95:8081/download/lotus_chain_snapshot.car

# 确认当前链没有程序在用，关闭链程序; 
# 生产部署中若是主节点的链需要裁剪，应进行主备切换变备节点处于空闲后再裁减
cd ~/fil-miner
. env.sh

# 停止程序
filc status
filc stop lotus-daemon-1
filc status # 确认链程序停止(ps aux|grep "lotus"也可以确认)

# 导入快照
cd script/lotus/lotus-user
. env/lotus-1.sh # 注意repo路径
cat export-chain.sh
mv /data/cache/.lotus/datastore /data/cache/.lotus/datastore.bak # 备份原链数据
./lotus.sh daemon --import-snapshot ./lotus_chain_snapshot.car --halt-after-import # 导入快照
filc start lotus-daemon-1 # 启动链
filc status # 确认链已启动
./lotus.sh sync status #  确认链同步成

# 删除原链的块数据文件
rm -rf /data/cache/.lotus/datastore.bak
```

## 主备切换

**注意，主备切换时不能有密封任务进行中，否则数据可能不一致导致需要进行灾难重建**

### 日常链切换
日常主备基于主备机器都正常的情况下进行日常的主备链指向切换,
用在于裁剪链、主备可用性验证操作等定时执行的工作。

主备链切换只需将主节点与备节点的部署进程互换即可，切换应在wdpost空窗期进行

切换前备节点准备工作
**开两个窗口，一个打开主节点，一个打开备节点** 

确定主节点与备节点信息
```
# 确认miner使用的主节点链与备链节点位置
cd ~/fil-miner
filc status # 若lotus-user-1处于启动状态，则为主节点
cat /data/sdb/lotus-user-1/.lotus-proxy/api # 若有，则miner指向该链，否则cat /data/cache/.lotus/api
mkdir -p /data/sdb/lotus-user-1/.lotus-proxy/keystore
vim /data/sdb/lotus-user-1/.lotus-proxy/api # 将需要指向链的地址写入，可在/data/cache/.lotus/api得到该数据
vim /data/sdb/lotus-user-1/.lotus-proxy/token # 将需要指链的token写入，可在/data/cache/.lotus/token得到该数据
chmod 0600 /data/sdb/lotus-user-1/.lotus-proxy/token
cd ~/fil-miner/script/lotus/lotus-user
. env/miner-1.sh
./lotus.sh sync status # 确认指向的链可正常使用
./lotus.sh wallet list # 确认指向的链的对应miner钱包密钥存在
```

在shell 1上打开主节点连接，观察wdpost空窗期
```
cd ~/fil-miner
. env.sh # 加载全局环境变量
cd script/lotus/lotus-user
. env/miner-1.sh
./miner.sh proving info # 查阅当前的wdpost deadline进度

# 不熟悉时多观察几轮wdpost找节奏感觉
./tailf-miner.sh|grep "wdpost" # 跟踪wdpost日志，在wdpost结果成功提交时(submitting .... success)

filc restart lotus-user-1 # 注意!!!!一定在wdpost结果提交成功后再执行

### 主备机切换

主备机切换用于在主备机都正常的情况下，需要关闭一台机器时使用

**开两个窗口，一个打开主节点，一个打开备节点**

准备备机环境
```
# 1. 确认链是正常的, 且miner使用的私钥都存在
cd ~/fil-miner
. env.sh
cd script/lotus/lotus-user
. env/miner-1.sh
./lotus.sh sync status # 确认链同步正常
./lotus.sh wallet list # 确认miner对应的钱包密钥存在

# 2. 预启动备节点的miner信息，检查看是否能正常启动
# 备复主节点上的/data/sdb/lotus-user-1/.lotus-miner到同样的位置

# 3. 可选创建.lotus-proxy
mkdir -p /data/sdb/lotus-user-1/.lotus-proxy/keystore
vim /data/sdb/lotus-user-1/.lotus-proxy/api # 将需要指向链的地址写入，可在/data/cache/.lotus/api得到该数据
vim /data/sdb/lotus-user-1/.lotus-proxy/token # 将需要指链的token写入，可在/data/cache/.lotus/token得到该数据
chmod 0600 /data/sdb/lotus-user-1/.lotus-proxy/token
cd ~/fil-miner/script/lotus/lotus-user
. env/miner-1.sh
./lotus.sh sync status # 确认指向的链可正常使用
./lotus.sh wallet list # 确认指向的链的对应miner钱包密钥存在

# 4. 预启动miner节点校验是否可正常启动
cd ~/fil-miner
. env.sh
cd script/lotus/lotus-user
. env/miner-1.sh
# 修改miner的配置文件为无wdpost与无wnpost服务，并修改好启动的监听服务器
vim /data/sdb/lotus-user-1/.lotusminer/config.toml
# 全文替换: %s/原ip/本地局域网ip/g
# 修改配置文件中的子系统不起启以下这些服务
# [Subsystems]
#   EnableMarkets = false
#   EnableWnPoSt = false
#   EnableWdPoSt = false
# 退出vim :wq
filc start lotus-user-1
./tailf-miner.sh # 确认是否正常启动
./miner.sh info # 确认可以启动
./miner.sh fstar-storage status # 确认存储挂载正常
df -h # 确认存储挂载正常
filc stop lotus-user-1
filc status # 确认lotus-user-1停止
# 修改miner的配置文件回来
vim /data/sdb/lotus-user-1/.lotusminer/config.toml
# 修改配置文件中的子系统不起启以下这些服务
# [Subsystems]
#   EnableMarkets = true 
#   EnableWnPoSt = true
#   EnableWdPoSt = true
# 退出vim :wq
# 准备结束
```

切换主备机
```
# 一，在shell 1上打开主节点连接，在主节点上确认wdpost空窗期
cd ~/fil-miner
. env.sh # 加载全局环境变量
cd script/lotus/lotus-user
. env/miner-1.sh
./miner.sh proving info # 查阅当前的wdpost deadline进度

# 不熟时多观察几轮wdpost找节奏感觉
./tailf-miner.sh|grep "wdpost" # 跟踪wdpost日志，在wdpost结果成功提交时(submitting .... success)

filc stop lotus-user-1 # 注意!!!!一定在wdpost结果提交成功后再执行

# 二，在shell 2上打开备节点，以下在备节点上操作变主节点
cd ~/fil-miner
. env.sh # 加载全局环境变量
cd script/lotus/lotus-user
. env/miner-1.sh

# 等待主节点filc stop lotus-user-1命令调用后，
# 尽快启动备用节点的lotus-user-1,
filc stop lotus-worker-wdpost
filc start lotus-user-1
filc start lotus-worker-wnpost
./tailf-miner.sh # 确认日志正常
filc status  

# 三，在shell 1上，变更主节点为备节点
# 修改/data/sdb/lotus-user-1/.lotusminer/worker_api指向到新的主节点
filc start lotus-worker-wdpost

# 此时如一切正常，完成了主备切换
#
# 主节点filc status
# lotus-daemon-1 运行中, 停止为异常
# lotus-user-1 停止中，停止为异常
# lotus-worker-wnpost 运行中，可临时停卡，尽可能保持运行
# lotus-worker-wdpost 停止中，用备机的lotus-worker-wdpost代替计算，以便不与lotus-worker-wnpost同时冲突计算
#
# 备节点filc status
# lotus-daemon-1 运行中, 备用，可稍后进行关停裁剪
# lotus-user-1 停止中，备用
# lotus-worker-wnpost 停止中，备用
# lotus-worker-wdpost 运行中，应尽可能保持运行中，若停止，主节点上的wnpost与wdpost可能会计算冲突。
```


### 存储替换
当存储发布故障时，需要替换存储ip，或者临时退出挂载盘，可通过以下指令来完成,但因存储不同参数会有些变化，产生以实际挂载为准.

替换存储
```
# fstar-storage存储示例
./miner.sh search 旧ip
./miner.sh fstar-storage replace --storage-id=x --mount-type='fstar-storage' --mount-auth-uri="新ip:1330" --mount-transf-uri="新ip:1331" --mount-signal-uri="新ip:/data/zfs" 

# nfs存储示例
./miner.sh search 旧ip 
./miner.sh fstar-storage replace --storage-id=x --mount-signal-uri="新ip:/data/zfs" 
```

重挂载存储
```
./miner.sh search ip # 或者df -h, 或者mount 
./miner.sh mount id
```

重挂载存储
```
./miner.sh search ip # 或者df -h, 或者mount 
./miner.sh umount id
```

## 升级节点
以下为通用升级方式，特殊的再另行说明
```
# 注意版本号对应不同的包
cd ~
wget -c http://10.202.89.95:8081/download/fil-miner-linux-amd64-mainnet-v1.16.0-patch5.tar.gz


# 在fil-miner边上直接解压覆盖，注意:覆盖会对已存在的文件进行替换操作，请注意自行保存已修改过的文件
tar -xzf xxx.tar.gz # 会直接覆盖fil-miner文件目录

cd fil-miner
. env.sh
filc restart xxx # 选择适当的重启时间窗口重启需要升级的程序
```

## 灾难恢复

### 重建miner

当损坏已发生，不可恢复原.lotusminer数据时，按以下文档重建主节点.lotusminer数据。

重建前按主节点机器准备好软硬件环境, lotus-daemon-1必须已正常运行
```
cd ~/fil-miner
. env.sh # 加载全局环境变量
cd script/lotus/lotus-user
. env/miner-1.sh

filc status # 确定lotus-user-1未运行
mv /data/sdb/lotus-user-1/.lotusminer /data/sdb/lotus-user-1/.lotusminer.bak

./miner.sh init --actor f0xxx(已有miner编号) --seal-service
# # 修改/data/sdb/lotus-user-1/.lotusminer/config.toml配置文件
# [Subsystems]
#   EnableMarkets = false
#   EnableWnPoSt = false
#   EnableWdPoSt = false
# [MinerEnv]
#   # env var: LOTUS_MINERENV_SN
#   #SN = ""
#   # env var: LOTUS_MINERENV_SECTORHEAD
#   SectorHead = "s-f" # 确认是s-t还是s-f打头


# 运行一个空服务的lotus-user-1
filc start lotus-user-1
filc start lotus-worker-wdpost
filc start lotus-worker-wnpost
./tailf-miner.sh # 确认启动
./miner.sh info # 确认信息正确
./miner.sh fstar-storage add --help # 导入原有存储, 原有多少存储原样导入
./miner.sh fstar-storage status # 确认存储正常
./miner.sh fstar-storage relink all # 从存储中重建扇区数据

# # 修改/data/sdb/lotus-user-1/.lotusminer/config.toml配置文件为正常服务文件
# [Subsystems]
#   EnableMarkets = true
#   EnableWnPoSt = true
#   EnableWdPoSt = true

filc restart lotus-user-1
./tailf-miner.sh # 确认启动日志正常

# 如果仍需要密封任务，此时需要重新设定下一个扇区的编号值
./miner.sh fstar-sector set-start-id --help

# 完成恢复主节点运行后，按前面的构建恢复备节点运行
```

## 运行密封工人
### Precommit密封工人
#### 硬件要求
**此为32GB, 64GB扇区要求，模拟环境2KB扇区同debug.md的硬件要求**
```
CPU: AMD或Intel支持sha256运算的CPU, 这里为双座双核AMD7543 
内存: 官方要求64GB以上，这里为2TB内存;   
显卡: NVIDIA RTX 2080 TI, NVIDIA RTX 3080, NVIDIA RTX 3090都可以，这里为双卡RTX 3090  
SSD: 至少1T空间, 这里为4块8T SSD盘
```

#### 软件依赖
```
系统版本：20.04

sudo aptitude install rsync chrony make mesa-opencl-icd ocl-icd-opencl-dev gcc bzr jq pkg-config curl clang build-essential libhwloc-dev

显卡驱动安装参考前面的CUDA安装
```

#### 下载主网的fil-miner
**2KB模拟环境不需要再下载此包，需要注意产生与模拟环境一个是mainnet版本，一个是debug版本。**
```
# 下载release版的fil-miner-linux-amd64-mainnet-xxx.tar.gz
# 在https://github.com/wakanet/fil-miner/release/找到下载包
tar -xzf fil-miner-linux-amd64-mainnet-xxx.tar.gz
cd ~/fil-miner
. env.sh # 加载全局环境变量
./install.sh install
```

#### 运行28任务程序
```
mkdir -p /data/sdb/lotus-user-1/.lotusminer
cd /data/sdb/lotus-user-1/.lotusminer
# 从miner复制.lotusminer/worker_api与worker_token过来

cd ~/fil-miner
. env.sh
rm ./etc/supd/apps/*.ini
cp ./etc/supd/apps/tpl/lotus-worker-t28.ini ./etc/supd/apps/
filc reload
filc start lotus-worker-t28

# 在miner端校验
cd ~/fil-miner
. env.sh
cd script/lotus/lotus-user
. env/miner-1.sh
./miner.sh fstar-worker list
```


### Commit密封工人
#### 硬件要求
**此为32GB, 64GB扇区要求，模拟环境2KB扇区同debug.md的硬件要求**
```
CPU: AMD或Intel的CPU, 这里为未指定
内存: 官方要求64GB以上，这里为256GB内存;   
显卡: NVIDIA RTX 2080 TI, NVIDIA RTX 3080, NVIDIA RTX 3090都可以，这里为四卡RTX 3080  
存储: 无要求
```

#### 软件依赖
```
系统版本：20.04

sudo aptitude install rsync chrony make mesa-opencl-icd ocl-icd-opencl-dev gcc bzr jq pkg-config curl clang build-essential libhwloc-dev

显卡驱动安装参考前面的CUDA安装
```

#### 下载主网的fil-miner
**2KB模拟环境不需要再下载此包，需要注意产生与模拟环境一个是mainnet版本，一个是debug版本。**
```
# 下载release版的fil-miner-linux-amd64-mainnet-xxx.tar.gz
# 在https://github.com/wakanet/fil-miner/release/找到下载包
tar -xzf fil-miner-linux-amd64-mainnet-xxx.tar.gz
cd ~/fil-miner
. env.sh # 加载全局环境变量
./install.sh install
```

#### 运行4任务C2程序
```
mkdir -p /data/sdb/lotus-user-1/.lotusminer
cd /data/sdb/lotus-user-1/.lotusminer
# 从miner复制.lotusminer/worker_api与worker_token过来

cd ~/fil-miner
. env.sh
rm ./etc/supd/apps/*.ini
cp ./etc/supd/apps/tpl/lotus-worker-c2-0.ini ./etc/supd/apps/
cp ./etc/supd/apps/tpl/lotus-worker-c2-1.ini ./etc/supd/apps/
cp ./etc/supd/apps/tpl/lotus-worker-c2-2.ini ./etc/supd/apps/
cp ./etc/supd/apps/tpl/lotus-worker-c2-3.ini ./etc/supd/apps/
filc reload
filc start all

# 在miner端校验
cd ~/fil-miner
. env.sh
cd script/lotus/lotus-user
. env/miner-1.sh
./miner.sh fstar-worker list
```
