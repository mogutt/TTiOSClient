//
//  DDRecentGroupAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-6.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDRecentGroupAPI.h"
#import "DDGroupEntity.h"
@implementation DDRecentGroupAPI
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
    return CMD_ID_GROUP_DIALOG_LIST_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_ID_GROUP_DIALOG_LIST_RES;
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
        NSMutableArray* recentlyGroup = [[NSMutableArray alloc] init];
        uint32_t groupCnt = [bodyData readInt];
        for (uint32_t i = 0; i < groupCnt; i++)
        {
            NSString* groupId = [bodyData readUTF];
            NSString* groupName = [bodyData readUTF];
            NSString* groupAvatar = [bodyData readUTF];
            NSString* groupCreator = [bodyData readUTF];
            
            UInt32 groupType = [bodyData readInt];
            DDGroupEntity* group = [[DDGroupEntity alloc] init];
            group.objID = groupId;
            group.name = groupName;
            group.avatar = groupAvatar;
            group.groupCreatorId = groupCreator;
            group.groupType = groupType;
            group.lastUpdateTime = [bodyData readInt];
            uint32_t groupMemberCnt = [bodyData readInt];
            if(groupMemberCnt > 0)
                group.groupUserIds = [[NSMutableArray alloc] init];
            for (uint32_t i = 0; i < groupMemberCnt; i++)
            {
                NSString *userId = [bodyData readUTF];
                [group.groupUserIds addObject:userId];
                [group addFixOrderGroupUserIDS:userId];
            }
            
            [recentlyGroup addObject:group];
        }
        
        return recentlyGroup;
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
                                    cId:CMD_ID_GROUP_DIALOG_LIST_REQ
                                  seqNo:seqNo];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}
@end
