//
//  DDGetUserUnreadMessagesAPI.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-6-12.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDGetUserUnreadMessagesAPI.h"
#import "DDMessageEntity.h"
#import "Encapsulator.h"
#import "DDUserModule.h"
#import "DDMessageModule.h"
#import "RuntimeStatus.h"
@implementation DDGetUserUnreadMessagesAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 20;
}

/**
 *  请求的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)requestServiceID
{
    return DDSERVICE_MESSAGE;
}

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID
{
    return DDSERVICE_MESSAGE;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return DDCMD_MSG_UNREAD_MSG_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return DDCMD_MSG_GET_2_UNREAD_MSG;
}

/**
 *  解析数据的block
 *
 *  @return 解析数据的block
 */
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        DDDataInputStream* bodyData = [DDDataInputStream dataInputStreamWithData:data];
        NSMutableDictionary* msgDict = [[NSMutableDictionary alloc] init];
        NSMutableArray* msgArray = [[NSMutableArray alloc] init];
        NSString *sessionId = [bodyData readUTF];
        uint32_t msgCnt = [bodyData readInt];
        DDLog(@"msgList for session: %@", sessionId);
        
        for (uint32_t i = 0; i < msgCnt; i++)
        {
            NSString *fromUserId = [bodyData readUTF];
            /*NSString *fromUserName = */[bodyData readUTF];
            /*NSString *fromNickName = */[bodyData readUTF];
            /*NSString *fromAvatar = */[bodyData readUTF];
            uint32_t createTime = [bodyData readInt];
            uint8_t msgContentType = [bodyData readChar];
            NSString *msgContent = @"";
            NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
            DDMessageEntity *msg = [[DDMessageEntity alloc ] init];
            msg.msgType = MESSAGE_TYPE_SINGLE;
            msg.msgContentType=DDMessageTypeText;
            if (msgContentType == DDMessageTypeVoice || msgContentType == DDGroup_MessageTypeVoice) {
              
                msg.msgContentType=msgContentType;
                int32_t dataLength = [bodyData readInt];
                if (dataLength) {
                    NSData* data = [bodyData readDataWithLength:dataLength];
                    NSData* voiceData = [data subdataWithRange:NSMakeRange(4, [data length] - 4)];
                    NSString* filename = [NSString stringWithString:[Encapsulator defaultFileName]];
                    if ([voiceData writeToFile:filename atomically:YES])
                    {
                        msgContent = filename;
                    }
                    else
                    {
                        msgContent = @"语音存储出错";
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
                }
               
            }else
            {
                msgContent = [bodyData readUTF];
                ;
                if ([msgContent hasPrefix:DD_MESSAGE_IMAGE_PREFIX])
                {
                    msg.msgContentType = DDMessageTypeImage;
                }else{
                    msg.msgContentType = DDMessageTypeText;
                }
        
            }
            msg.msgTime = createTime;
            msg.msgContent = msgContent;
            msg.sessionId = fromUserId;
            msg.senderId = fromUserId;
            msg.info=info;
            msg.msgID = [DDMessageModule getMessageID];
            [msgArray addObject:msg];
            
        }
        
        
        [msgDict setObject:sessionId forKey:@"sessionId"];
        [msgDict setObject:msgArray forKey:@"msgArray"];
        
        return msgDict;
        
    };
    return analysis;
}

/**
 *  打包数据的block
 *
 *  @return 打包数据的block
 */
- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo)
    {
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        uint32_t totalLen = IM_PDU_HEADER_LEN + 4 + strLen(object);
        
        [dataout writeInt:totalLen];
        [dataout writeTcpProtocolHeader:DDSERVICE_MESSAGE
                                    cId:DDCMD_MSG_UNREAD_MSG_REQ
                                  seqNo:seqNo];
        [dataout writeUTF:object];
        
        DDLog(@"serviceID:%i cmdID:%i --> get unread msg from user:%@",DDSERVICE_MESSAGE,DDCMD_MSG_UNREAD_MSG_REQ,object);
        
        return [dataout toByteArray];
    };
    return package;
}
@end
