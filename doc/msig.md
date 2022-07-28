# 设置钱包多签

多签当前只能用于miner的owner地址以及资金钱包，worker地址和wdpost control地址无法设定为多签. 
owner地址可以控制提现、设置worker地址(密封), control地址(wdpost).

## 创建多签帐户　
```shell
# 创建一个需要两个人操作的多签帐号，任意两个钱包密钥同意即可完成操作，其他地址用于备份机制
lotus msig create --required=2 addr1 addr2 addr3 ... 

# 返回帐户信息
# f01004 xxxxxx

# 查询多签帐户信息
lotus msig inspect f01004

# 添加或取消多签帐户下的钱包地址
lotus msig add-propose --help 增加请求钱包密钥
lotus msig add-approve --help 增加同意钱包密钥
lotus msig propose-remove --hep 删除签名用户
```

## 替换miner的owner为多签帐户
** 注意：替换后注意保存多签帐户的信息 **
```
# lotus-miner actor set-owner [command options] [newOwnerAddress senderAddress]
lotus-miner actor set-owner --really-do-it 新多签帐户(f01004) 原钱包 # 未设置多签前原钱包为普通钱包

# 提议通过新的请求
# lotus-shed miner-multisig propose-change-owner [command options] [newOwner]
lotus-shed miner-multisig --from 多签帐户的第一个签名地址 --miner=<minerid> --multisig=<多签帐户f01004> propose-change-owner f01004

# 查询提议的信息
lotus msig inspect f01004

# 通过提议
# lotus-shed miner-multisig approve-change-owner [command options] [newOwner txnId proposer]
lotus-shed miner-multisig --from 多签帐户的第二个签名地址 --miner=<minerid> --multisig=<多签帐户f01004> approve-change-owner f01004 0 多签帐户的第一个提议地址

# 提现以及其他miner的owner操作见lotus-shed miner-multisig --help
```

## 多签转账
```shell
# 提议转账
# lotus msig propose [command options] [multisigAddress destinationAddress value <methodId methodParams> (optional)]
lotus msig propose --from=多签帐号的第一个地址 多签帐号(f01004) 转入的钱包或ID 金额

# 同意转账
# lotus msig approve [command options] <multisigAddress messageId> [proposerAddress destination value [methodId methodParams]]
lotus msig propose --from=多签帐号的第二个或其他地址 多签帐号(f01004) 0 
```

