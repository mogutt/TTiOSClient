//
//  DDMessageEntity.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDMessageEntity.h"
#import "DDUserModule.h"
#import "EmotionsModule.h"
#import "ChattingModule.h"
#import "Encapsulator.h"
#import "DDMessageModule.h"
#import "DDDataInputStream.h"
#import "RuntimeStatus.h"
@interface DDMessageEntity(private)

- (NSString*)getNewMessageContentFromContent:(NSString*)content;

@end
@implementation DDMessageEntity

- (DDMessageEntity*)initWithMsgID:(NSString *)ID msgType:(DDMessageType)msgType msgTime:(NSUInteger)msgTime sessionID:(NSString*)sessionID senderID:(NSString*)senderID msgContent:(NSString*)msgContent toUserID:(NSString*)toUserID
{
    self = [super init];
    if (self)
    {

        _msgID = ID;
        _msgType = msgType;
        _msgTime = msgTime;
        _sessionId = [sessionID copy];
        _senderId = [senderID copy];
        _msgContent = [self getNewMessageContentFromContent:msgContent];
        _toUserID = [toUserID copy];
        _info = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone
{
    DDMessageEntity *ddmentity =[[[self class] allocWithZone:zone] initWithMsgID:_msgID msgType:_msgType msgTime:_msgTime sessionID:_sessionId senderID:_senderId msgContent:_msgContent toUserID:_toUserID];
    return ddmentity;
}

#pragma mark - 
#pragma mark - privateAPI
- (NSString*)getNewMessageContentFromContent:(NSString*)content
{
    
    NSMutableString *msgContent = [NSMutableString stringWithString:content?content:@""];
    NSMutableString *resultContent = [NSMutableString string];
    NSRange startRange;
    NSDictionary* emotionDic = [EmotionsModule shareInstance].emotionUnicodeDic;
    while ((startRange = [msgContent rangeOfString:@"["]).location != NSNotFound) {
        if (startRange.location > 0)
        {
            NSString *str = [msgContent substringWithRange:NSMakeRange(0, startRange.location)];
            DDLog(@"[前文本内容:%@",str);
            [msgContent deleteCharactersInRange:NSMakeRange(0, startRange.location)];
            startRange.location=0;
            [resultContent appendString:str];
        }
        
        NSRange endRange = [msgContent rangeOfString:@"]"];
        if (endRange.location != NSNotFound) {
            NSRange range;
            range.location = 0;
            range.length = endRange.location + endRange.length;
            NSString *emotionText = [msgContent substringWithRange:range];
            [msgContent deleteCharactersInRange:
             NSMakeRange(0, endRange.location + endRange.length)];
            
            DDLog(@"类似表情字串:%@",emotionText);
            NSString *emotion = emotionDic[emotionText];
            if (emotion) {
                // 表情
                [resultContent appendString:emotion];
            } else
            {
                [resultContent appendString:emotionText];
            }
        } else {
            DDLog(@"没有[匹配的后缀");
            break;
        }
    }
    
    if ([msgContent length] > 0)
    {
        [resultContent appendString:msgContent];
    }
    return resultContent;
}
+(DDMessageEntity *)makeMessage:(NSString *)content Module:(ChattingModule *)module MsgType:(DDMessageContentType )type
{
    NSUInteger msgTime = [[NSDate date] timeIntervalSince1970];
    NSString* senderID = [RuntimeStatus instance].user.objID;
    DDMessageEntity* message = [[DDMessageEntity alloc] initWithMsgID:[DDMessageModule getMessageID] msgType:module.sessionEntity.sessionType msgTime:msgTime sessionID:module.sessionEntity.sessionID senderID:senderID msgContent:content toUserID:module.sessionEntity.sessionID];
    message.state = DDMessageSending;
    message.msgContentType=type;
    [module addShowMessage:message];
    [module updateSessionUpdateTime:message.msgTime];
    return message;
}
-(BOOL)isGroupMessage
{
    if (self.msgType == MESSAGE_TYPE_SINGLE ) {
        return NO;
    }
    return YES;
}
-(BOOL)isGroupVoiceMessage
{
    if (self.msgType == DDGroup_Message_TypeText || self.msgType == DDGroup_MessageTypeVoice) {
        return YES;
    }
    return NO;
}
-(BOOL)isImageMessage
{
    if (self.msgContentType == DDMessageTypeImage) {
        return YES;
    }
    return NO;
}
-(BOOL)isSendBySelf
{
    if ([self.senderId isEqualToString:TheRuntime.user.objID]) {
        return YES;
    }
    return NO;
}
+(DDMessageEntity *)makeMessageFromStream:(DDDataInputStream *)bodyData
{
    int32_t seqNo = [bodyData readInt];
    NSString *fromUserId = [bodyData readUTF];
    NSString *toUserId = [bodyData readUTF];
    int32_t msgTime = [bodyData readInt];
    int8_t msgType = [bodyData readChar];
    //int8_t msgRenderType = [bodyData readChar];
    DDMessageEntity *msg = [[DDMessageEntity alloc ] init];
    msg.msgType = msgType;
    msg.msgContentType = msgType;
    NSString* messageContent = nil;
    NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
    if (msgType == DDMessageTypeVoice || msgType == DDGroup_MessageTypeVoice) {
        if (msgType ==DDMessageTypeVoice) {
            msg.msgType = MESSAGE_TYPE_SINGLE;
            msg.msgContentType =DDMessageTypeVoice;
        }else{
            msg.msgType = MESSAGE_TYPE_TEMP_GROUP;
            msg.msgContentType =DDGroup_MessageTypeVoice;
        }
        int32_t dataLength = [bodyData readInt];
        NSData* data = [bodyData readDataWithLength:dataLength];
        NSData* voiceData = [data subdataWithRange:NSMakeRange(4, [data length] - 4)];
        NSString* filename = [NSString stringWithString:[Encapsulator defaultFileName]];
        if ([voiceData writeToFile:filename atomically:YES])
        {
            messageContent = filename;
        }
        else
        {
            messageContent = @"语音存储出错";
        }
        NSData* voiceLengthData = [data subdataWithRange:NSMakeRange(0, 4)];
        
        int8_t ch1;
        [voiceLengthData getBytes:&ch1 range:NSMakeRange(0,1)];
        ch1 = ch1 & 0x0ff;
        
        int8_t ch2;
        [voiceLengthData getBytes:&ch2 range:NSMakeRange(1,1)];
        ch2 = ch2 & 0x0ff;
        
        int32_t ch3;
        [voiceLengthData getBytes:&ch3 range:NSMakeRange(2,1)];
        ch3 = ch3 & 0x0ff;
        
        int32_t ch4;
        [voiceLengthData getBytes:&ch4 range:NSMakeRange(3,1)];
        ch4 = ch4 & 0x0ff;
        
        if ((ch1 | ch2 | ch3 | ch4) < 0){
            @throw [NSException exceptionWithName:@"Exception" reason:@"EOFException" userInfo:nil];
        }
        int voiceLength = ((ch1 << 24) + (ch2 << 16) + (ch3 << 8) + (ch4 << 0));
        [info setObject:@(voiceLength) forKey:VOICE_LENGTH];
        [info setObject:@(0) forKey:DDVOICE_PLAYED];
    }else
    {
        messageContent = (NSString *)[bodyData readUTF];
        if ([messageContent hasPrefix:DD_MESSAGE_IMAGE_PREFIX])
        {
            msg.msgContentType = DDMessageTypeImage;
        }
    }
    NSString *attach = [bodyData readUTF];
    msg.msgID = [DDMessageModule getMessageID];
    msg.seqNo = seqNo;
    msg.msgTime = msgTime;
    msg.toUserID=toUserId;
    msg.msgContent = [msg getNewMessageContentFromContent:messageContent];
    msg.attach = attach;
    if([msg isGroupMessage])
    {
        msg.sessionId = toUserId;       //群聊时，toUserId表示会话ID
        msg.senderId = fromUserId;      //群聊时，fromUserId表示发送者I
    }
    else
    {
        msg.sessionId = fromUserId; //单人时，fromUserId表示发送者ID，作为会话id
        msg.senderId = fromUserId;  //单人时，fromUserId表示发送者ID
        
    }
    if ([msg.sessionId isEqualToString:TheRuntime.userID]) {
        msg.sessionId = toUserId;
    }
      msg.info=info;
    return msg;
}
@end
