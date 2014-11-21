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
