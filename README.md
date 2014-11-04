### 公告
近期有很多热衷开源的geek们在问最新代码的更新日期，我们在此说明一下，由于近期工程师们都在备战双十一，开源的投入会相对减少，所以我们把提交最新代码的时间定在2014年11月18日，非常感谢大家对TeamTalk的关注和支持~具体安排如下：
* 11.11之前工程师全力备战双十一，请见谅
* 11.12～11.14 C++ Server, Java DB Proxy, PHP, android, iOS, Win Client代码移植, MAC Client延后（功能还未完全）
* 11.15～11.17 测试TeamTalk，包括PHP，android, iOS, Win Client 端功能走通，测试一键部署脚本
* 11.18  上传代码并正式发布


###项目背景
随着蘑菇街由导购向电商转型，蘑菇街自己的IM也应运而生，IM起初只是用于商家和买家之间沟通的工具。后面我们问自己，既然已经有了用于客服的IM，为什么不自己做一个IM，用于公司内部的沟通工具，来替换RTX呢，然后就有了TT(TeamTalk)的雏形，现在蘑菇街内部的IM工具都是TT来完成的。随着TT的逐渐完善，我们再次决定把TT开源，来回馈开源社区，我们希望国内的中小企业都能用上免费开源的IM内部沟通工具。

###ios客户端描述文档

TeamTalk是一套开源的企业办公即时通讯软件，作为整套系统的组成部分之一，IOS客户端为TeamTalk 客户端提供用户登录，消息转发及存储等服务。
目前IOS客户端支持的功能有
- 消息发送，
- 图片发送
- 拍照发送
- 多点登录功能
- 群聊功能


###结构设计描述

客户端主要依赖三个module，DDMessageModule，DDGroupModule，ContactsModule。

DDMessageModule 
主要负责消息的接收和存储功能，聊天界面的消息接收和最近联系人界面的消息接收都是从这个模块来的

DDGroupModule 
负责对最近联系群进行管理

ContactsModule 负责对最近联系人进行管理

DDTcpClientManager类负责TCP收发的管理

###开源协议
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html) 
