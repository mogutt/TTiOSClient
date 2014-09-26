//
//  DDMessageEntity.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ChattingModule;
typedef NS_ENUM(NSUInteger, DDMessageType)
{
    DDMessageTypeText = 1,
    DDMessageTypeVoice,
    DDMessageTypeImage,
    DDGroup_Message_TypeText=17,
    DDGroup_MessageTypeVoice=18,
};

typedef NS_ENUM(NSUInteger, DDMessageState)
{
    DDMessageSending,
    DDMessageSendFailure,
    DDmessageSendSuccess
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
@property(nonatomic,assign) NSUInteger msgID;           //MessageID
@property(nonatomic,assign) DDMessageType msgType;              //消息类型
@property(nonatomic,assign) NSUInteger msgTime;             //消息收发时间
@property(nonatomic,strong) NSString* sessionId;        //会话id，
@property(nonatomic,strong) NSString* senderId;         //发送者的Id,群聊天表示发送者id
@property(nonatomic,strong) NSString* msgContent;       //消息内容,若为非文本消息则是json
@property(nonatomic,strong) NSString* toUserID;     //发消息的用户ID
@property(nonatomic,strong) NSMutableDictionary* info;     //一些附属的属性，包括语音时长
//@property(nonatomic,assign) BOOL isSend;
@property(nonatomic,assign) DDMessageState state;       //消息发送状态
- (DDMessageEntity*)initWithMsgID:(NSUInteger)ID msgType:(DDMessageType)msgType msgTime:(NSUInteger)msgTime sessionID:(NSString*)sessionID senderID:(NSString*)senderID msgContent:(NSString*)msgContent toUserID:(NSString*)toUserID;
+(DDMessageEntity *)makeMessage:(NSString *)content Module:(ChattingModule *)module MsgType:(DDMessageType )type;
@end
