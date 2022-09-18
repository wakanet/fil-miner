This Week in Lotus - Week 37 
本周在莲花-第37周

Hey everyone and welcome to This Week in Lotus!
大家好，欢迎来到本周的莲花！
The Lotus team is hosting our very first Lotus & Data onboarding & Friends Summit? @FilLisbon on Nov 2nd! There will be a lot of talks, workshops & panel from Lotus, Filecoin Crypto, Data onboarding team and more. Registration is opening soon!
Lotus团队正在主办我们的第一届Lotus&数据入职和朋友峰会@菲利斯本11月2日！将有许多来自Lotus、Filecoin加密、数据登录团队等的会谈、研讨会和小组讨论。注册即将开始！

Upcoming features/enhancements:
即将推出的功能/增强功能：
Sealing-as-a-service: The main piece for implementing all SaaS<->Lotus interactions needed for the service to work is now finalized and in review. For an updated comment on the current implementation status, and the sector number management APIs, check out this comment.
Sealing-as-a-service：实现服务工作所需的所有SaaS<->Lotus交互的主要部分现已完成并正在审查中。有关当前实现状态和扇区号管理API的更新评论，请查看此评论。
Redundant chain nodes: A PR for adding the raft consensus for lotus nodes in a cluster is now in review.
冗余链节点：目前正在审查为集群中的lotus节点添加raft共识的PR。
Both the above features are quite big PRs, so it will take some time to get them thoroughly reviewed. The lotus v1.17.2 code freeze where extended for a week, and is targeted early next week due to our goal of landing the Sealing-as-a-service enablement in that release.
以上两个特性都是相当大的PRs，因此需要一些时间才能彻底审查它们。lotus v1.17.2代码冻结将延长一周，由于我们的目标是在该版本中实现“密封即服务”功能，因此定于下周初。
An enhancement displaying the update & update-cache files in the lotus-miner storage list command has been merged.
在lotus miner存储列表命令中显示更新和更新缓存文件的增强功能已合并。

fixes:
修复：
A fix for the issue where available CC snap-up sectors being prematurely upgraded to UpdateReplica status is currently in review.
对于可用CC快照扇区过早升级为UpdateReplica状态的问题，目前正在进行修复。
The ability to send a terminate message with either an owner address or a worker address fixed an issue where the owner-address was a multi-signature owner.
发送具有所有者地址或工作者地址的终止消息的能力修复了所有者地址为多重签名所有者的问题。

Protocol development:
协议实验室开发：
A lot of work for implementing FIP0029 - Beneficiary address for SPs into Lotus happened this week:
本周在Lotus中实施FIP0029 SP受益人地址的大量工作：
Adding a CLI for changing the the beneficiary address.
添加用于更改受益人地址的CLI。
Adding beneficiary withdraw api and CLI, adding caller for actorWithdrawCmd was also included in this PR.
添加受益人撤销api和CLI，为actorWithdrawCmd添加调用方也包括在本PR中。

All community members are welcome to cast a vote on FIP0036 via FIL Poll to either approve or reject FIP0036. Read the announcement here.
欢迎所有社区成员通过FIL投票对FIP0036投赞成票或反对票。请阅读此处的公告。

That´s it for the week! Have a great weekend! 
本周就这样！周末愉快！

