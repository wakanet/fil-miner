This Week in Lotus - Week 35

本周在莲花-第35周

Hey everyone and welcome to This Week in Lotus!<br/>
大家好，欢迎来到本周的莲花！<br/>

Upcoming features/enhancements:<br/>
Sealing-as-a-service: A lot of work towards supporting partially sealed sectors imports happened this week, but there are still quite a lot to do. So by end of next week something mergeable that can be reviewed might be ready.<br/>
A lotus info command is currently in review, it gathers a lot of nice high level node status and metrics in one place.<br/>

即将推出的功能/增强功能：<br/>
* Sealing-as-a-service：本周在支持部分密封行业进口方面开展了大量工作，但仍有大量工作要做。所以，到下周末，一些可合并的、可以审查的东西可能已经准备好了。<br/>
* 增加lotus info,命令, 目前正在审查中，它在一个地方收集了许多高级节点状态和指标。<br/>

fixes:<br/>
A PR to ensure that connections between Boost and Lotus-workers computing DataCids is closed correctly has been merged.<br/>
A fix to ensure that the MAX_CONCURRENT environment variable for DataCid tasks is being enforced has been fixed.<br/>
Some smaller UX-improvements where also merged, like adding a better Ledger rejection error, and ability to specify the message sender in the lotus-miner actor set-addrs command.<br/>

BUG修复：<br/>
* 已合并一个PR，以确保Boost和Lotus workers计算数据CID之间的连接正确关闭。<br/>
* 已修复了一个修复程序，以确保正在执行DataCid任务的MAX_CONCURRENT环境变量。<br/>
* 一些较小的UX改进也被合并，如添加更好的分类账拒绝错误，以及在lotus miner actor set addrs命令中指定消息发送者的能力。<br/>

Protocol development:<br/>
In Lotus we are getting ready to implement FIP0029 - Beneficiary address for SPs, you can track the open work items here. The TL;DR for FIP0029 is introducing a separation of node control and financial control, to allow for more flexible Filecoin lending markets. You can read the full FIP here.<br/>
SplitStoreV2: We are tracking a potential issue where no automatic pruning is happening when ColdStoreType is set to universal and  EnableColdStoreAutoPrune = true.<br/>
FIL Lisbon now has a website, it will take place from Oct 30 - Nov 4, and the Lotus team will host a Lotus & Friends (friends from Boost, FIL-Crypto, FVM and so on) day on the 2nd of November. We will come back with an exact agenda and place later<br/>

协议实验室开发状态：<br/>
* 在Lotus中，我们准备实施FIP0029 -  供应商的受益人地址，您可以在此处跟踪未结工作项。FIP0029的TL;DR引入了节点控制和财务控制的分离，以允许更灵活的Filecoin借贷市场。你可以在这里阅读完整的FIP。<br/>

SplitStoreV2：我们正在跟踪一个潜在问题，当ColdStoreType设置为universal且EnableColdStoreAutoRune=true时，不会发生自动修剪。<br/>
FIL里斯本现在有一个网站，将于10月30日至11月4日举行，Lotus团队将于11月2日举办Lotus&Friends（来自Boost、FIL Crypto、FVM等的朋友）日。稍后，我们将带着确切的议程和地点回来<br/>

That´s it for the week! Have a great weekend!<br/>
本周就这样！祝大家有个伟大的周末!<br/>

