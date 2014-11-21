//
//  DDDDGroupsUnreadMessageAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-7.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDGroupsUnreadMessageAPI.h"
#import "DDMessageEntity.h"
#import "Encapsulator.h"
#import "RuntimeStatus.h"
#import "DDMessageModule.h"
@implementation DDGroupsUnreadMessageAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 5;
}

/**
 *  请求的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)requestServiceID
{
    return MODULE_ID_GROUP;
}

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID
{
    return MODULE_ID_GROUP;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return CMD_ID_GROUP_UNREAD_MSG_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_ID_GROUP_UNREAD_MSG_RES;
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
        NSMutableArray* msgArray = [[NSMutableArray alloc] init];
        NSMutableDictionary* msgDict = [[NSMutableDictionary alloc] init];
        NSString *groupId = [bodyData readUTF];
        uint32_t msgCnt = [bodyData readInt];
        for (uint32_t i = 0; i < msgCnt; i++)
        {
            
            NSString *fromUserId = [bodyData readUTF];
            uint32_t createTime = [bodyData readInt];
             DDMessageContentType msgType = [bodyData readChar];
            NSString* messageContent = nil;
   
            NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
            if ( msgType == DDGroup_Message_TypeText ) {
                messageContent = [bodyData readUTF];
            }else if (msgType == DDGroup_MessageTypeVoice)
            {
                
                int32_t dataLength = [bodyData readInt];
                if (dataLength != 0) {
                    NSData* data = [bodyData readDataWithLength:dataLength];
                    NSData* voiceData = [data subdataWithRange:NSMakeRange(4, [data length] - 4)];
                    NSString* filename = [NSString stringWithString:[Encapsulator defaultFileName]];
                    if ([voiceData writeToFile:filename atomically:YES])
                    {
                        messageContent = filename;
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
              
            }
            if ([messageContent hasPrefix:DD_MESSAGE_IMAGE_PREFIX])
            {
                msgType = DDMessageTypeImage;
            }
            DDMessageEntity *msg = nil;
            if (msgType == 0)
            {
                break;
            }
            else
            {
                NSString *messageID = [DDMessageModule getMessageID];
                msg = [[DDMessageEntity alloc ] initWithMsgID:messageID msgType:MESSAGE_TYPE_TEMP_GROUP msgTime:createTime sessionID:groupId senderID:fromUserId msgContent:messageContent toUserID:[RuntimeStatus instance].user.objID];
                msg.msgContentType=msgType;
                [msg setInfo:info];
            }
            
            [msgArray addObject:msg];
        }
        [msgDict setObject:groupId forKey:@"sessionId"];
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
        NSString* groupId = (NSString*)object;
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        uint32_t totalLen = IM_PDU_HEADER_LEN + 4 + strLen(groupId);
        
        [dataout writeInt:totalLen];
        [dataout writeTcpProtocolHeader:MODULE_ID_GROUP cId:CMD_ID_GROUP_UNREAD_MSG_REQ seqNo:seqNo];
        
        [dataout writeUTF:groupId];
        return [dataout toByteArray];
    };
    return package;
}
@end
