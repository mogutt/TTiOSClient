//
//  DDSendMessageAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-8.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDSendMessageAPI.h"

@implementation DDSendMessageAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 10;
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
    return DDCMD_MSG_DATA;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return DDCMD_MSG_RECEIVE_DATA_ACK;
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
        uint32_t seqNo = [bodyData readInt];
        return [NSNumber numberWithInt:seqNo];
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
    Package package = (id)^(id object,uint16_t seqNo)
    {
        
        NSArray* array = (NSArray*)object;
        NSString* fromId = array[0];
        NSString* toId = array[1];
        NSString* messageContent = array[2];//消息内容
        int messageSeqNo = [array[3] intValue];
        char messageTpye = [array[4] intValue];//消息类型
        NSString *messageAttachContent=nil;
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        uint32_t totalLen = strLen(fromId) + strLen(toId) + strLen(messageContent) + strLen(messageAttachContent) + 24 + 12+sizeof(messageTpye);
        DDLog(@"  getSendMsgData: 消息长度:%d",totalLen);
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:DDSERVICE_MESSAGE cId:DDCMD_MSG_DATA seqNo:seqNo];
        [dataout writeInt:messageSeqNo];
        [dataout writeUTF:fromId];
        [dataout writeUTF:toId];
        [dataout writeInt:0];   //createTime.由msgserver生成
        [dataout writeChar:messageTpye];
        [dataout writeUTF:messageContent];
        [dataout writeUTF:nil];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}

@end
