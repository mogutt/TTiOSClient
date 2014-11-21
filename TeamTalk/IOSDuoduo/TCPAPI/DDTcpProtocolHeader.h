//
//  DDTcpProtocolHeader.h
//
//
//  Created by Michael Scofield on 2014-07-15.
//  Copyright (c) 2014 dujia. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <stdint.h>

enum
{
    DDSERVICE_LOGIN                 = 1,            //登录相关
    DDSERVICE_FRI                   = 2,            //好友相关
    DDSERVICE_MESSAGE               = 3,           //消息相关
    CMD_FRI_ALL_USER_REQ            = 14,               // 获取公司全部员工信息
    CMD_FRI_ALL_USER_RES            = 15,
    DDSERVICE_USER                  = 7
};
// 心跳包
enum
{
    DDHEARTBEAT_REQ                 = 1,
    DDHEARTBEAT_SID                 =7,
    REQ_CID                         =1,
    RES_CID                         =1
};

//MODULE_ID_LOGIN = 2   登陆相关
enum
{
    DDCMD_LOGIN_REQ_MSGSERVER                     = 1,                //获取消息服务器信息接口请求
    DDCMD_LOGIN_RES_MSGSERVER                     = 2,                //返回一个消息服务器的IP和端口
    DDCMD_LOGIN_REQ_USERLOGIN                     = 3,                //用户登录请求
    DDCMD_LOGIN_RES_USERLOGIN                     = 4,                //登陆消息服务器验证结果
    DDCMD_LOGIN_RES_USERLOGOUT                    = 6,                //这个目前不用实现
    DDCMD_LOGIN_KICK_USER                         = 7,                //踢出用户提示.
    
};

//MODULE_ID_FRIENDLIST = 3 成员列表相关
enum
{
    DDCMD_FRI_RECENT_CONTACTS_REQ     = 1,                //请求最近联系人
    DDCMD_FRI_SERVICE_LIST            = 2,                //店铺客服列表
    DDCMD_FRI_RECENT_CONTACTS_RES     = 3,                //最近联系人列表
    DDCMD_FRI_USERLIST_ONLINE_STATE   = 4,                //在线好友状态列表
    DDCMD_FRI_USER_STATE_CHANGE       = 5,                //好友状态更新通知
    DDCMD_FRI_USER_SERVICE_REQ        = 6,                //请求一个客服
    DDCMD_FRI_USER_SERVICE_RES        = 7,                //返回一个客服
    DDCMD_FRI_USER_ONLINE_STATE_REQ   = 8,                //获取某个用户的在线状态
    DDCMD_FRI_USER_ONLINE_STATE_RES   = 9,                //返回某个用户的在线状态
    DDCMD_FRI_LIST_DETAIL_INFO_REQ    = 18,               //批量获取用户详细资料
    DDCMD_FRI_LIST_DETAIL_INFO_RES    = 19                //批量放回用户详细资料
    
};

//MODULE_ID_SESSION = 80 消息会话相关
enum
{
    DDCMD_MSG_DATA                        = 1,            //收到聊天消息
    DDCMD_MSG_RECEIVE_DATA_ACK            = 2,            //消息收到确认.  这是收
    DDCMD_MSG_READ_ACK                    = 3,            //消息已读确认
    DDCMD_MSG_UNREAD_CNT_REQ              = 7,            //请求未读消息计数
    DDCMD_MSG_UNREAD_CNT_RES              = 8,            //返回自己的未读消息计数
    DDCMD_MSG_UNREAD_MSG_REQ              = 9,            //请求两人之间的未读消息
    DDCMD_MSG_HISTORY_MSG_REQ             = 10,           //请求两人之间的历史消息
    DDCMD_MSG_GET_2_UNREAD_MSG            = 14,           //返回两人之间的未读消息
    DDCMD_MSG_GET_2_HISTORY_MSG           = 15,           //查询两人之间的历史消息
};

//MODULE_ID_USERINFO = 1000
enum
{
    DDCMD_USER_INFO_REQ                     = 11,          //查询用户详情
    DDCMD_USER_INFO_RES                     = 10,           //返回用户详情
    
};

//群
enum
{
    CMD_ID_GROUP_LIST_REQ               = 1,    // 固定群
    CMD_ID_GROUP_LIST_RES               = 2,
    CMD_ID_GROUP_USER_LIST_REQ          = 3,
    CMD_ID_GROUP_USER_LIST_RES          = 4,
    CMD_ID_GROUP_UNREAD_CNT_REQ         = 5,
    CMD_ID_GROUP_UNREAD_CNT_RES         = 6,
    CMD_ID_GROUP_UNREAD_MSG_REQ         = 7,
    CMD_ID_GROUP_UNREAD_MSG_RES         = 8,
    CMD_ID_GROUP_HISTORY_MSG_REQ        = 9,
    CMD_ID_GROUP_HISTORY_MSG_RES        = 10,
    CMD_ID_GROUP_MSG_READ_ACK           = 11,
    CMD_ID_GROUP_CREATE_TMP_GROUP_REQ   = 12,
    CMD_ID_GROUP_CREATE_TMP_GROUP_RES   = 13,
    CMD_ID_GROUP_CHANGE_GROUP_REQ         = 14,
    CMD_ID_GROUP_CHANGE_GROUP_RES         = 15,
    CMD_ID_GROUP_DIALOG_LIST_REQ        = 16,   // 最近联系群
    CMD_ID_GROUP_DIALOG_LIST_RES        = 17,
    CMD_ID_FIXED_GROUP_CHANGED          =19,
    MODULE_ID_GROUP                     = 5
};
@interface DDTcpProtocolHeader : NSObject

@property (nonatomic,assign) UInt16 version;
@property (nonatomic,assign) UInt16 flag;
@property (nonatomic,assign) UInt16 serviceId;
@property (nonatomic,assign) UInt16 commandId;
@property (nonatomic,assign) UInt16 reserved;
@property (nonatomic,assign) UInt16 error;

@end
