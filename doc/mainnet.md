# 生产主备部署(真实环境)

此为生产环境下使用的部署，使用此文档前应掌握debug.md文档部署.

# 目录
- [硬件要求](#硬件要求)
- [软件安装](#软件安装)
- [运行主节点](#运行主节点)
- [运行备节点](#运行备节点)
- [日常链快照](#日常链快照)
- [主备切换](#主备切换)
  - [日常切换](##日常切换)
  - [灾难切换](##灾难切换)
  - [存储替换](##存储替换)
- [升级节点](#升级节点)
- [灾难恢复](#灾难恢复)
  - [重建miner](#重建miner)

## 硬件要求
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
** 不需要root，但需要sudo权限 **

### 通用依赖安装
```
sudo aptitude install rsync chrony make mesa-opencl-icd ocl-icd-opencl-dev gcc bzr jq pkg-config curl clang build-essential libhwloc-dev
```

### 显卡驱动安装
因此当前版本要求使用CUDA进行算法运算，需要安装测试过的显卡驱动包.  
显卡驱动Nouveau安装失败的问题  
https://ld246.com/article/1378012262086
```
sudo su -
cd ~
wget https://developer.nvidia.cn/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=20.04&target_type=runfile_local

cp /etc/modprobe.d/nvidia-installer-disable-nouveau.conf ~/nvidia-installer-disable-nouveau.conf
echo "blacklist nouveau">/etc/modprobe.d/nvidia-installer-disable-nouveau.conf
echo "options nouveau modeset=0">/etc/modprobe.d/nvidia-installer-disable-nouveau.conf

update-initramfs -u
update-grub

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
```
# 下载release版的fil-miner-linux-amd64-mainnet-xxx.tar.gz
tar -xzf fil-miner-linux-amd64-mainnet-xxx.tar.gz
cd ~/fil-miner
. env.sh # 加载全局环境变量
./install.sh install
```

## 运行主节点

准备以下数据
```
/data/cache/filecoin-proof-parameters/v28/ # 需事先下载
/data/cache/.lotus # # 用已经有的或从快照中恢复
/data/sdb/lotus-user-1/.lotusminer # 复制已有的过来，没有需要通过init新建
```

运行程序
```
cd ~/fil-miner
. env.sh # 加载全局环境变量

rm etc/supd/apps/*.ini # 清除需要启动的进程
cp etc/supd/apps/tpl/lotus-daemon-1.ini etc/supd/apps # 准备lotus链进程
cp etc/supd/apps/tpl/lotus-user-1.ini etc/supd/apps # 准备miner进程
cp etc/supd/apps/tpl/lotus-user-wdpost.ini etc/supd/apps # 准备wdpost进程
cp etc/supd/apps/tpl/lotus-user-wnpost.ini etc/supd/apps # 准备wnpost进程

# 将以上配置文件加载到fil-miner中管理
filc reload
filc status # 确认有lotus-daemon-1, lotus-user-1, lotus-worker-wdpost, lotus-worker-wnpost

cd script/lotus/lotus-user
. env/lotus-1.sh
. env/miner-1.sh
filc start lotus-daemon-1
./tailf-lotus.sh # 确认日志正常
./lotus.sh sync status # 确认链同步正常
./lotus.sh wallet list # 确认钱包正常，没有就需要导入

filc start lotus-user-1
./tailf-miner.sh # 确认miner正常启动，需要几分钟校验参数包数据
./miner.sh info # 确认miner启动成功

filc start lotus-worker-wdpost # 启动单独的wdpost工人，以便可以专用显卡计算
filc start lotus-worker-wnpost # 启动单独的wnpost工人，此工人只会使用CPU计算，不会抢占GPU
```

## 运行备节点

准备以下数据
```
/data/cache/filecoin-proof-parameters/v28/ # 需事先下载
/data/cache/.lotus # # 用已经有的或从快照中恢复
/data/sdb/lotus-user-1/.lotusminer # 从主节点整个复制过来, 若主节点已损坏，需要走恢复流程, 详见[灾难恢复](#灾难恢复)
```

运行程序
```
cd ~/fil-miner
. env.sh # 加载全局环境变量

rm etc/supd/apps/*.ini # 清除需要启动的进程
cp etc/supd/apps/tpl/lotus-daemon-1.ini etc/supd/apps # 准备lotus链进程
cp etc/supd/apps/tpl/lotus-user-1.ini etc/supd/apps # 准备miner进程
cp etc/supd/apps/tpl/lotus-user-wdpost.ini etc/supd/apps # 准备wdpost进程
cp etc/supd/apps/tpl/lotus-user-wnpost.ini etc/supd/apps # 准备wnpost进程

# 将以上配置文件加载到fil-miner中管理
filc reload
filc status # 确认有lotus-daemon-1, lotus-user-1, lotus-worker-wdpost, lotus-worker-wnpost

cd script/lotus/lotus-user
. env/lotus-1.sh
. env/miner-1.sh
filc start lotus-daemon-1
./tailf-lotus.sh # 确认日志正常
./lotus.sh sync status # 确认链同步正常
./lotus.sh wallet list # 确认钱包正常，没有就需要导入

# 不需启动lotus-user-1，但要事先确认以下配置是正确的
/data/sdb/lotus-user-1/.lotusminer/config.toml
[API]地址指向本机

/data/sdb/lotus-user-1/.lotusminer/worker_api
指向主节点

filc start lotus-worker-wdpost # 连接主节点进行wdpost双计算保证主节点运行
filc start lotus-worker-wnpost #  连接主节点进行wnpost双计算保证主节点运行

filc status # 此时备节点运行: lotus-daemon-1, lotus-worker-wdpost, lotus-worker-wnpost
```
## 日常链快照
应找一台专用链机器，用于日常快照生成  
TODO: 更多细节

## 主备切换

### 日常主备切换
日常主备切换作用在于裁剪链、主备可用性验证操作，可定时执行。

切换前准备工作  
```
1. 确认链是正常的
2. 确认/data/sdb/lotus-user-1/.lotusminer/config.toml的API配置文件是本机的
3. 如果扇区在密封中，需停止密封后，从主节点上同步.lotusminer过来改, 否则需要因扇区数据不致需要走损坏恢复流程
```

备节点进行链裁剪
```
cd ~/fil-miner
. env.sh # 加载全局环境变量
cd script/lotus/lotus-user
. env/lotus-1.sh
. env/miner-1.sh

cd script/lotus/lotus-user
# 复制链快照到此目录下
cat export-chain.sh # 里边有恢复文档
filc stop lotus-daemon-1 # 停止原服务
filc status # 确认链已停止

mv /data/cache/.lotus/datastore /data/cache/.lotus/datastore.bak # 备份原链数据

./lotus.sh daemon --import-snapshot ./lotus_chain_20220705.car --halt-after-import # 导入快照
filc start lotus-daemon-1 # 启动链
filc status # 确认链已启动
./lotus.sh sync status #  确认链同步成功

# rm -rf /data/cache/.lotus/datastore.bak
```

开两个窗口，一个打开主节点，一个打开备节点  
```
# 一，在主节点上确认wdpost空窗期
cd ~/fil-miner
. env.sh # 加载全局环境变量
cd script/lotus/lotus-user
. env/lotus-1.sh
. env/miner-1.sh
./miner.sh proving info # 查阅当前的wdpost deadline进度
./tailf-miner.sh # 跟踪日志，在wdpost结果成功提交时(submitting .... success)
filc stop lotus-user-1 # 注意!!!!一定在wdpost结果提交成功后再执行


# 二，以下在备节点上操作
cd ~/fil-miner
. env.sh # 加载全局环境变量
cd script/lotus/lotus-user
. env/lotus-1.sh
. env/miner-1.sh

# 主节点stop命令调用后，立即启动备用节点的lotus-user-1, 一定要事先检查/data/sdb/lotus-user-1/.loutsminer/config.toml文件的正确性

filc start lotus-user-1
./tailf-miner.sh # 确认日志正常
filc status # 会显示lotus-worker-wdpost与lotus-worker-wnpost会自动启动起来

# 三，将主节改为备节点
# 改动/data/sdb/lotus-user-1/.lotusminer/config.toml指向本本，worker_api指向备用机, worker_api指向备用机后
# lotus-worker-wdpost, lotus-worker-wdpost会自动起来
＃可以切换成主节点上的备节点运行./miner.sh fstar-worker list进行确认

# 完成日常主备切换
```

### 灾难切换

参考[灾难恢复-重建miner](#参考重建miner)

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
wget https://github.com/wakanet/fil-miner/release/xxx.tar.gz

# 在fil-miner边上直接解压覆盖，注意:覆盖会对已存在的文件进行替换操作，请注意自行保存已修改过的文件
tar -xzf xxx.tar.gz # 会直接覆盖fil-miner文件目录

cd fil-miner
. env.sh
filc restart # 选择适当的重启时间窗口重启程序
```

## 灾难恢复

### 重建miner

当损坏已发生，不可恢复原.lotusminer数据时，按以下文档重建.lotusminer。

重建前主节点机器准备好软硬件环境，以及相关链
```
cd ~/fil-miner
. env.sh # 加载全局环境变量
cd script/lotus/lotus-user
. env/lotus-1.sh
. env/miner-1.sh

filc status # 确定lotus-user-1未运行
mv /data/sdb/lotus-user-1/.lotusminer /data/sdb/lotus-user-1/.lotusminer.bak

./miner.sh init --actor f0xxx --seal-service
# 关闭/data/sdb/lotus-user-1/.lotusminer/config.toml中的
[Subsystems]
  EnableMarkets = false
  EnableWnPoSt = false
  EnableWdPoSt = false

# 运行一个空服务的lotus-user-1
filc start lotus-user-1
filc start lotus-worker-wdpost
filc start lotus-worker-wnpost
./tailf-miner.sh # 确认启动
./miner.sh info # 确认信息正确
./miner.sh fstar-storage add --help # 导入原有存储, 原有多少存储原样导入
./miner.sh fstar-storage status # 确认存储正常
./miner.sh fstar-storage relink all # 从存储中重建扇区数据

# 开启/data/sdb/lotus-user-1/.lotusminer/config.toml中的
[Subsystems]
  EnableMarkets = true
  EnableWnPoSt = true
  EnableWdPoSt = true

filc restart lotus-user-1
./tailf-miner.sh # 确认启动日志正常

# 如果仍需要密封，此时需要重新设定扇区编号
./miner.sh fstar-sector set-start-id --help

# 完成恢复主节点运行后，按前面的构建恢复备节点运行
```

