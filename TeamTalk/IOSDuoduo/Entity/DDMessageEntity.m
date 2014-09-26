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
#import "DDMessageModule.h"
#import "RuntimeStatus.h"
@interface DDMessageEntity(private)

- (NSString*)getNewMessageContentFromContent:(NSString*)content;

@end
@implementation DDMessageEntity

- (DDMessageEntity*)initWithMsgID:(NSUInteger)ID msgType:(DDMessageType)msgType msgTime:(NSUInteger)msgTime sessionID:(NSString*)sessionID senderID:(NSString*)senderID msgContent:(NSString*)msgContent toUserID:(NSString*)toUserID
{
    self = [super init];
    if (self)
    {
        if (msgType == DDMessageTypeImage)
        {
            NSLog(@"asd");
        }
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
    
    NSMutableString *msgContent = [NSMutableString stringWithString:content];
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
+(DDMessageEntity *)makeMessage:(NSString *)content Module:(ChattingModule *)module MsgType:(DDMessageType )type
{
    NSUInteger msgTime = [[NSDate date] timeIntervalSince1970];
    NSString* senderID = [RuntimeStatus instance].user.userId;
    NSUInteger messageID = [DDMessageModule getMessageID];
    DDMessageEntity* message = [[DDMessageEntity alloc] initWithMsgID:messageID msgType:type msgTime:msgTime sessionID:module.sessionEntity.sessionID senderID:senderID msgContent:content toUserID:module.sessionEntity.sessionID];
    message.state = DDMessageSending;
    message.msgType=type;
    [module addShowMessage:message];
    [module updateSessionUpdateTime:message.msgTime];
    return message;
}
@end
