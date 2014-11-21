//
//  DDCreateGroupAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-8.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDCreateGroupAPI.h"
#import "DDTcpProtocolHeader.h"
#import "DDGroupEntity.h"
@implementation DDCreateGroupAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return TimeOutTimeInterval;
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
    return CMD_ID_GROUP_CREATE_TMP_GROUP_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_ID_GROUP_CREATE_TMP_GROUP_RES;
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
        uint32_t result = [bodyData readInt];
        
        
        DDGroupEntity* group = nil;
        if (result != 0)
        {
            return group;
        }
        else
        {
            NSString *groupId = [bodyData readUTF];
            NSString *groupName = [bodyData readUTF];
            uint32_t userCnt = [bodyData readInt];
            group = [[DDGroupEntity alloc] init];
            group.objID = groupId;
            group.name = groupName;
            group.groupUserIds = [[NSMutableArray alloc] init];
            
            for (uint32_t i = 0; i < userCnt; i++) {
                NSString* userId = [bodyData readUTF];
                [group.groupUserIds addObject:userId];
                [group addFixOrderGroupUserIDS:userId];
            }
           
            return group;
        }
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
        NSString* groupName = array[0];
        NSString* groupAvatar = array[1];
        NSArray* groupUserList = array[2];
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        uint32_t totalLen = IM_PDU_HEADER_LEN + strLen(groupName) + strLen(groupAvatar) + 12;
        
        NSUInteger totalUserCnt = [groupUserList count];
        for (NSUInteger i = 0; i < totalUserCnt; i++) {
            NSString *userId = [groupUserList objectAtIndex:i];
            totalLen += 4 + strLen(userId);
        }
        
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:MODULE_ID_GROUP
                                    cId:CMD_ID_GROUP_CREATE_TMP_GROUP_REQ
                                  seqNo:seqNo];
        [dataout writeUTF:groupName];
        [dataout writeUTF:groupAvatar];
        [dataout writeInt:(uint32_t)totalUserCnt];
        for (NSUInteger i = 0; i < totalUserCnt; i++) {
            NSString *userId = [groupUserList objectAtIndex:i];
            [dataout writeUTF:userId];
        }
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}
@end
