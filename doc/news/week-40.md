This Week in Lotus - Week 40 
Lotus的本周-第40周

Hey everyone and welcome to This Week in Lotus!
大家好，欢迎来到莲花的这个星期！
The stable release of Lotus v1.17.2 is now out 
Lotus v1.17.2的稳定版本现已发布
This feature release introduces the sector number management APIs in Lotus that enables all the Sealing-as-a-Service and Lotus interactions needed to function. Deep dive into the new APIs here: #9079 (comment). This version also raises the default propagation delay to 10 seconds for storage providers, so from now on you will see "baseDeltaSeconds": 10 as default in your lotus-miner logs.
此功能版本在Lotus中引入了扇区号管理API，它支持运行所需的所有Sealing-as-a-Service和Lotus交互。在这里深入了解新的API：#9079（注释）。此版本还将存储提供程序的默认传播延迟提高到10秒，因此从现在起，您将在lotus miner日志中看到“baseDeltaSeconds”：10 作为默认值。

The release has numerous other enhancements and bug fixes, so make sure to check out the full release notes here.
Please note that Lotus v1.17.2 will require a Go-version of v1.18.1 or higher!
该版本有许多其他增强功能和错误修复，因此请务必在此处查看完整的发行说明。
请注意，Lotus v1.17.2需要Go版本的v1.18.1或更高版本！

Features / Enhancements:
功能/配件：
A pull request to add the uptime of your lotus daemon to the lotus info command has been opened, and is currently in review.
We are currently testing the redundant chain nodes feature, and will test it over the next couple of weeks/month. If you feel adventurous and want to play with the feature early, here is a guide to how you can set it up in a local developer network.
将lotus守护进程的正常运行时间添加到lotus info命令的请求已经打开，目前正在审查中。
我们目前正在测试冗余链节点功能，并将在接下来的几周/几个月内对其进行测试。如果您觉得很冒险，想尽早使用该功能，这里有一个如何在本地开发人员网络中设置该功能的指南。

Protocol development:
协议实验室开发：
A second release candidate for builtin-actors v9.0.0 was released this week. We currently integrating the remaining work items of Network 17 into Lotus.
本周发布了内置actors v9.0.0的第二个候选版本。我们目前正在将Network 17的其余工作项集成到Lotus中。
Network version 17 is now deployed to the Butterfly network
网络版本17现已部署到Butterfly网络
The network will most likely be reset multiple times as we test out different network upgrade test cases.
当我们测试不同的网络升级测试用例时，网络很可能会重置多次。

As you may know by now, we are hosting a Lotus, data onboarding, and friends day on Nov 2nd in Lisbon! The registration for the event is finally open, and the schedule has been finalised. Come meet us in Lisbon, on Nov 2nd!
正如您现在所知，我们将于11月2日在里斯本举办Lotus、数据登录和好友日！该活动的登记工作终于开始了，日程安排也已经确定。请于11月2日在里斯本与我们见面！

Full schedule can be seen here: https://lotusandfriends.com/
可在此处查看完整的时间表：https://lotusandfriends.com/
Get your ticket to the event here: https://bit.ly/lotusnfriends
在此处获取活动门票：https://bit.ly/lotusnfriends
That´s it for the week! Have a great weekend!
本周到此为止！祝你周末愉快！

