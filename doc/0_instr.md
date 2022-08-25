# 入门术语

## 各进程(或节点)关系图
```
                    lotus
                      |
                lotus-miner
      /               |                 \
  storage  lotus-worker(sealing)  lotus-worker(wdpost,wnpost)
```

## 术语说明
### lotus 链节点
```
    -- MessagePool(mpool)
       消息池，主要有两大类消息，通用消息(msgs), 块消息(blocks).
       链节点通过libp2p与节点通讯后，内置订阅指定频道的主题获得消息，
       首次启动链节点时，将与内置的启动节点(bootstrappers)进行连接通讯。

    -- VM(链内建的虚拟机模型)
       -- actor VM的帐号模型，内置有f0111,f099等这些，创建地址时实际以actor为地址。
                f打头为主网帐号类型，t打头为测试网帐号类型，但这只是一个显示类型，实际以数字编号为准。

    -- Wallet 钱包私钥
       钱包私钥构成，通过私钥可以得到公钥、通过公钥编号后生成钱包地址，反之逆推是极困难的。
       钱包地址以t1(f1),t3(f3)打头，但上链后实际会有一个actor地址进行对应用于存储余额。
       消息需要通过钱包签名且合法共识后才得到链VM的认可。
       -- secp256k1
          t1(f1)打头的钱包私钥，常用于存储市场消息签名, 速度较bls快
       -- bls
          t3(f3)打头的钱包私钥，常用于密封消息的签名，安全性高。

    -- Signer 签名器
       所有消息都是一个规范的json消息，通过钱包公钥对消息签名后publish到libp2p的主题中。

    -- Epoch 元周期
       Filecoin区块链是一个有向链，在固定的周期会生成一个消息块集合，Epoch值即为块高度值。

       -- Tipset
            Filecoin区块链的每一个Epoch高度的术语叫Tipset，一个Tipset由多个块(block)构成, 但也可能是空块。

           -- Block
            Filecoin区块单元，有出块权的矿工将生产一个区块，多个矿工可能会同一时间都会生产出块。
            矿工生产区块时，将打包消息池中的消息，并通过libp2p相关主题发布到整个网络中，各链节点解析并进行VM处理。
```

### storage 存储节点
```
    -- unsealed 未密封前或解封后的数据，以2KB, 512MB, 32GB, 64GB为单位，当前主网只支持32GB与64GB的扇区
    -- sealed 将原文件密封后的扇区数据, 大小与unsealed文件相同
    -- cache 密封证明的辅文件
```

### lotus-miner 矿工节点
```
    -- StorageProvider 存储接入
       -- Garbage 本地垃圾存入(空扇区)
       -- Market 通过交易传输存储数据
    -- StorageRetrieve 
    　　检索存入的数据，垃圾数据不可检索
    -- Sealer 密封器
       lotus-miner默认内置有一个工人密封器
       -- AddPiece 将数据添加到一个存储扇区
       -- Packing 将AddPiece打包完整的unsealed扇区，不足补空.
       -- Precommit1 预复制证明阶段1
       -- Precommit2 预复制证明阶段2
       -- Commit1 上链后的证明阶段校验1
       -- Commit2 上链后的证明阶段校验2
       -- Finalize 释放复制证明的cache文件至归档状态
       -- Unseal 解封Sealed数据
    -- Prover
        -- Window PoSt
           时空证明。只能过了时空证明的Sealed文件才是有效的存力文件。
           时空证明将所有sealed文件分为48个窗口进行计算，或计算失败，该窗口存力将无效。
        -- Winning PoSt
           出块主明。当达到指定的有效存力时，矿工可以参与出块选举，有效存力越高，概率越大。
           当矿工赢得选举权时，将对一个随机指定的sealed文件进行存储证明计算, 证明成功，打包块消息。
```      

### lotus-worker 工人节点
lotus-worker从lotus-miner中抽离出来优化的Sealer和Prover, 有不同的开发实现者。

