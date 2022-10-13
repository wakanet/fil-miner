This Week in Lotus - Week 36

在Lotus的这一周 - 第36周

Hey everyone and welcome to This Week in Lotus! <br/>
大家好，欢迎来到本周的Lotus！<br/>

Lotus v1.17.1 was released this week. One of the main features in the release is SplitStoreV2 (beta), which aims to reduce the node performance impact that’s caused by Filecoin’s large and continuously growing datastore. The release also includes many other features like storage path filtering, updating sector location, and detaching storage paths. You can read the full release notes here.<br/>
Lotus v1.17.1本周发布。该版本的主要功能之一是SplitStoreV2（测试版），旨在减少Filecoin的大型且持续增长的数据存储对节点性能的影响。该版本还包括许多其他功能，如存储路径过滤、更新扇区位置和分离存储路径。您可以在此处阅读完整的发行说明。

Upcoming features/enhancements:<br/>
Sealing-as-a-service: Supporting partially sealed sectors is close to done and being able to support potential sealing-as-a-service solutions. All the functionality is there and tested, it just need some finishing touches.<br/>
密封即服务：支持部分密封行业已接近完成，并能够支持潜在的密封即服务解决方案。所有的功能都已经测试过了，只需要一些最后的润色。<br/>

Redundant chain nodes: Integration of the raft consensus between multiple node into the existing APIs continued this week. Current results for keeping state in sync between multiple nodes are promising.<br/>
冗余链节点：本周继续将多节点之间的raft共识集成到现有API中。当前在多个节点之间保持状态同步的结果是有希望的。<br/>

Protocol development(协议实验室开发进度):<br/>
We are getting ready to implement FIP0045 - De-couple verified registry from markets in Lotus, you can track the open work items here. The TL;DR for FIP0045 is to enable the development of markets and market-like actors on the FVM, once user-programability is supported.<br/>
我们已经准备好在Lotus中实现FIP0045 - De-couple-verified-registry，您可以在这里跟踪打开的工作项。TL;DR 一旦用户可编程性得到支持，FIP0045将能够在FVM上开发市场和类似市场的参与者。<br/>

Migration for FIP0029 - Beneficiary address for SPs and FIP0034 - Fix pre-commit deposit independent of sector content for the upgrade to network 17 has landed.<br/>
FIP0029（SP的受益人地址）和FIP0034（独立于扇区内容的固定预提交保证金）的迁移已登陆网络17。<br/>

NB: If you are storage provider using Boost, check the Boost <> Lotus compatibility matrix before upgrading to v1.17.1.<br/>
注意：如果您是使用Boost的存储提供商，请在升级到v1.17.1之前检查Boost<>Lotus兼容性矩阵。<br/>

That´s it for the week! Have a great weekend! <br/>
本周就这样！周末愉快！<br/>

