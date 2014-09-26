//
//  DDAddMemberToGroupAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-8.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDAddMemberToGroupAPI.h"
#import "DDGroupModule.h"
#import "DDGroupEntity.h"
#import "RuntimeStatus.h"
@implementation DDAddMemberToGroupAPI
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
    return CMD_ID_GROUP_JOIN_GROUP_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_ID_GROUP_JOIN_GROUP_RES;
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
        DDGroupEntity *groupEntity = nil;
        if (result != 0)
        {
            //log4CInfo(@"change group member failure");
            return groupEntity;
        }
        NSString *groupId = [bodyData readUTF];
        uint32_t userCnt = [bodyData readInt];
        groupEntity =  [[DDGroupModule instance] getGroupByGId:groupId];
//        if (!groupEntity)
//        {
//            [groupModule tcpGetUnkownGroupInfo:groupId];
//        }
        if (groupEntity) {
            for (uint32_t i = 0; i < userCnt; i++) {
                NSString* userId = [bodyData readUTF];
                if (![groupEntity.groupUserIds containsObject:userId]) {
                    [groupEntity.groupUserIds addObject:userId];
                    [groupEntity addFixOrderGroupUserIDS:userId];
                }
                //log4CInfo(@"group add member success,member userID:%@",userId);
            }
        }
        
        DDLog(@"result: %d, goupId: %@", result, groupId);
        return groupEntity;
        
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
        NSString* groupId = array[0];
        NSArray* userList = array[1];
        int isAdd=[array[2] intValue];
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        uint32_t totalLen = IM_PDU_HEADER_LEN + 4 + strLen(groupId) + 4+4;
        
        NSUInteger userCnt = [userList count];
        for (NSUInteger i = 0; i < userCnt; i++) {
            NSString *userId = [userList objectAtIndex:i];
            totalLen += 4 + strLen(userId);
        }
        
        [dataout writeInt:totalLen];
        [dataout writeTcpProtocolHeader:MODULE_ID_GROUP cId:CMD_ID_GROUP_JOIN_GROUP_REQ seqNo:seqNo];
        [dataout writeUTF:groupId];
        [dataout writeInt:isAdd];
        [dataout writeInt:(uint32_t)userCnt];
        for (NSUInteger i = 0; i < userCnt; i++) {
            NSString *userId = [userList objectAtIndex:i];
            [dataout writeUTF:userId];
        }
        //log4CInfo(@"serviceID:%i cmdID:%i --> change group member group ID:%@",MODULE_ID_GROUP,CMD_ID_GROUP_JOIN_GROUP_REQ,groupId);
        return [dataout toByteArray];
    };
    return package;
}
@end
