This Week in Lotus - Week 39 

Lotus的本周-第39周

Hey everyone and welcome to This Week in Lotus! <br/>
大家好，欢迎来到莲花的这个星期！<br/>

The second release candidate for the upcoming v1.17.2 was released this week.  Please note that Lotus v1.17.2 will require a Go-version of v1.18.1 or higher, so check which version you are on before upgrading!<br/>
即将发布的v1.17.2的第二个候选版本于本周发布。请注意，Lotus v1.17.2将需要1.18.1版或更高版本的Go，因此在升级之前请检查您使用的是哪个版本！<br/>

Features / Enhancements:<br/>
功能/配件：<br/>
Redundant chain nodes: We are getting closer to merging the PR that will enable support for redundant Lotus chain nodes. Going forward we will start testing it properly to see if we need additional tools to properly support the feature.<br/>
The requirement for checking parameters on startup has been disabled on lotus-miner nodes that have disabled all tasks (PoSt / C2 / PR2) that require the parameters. This makes startups much faster and reducing downtime when restarts are needed.<br/>
A work-in-progress tool that allows you to explore data on the Filecoin network was opened as a draft. It is uncertain if this tool will live in the Lotus codebase, but it was opened up as others might find it useful.<br/>
A PR to add retrieval deal ID and bytes transferred to the lotus client retrieve output has been merged.<br/>
冗余链节点：我们离合并PR越来越近，PR将支持冗余Lotus链节点。接下来，我们将开始对其进行适当的测试，看看是否需要其他工具来正确支持该特性。<br/>
在已禁用所有需要参数的任务（PoSt/C2/PR2）的lotus miner节点上，已禁用启动时检查参数的要求。这让初创公司受益匪浅在需要重启时更快并减少停机时间。<br/>
一个允许您浏览Filecoin网络上的数据的在建工具已作为草稿打开。不确定这个工具是否会存在于Lotus代码库中，但它是开放的，因为其他人可能会觉得它有用。<br/>
合并了用于添加检索交易ID和传输到lotus客户端检索输出的字节的PR。<br/>

fixes:<br/>
修复：<br/>
A fix to prevent Homebrew updates when release-candidates are published was merged this week. It now only updates for stable releases.<br/>
During testing of the v1.17.2-rc1/2 it was uncovered that the lotus-miner sectors renew --only-cc option does not apply when specifying sectors with a sector-file. A fix has been merged into master, and will be backported to v1.17.2.<br/>
本周合并了一个修复程序，用于在发布候选版本时阻止Homebrew更新。它现在只更新稳定版本。<br/>
在v1.17.2-rc1/2的测试过程中，发现lotusminer扇区更新——在使用扇区文件指定扇区时，仅cc选项不适用。修复程序已合并到主版本中，并将后移植到v1.17.2。<br/>

Protocol development:<br/>
协议实验室开发：<br/>
The first release candidate for builtin actors v9.0.0 for the network 17 (nickname: Shark) upgrade is out.<br/>
The first release candidate has been integrated into Lotus and testing will begin soon.<br/>
The beneficiary info has been added to the lotus-miner info command.<br/>
We hope everyone that attended FIL-Singapore had a good time! We are looking forward to see many of you @ FIL-Lisbon in approximately a month. Reminder that we will host a Lotus, data onboarding, and friends day on the 2nd of November, so save the date!<br/>
网络17（昵称：Shark）升级的内置actors v9.0.0的第一个候选版本已经发布。<br/>
第一个候选版本已经集成到Lotus中，测试将很快开始。<br/>
受益人信息已添加到lotus miner info命令中。<br/>
我们希望参加FIL新加坡的每一个人都过得愉快！我们期待着在大约一个月后在里斯本电影节上见到你们中的许多人。提醒您，我们将在11月2日举办Lotus、数据登录和好友日，所以请保存日期！<br/>

That´s it for the week! Have a great weekend!<br/>
本周到此为止！祝你周末愉快！<br/>

