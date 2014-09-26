//
//  DDGetUnreadMessageAPI.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-6-12.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDGetUnreadMessageUsersAPI.h"

@implementation DDGetUnreadMessageUsersAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 2;
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
    return DDCMD_MSG_UNREAD_CNT_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return DDCMD_MSG_UNREAD_CNT_RES;
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
        NSMutableArray* unReadMsgUserIds = [[NSMutableArray alloc] init];
        uint32_t unreadUserCnt = [bodyData readInt];
        for (uint32_t i = 0; i < unreadUserCnt; i++)
        {
            NSString *fromId = [bodyData readUTF];
            /*uint32_t unreadCnt = */[bodyData readInt];
            [unReadMsgUserIds addObject:fromId];
        }
        DDLog(@"receive un read msg count:%i",[unReadMsgUserIds count]);
        return unReadMsgUserIds;
        
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
        
        [dataout writeInt:IM_PDU_HEADER_LEN];
        [dataout writeTcpProtocolHeader:DDSERVICE_MESSAGE cId:DDCMD_MSG_UNREAD_CNT_REQ seqNo:seqNo];
        DDLog(@"serviceID:%i cmdID:%i --> get unread msg cnt",DDSERVICE_MESSAGE,DDCMD_MSG_UNREAD_CNT_REQ);
        return [dataout toByteArray];
    };
    return package;
}

@end
