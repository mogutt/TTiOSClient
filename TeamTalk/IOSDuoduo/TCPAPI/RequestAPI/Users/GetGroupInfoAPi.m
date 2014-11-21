//
//  GetGroupInfoAPi.m
//  TeamTalk
//
//  Created by Michael Scofield on 2014-09-18.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "GetGroupInfoAPI.h"
#import "DDGroupEntity.h"
@implementation GetGroupInfoAPI
- (int)requestTimeOutTimeInterval
{
    return TimeOutTimeInterval;
}

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
    return CMD_ID_GROUP_USER_LIST_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_ID_GROUP_USER_LIST_RES;
}
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        DDDataInputStream* bodyData = [DDDataInputStream dataInputStreamWithData:data];
        NSString *groupId = [bodyData readUTF];
        uint32_t result = [bodyData readInt];
        DDGroupEntity* group = nil;
        if (result != 0)
        {
            return group;
        }
        group = [[DDGroupEntity alloc] init];
        NSString *groupName = [bodyData readUTF];
        NSString *groupAvatar = [bodyData readUTF];
        NSString *groupCreator = [bodyData readUTF];
        UInt32 groupType = [bodyData readInt];
        group.objID = groupId;
        group.name = groupName;
        group.avatar = groupAvatar;
        group.groupCreatorId = groupCreator;
        group.groupType = groupType;
        UInt32 groupMemberCnt = [bodyData readInt];
        if(groupMemberCnt > 0)
            group.groupUserIds = [[NSMutableArray alloc] init];
        for (uint32_t i = 0; i < groupMemberCnt; i++)
        {
            NSString *userId = [bodyData readUTF];
            [group.groupUserIds addObject:userId];
            [group addFixOrderGroupUserIDS:userId];
        }
        return group;
    };
    return analysis;
}

- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo)
    {
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        uint32_t totalLen = IM_PDU_HEADER_LEN + 4 + strLen(object);
        
        [dataout writeInt:totalLen];
        [dataout writeTcpProtocolHeader:MODULE_ID_GROUP
                                    cId:CMD_ID_GROUP_USER_LIST_REQ
                                  seqNo:seqNo];
        [dataout writeUTF:object];
        return [dataout toByteArray];

    };
    return package;
}
@end
