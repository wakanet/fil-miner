This Week in Lotus - Week 38

Lotus的本周-第38周

Hey everyone and welcome to This Week in Lotus! <br/>
大家好，欢迎来到Lotus的这个星期！<br/>

The first release candidate for Lotus v1.17.2 was released this week and is currently under testing by the SPX group. This version enables the sealing-as-a-service API in Lotus. This will allow builders to create sealing services on top of Lotus. If you have a special interest in that subject please check out the #fil-sealing-as-a-service channel. In addition to the SaaS-feature, the v1.17.2 release also includes a lot of bug fixes, enhancements and new features. You can read the full releaselog here.<br/>
Lotus v1.17.2的第一个候选版本于本周发布，目前正由SPX小组进行测试。此版本在Lotus中启用了sealing-as-a-service API。这将允许构建者在Lotus上创建密封服务。如果您对该主题有特殊兴趣，请查看#fil-saling-as-a-service频道。除了SaaS特性外，v1.17.2版本还包括许多错误修复、增强和新特性。你可以在这里阅读完整的发布日志。<br/>

Please note that Lotus v1.17.2 will require a Go-version of v1.18.1 or higher!<br/>
请注意，Lotus v1.17.2需要Go版本的v1.18.1或更高版本！<br/>

fixes 修复:<br/>
* A bug where running lotus-miner sectors update-state on a sector in the ReplicaUpdateFailed state caused the lotus-miner to crash. A fix to avoid the panic has been merged, and is also included in the v1.17.2-rc1 version.<br/>
* 在ReplicaUpdateFailed状态的扇区上运行lotus miner扇区更新状态的错误导致lotus minor崩溃。一个避免死机的修复程序已经合并，也包含在v1.17.2-rc1版本中。<br/>
* The FFI has been updated to fix an issue where sectors on read-only storage was skipped during windowPoSt. (This fix is also in v1.17.2-rc1)<br/>
* FFI已更新，以修复windowPoSt期间跳过只读存储器上的扇区的问题。（此修复也在v1.17.2-rc1中）<br/>
* A fix to revert the lotus-miner init default size back to 32GiB has been merged.<br/>
* 合并了将lotus-miner初始化默认大小恢复为32GiB的修复程序。<br/>
* A price-per-byte calculation fix for retrievals to make the calculation correct has been merged.<br/>
* 为使计算正确而对检索进行的每字节价格计算修正已合并。<br/>
* A regression on the master-branch caused the lotus state compute-state command to return too much information for it to unmarshal. The regression was fixed and is now in the master branch.<br/>
* 主分支上的回归导致lotus state compute state命令返回太多信息，无法解组。回归是固化的，现在在主分支中。<br/>

Protocol development 协议实验室开发:<br/>
A lot of work on implementing and integrating FIP0045 - De-couple verified registry from markets has happened this week:<br/>
本周，在实施和集成FIP0045 - De couple验证的市场注册方面进行了大量工作：<br/>
* On the builtin-actors side of the code, you can see all the work items finished this week here.<br/>
* 在代码的内置参与者端，您可以在这里看到本周完成的所有工作项。<br/>
* On the Lotus side:<br/>
* 在Lotus方面:<br/>
 > A PR to integrate the builtin-actors changes for FIP-0045 has been opened.<br/>
 > 一份整合FIP-0045内置参与者变更的PR已经开放。<br/>
 > Integrating DataCap actors into Lotus<br/>
 > 将DataCap参与者集成到Lotus中<br/>

N.B for Storage Providers: In v1.17.2 the default PropagationDelay has been raised from 6 seconds -> 10 seconds, and you can tune this yourself with an environment variable. That means you will now wait for 10 seconds for other blocks to arrive from the network before computing a winningPoSt (if eligible). In your lotus-miner logs that means you will see this "baseDeltaSeconds": 10 as default. You can read the full post about why this was raised here.<br/>
存储提供商的N.B：在v1.17.2中，默认的PropagationDelay已从6秒提高到10秒以上，您可以使用环境变量自行调整。这意味着您现在将等待10秒钟，等待其他块从网络到达，然后再计算winningPoSt（如果符合条件）。在您的lotusminer日志中，这意味着您将看到这个“baseDeltaSeconds”：10作为默认值。你可以阅读关于为什么在这里提出这个问题的完整帖子。<br/>

That´s it for the week! Have a great weekend! (edited) <br/>
本周到此为止！祝你周末愉快！<br/>

