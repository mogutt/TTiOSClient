//
//  DDUnreadMessageGroupAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-7.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDUnreadMessageGroupAPI.h"

@implementation DDUnreadMessageGroupAPI
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
    return CMD_ID_GROUP_UNREAD_CNT_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_ID_GROUP_UNREAD_CNT_RES;
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
        NSMutableArray *unreadGroupList = [[NSMutableArray alloc] init];
        uint32_t unreadGroupCnt = [bodyData readInt];
        for (uint32_t i = 0; i < unreadGroupCnt; i++)
        {
            NSString *groupId = [bodyData readUTF];
            /*uint32_t unreadMsgCnt = */[bodyData readInt];
            
            [unreadGroupList addObject:groupId];
        }
        DDLog(@"receive group unread msg cnt:%i",unreadGroupCnt);
        return unreadGroupList;
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
        
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:MODULE_ID_GROUP
                                    cId:CMD_ID_GROUP_UNREAD_CNT_REQ
                                  seqNo:seqNo];
        //log4CInfo(@"serviceID:%i cmdID:%i --> get group unread cnt ",MODULE_ID_GROUP,CMD_ID_GROUP_UNREAD_CNT_REQ);
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}
@end
