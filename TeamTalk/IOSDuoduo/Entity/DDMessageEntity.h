//
//  DDMessageEntity.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ChattingModule;
@class DDDataInputStream;
typedef NS_ENUM(NSUInteger, DDMessageType)
{
    MESSAGE_TYPE_SINGLE =1,                 //单个人会话消息
    MESSAGE_TYPE_TEMP_GROUP  =2,                     //临时群消息.
};
typedef NS_ENUM(NSUInteger, DDMessageContentType)
{
    DDMessageTypeText = 1,
    DDMessageTypeVoice,
    DDMessageTypeImage,
    DDGroup_Message_TypeText=17,
    DDGroup_MessageTypeVoice=18,
};

typedef NS_ENUM(NSUInteger, DDMessageState)
{
    DDMessageSending =0,
    DDMessageSendFailure =1,
    DDmessageSendSuccess =2
};

//图片
#define DD_MESSAGE_IMAGE_PREFIX             @"&$#@~^@[{:"
#define DD_MESSAGE_IMAGE_SUFFIX             @":}]&$~@#@"

//语音
#define VOICE_LENGTH                        @"voiceLength"
#define DDVOICE_PLAYED                      @"voicePlayed"

//voice
#define DD_IMAGE_LOCAL_KEY                  @"local"
#define DD_IMAGE_URL_KEY                    @"url"

//商品
#define DD_COMMODITY_ORGPRICE               @"orgprice"
#define DD_COMMODITY_PICURL                 @"picUrl"
#define DD_COMMODITY_PRICE                  @"price"
#define DD_COMMODITY_TIMES                  @"times"
#define DD_COMMODITY_TITLE                  @"title"
#define DD_COMMODITY_URL                    @"URL"
#define DD_COMMODITY_ID                     @"CommodityID"

@interface DDMessageEntity : NSObject
@property(strong) NSString * msgID;           //MessageID
@property(nonatomic,assign) DDMessageType msgType;              //消息类型
@property(nonatomic,assign) NSUInteger msgTime;             //消息收发时间
@property(nonatomic,strong) NSString* sessionId;        //会话id，
@property(assign)NSUInteger seqNo;
@property(nonatomic,strong) NSString* senderId;         //发送者的Id,群聊天表示发送者id
@property(nonatomic,strong) NSString* msgContent;       //消息内容,若为非文本消息则是json
@property(nonatomic,strong) NSString* toUserID;     //发消息的用户ID
@property(nonatomic,strong) NSMutableDictionary* info;     //一些附属的属性，包括语音时长
@property(assign)DDMessageContentType msgContentType;
@property(nonatomic,strong) NSString* attach;
//@property(nonatomic,assign) BOOL isSend;
@property(nonatomic,assign) DDMessageState state;       //消息发送状态
- (DDMessageEntity*)initWithMsgID:(NSString *)ID msgType:(DDMessageType)msgType msgTime:(NSUInteger)msgTime sessionID:(NSString*)sessionID senderID:(NSString*)senderID msgContent:(NSString*)msgContent toUserID:(NSString*)toUserID;
+(DDMessageEntity *)makeMessage:(NSString *)content Module:(ChattingModule *)module MsgType:(DDMessageContentType )type;
+(DDMessageEntity *)makeMessageFromStream:(DDDataInputStream *)bodyData;
-(BOOL)isGroupMessage;
-(BOOL)isImageMessage;
-(BOOL)isSendBySelf;
@end
