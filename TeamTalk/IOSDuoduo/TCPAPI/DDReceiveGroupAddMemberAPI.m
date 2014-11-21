//
//  DDReceiveGroupAddMemberAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-8.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDReceiveGroupAddMemberAPI.h"
#import "DDGroupModule.h"
#import "RuntimeStatus.h"
#import "DDGroupEntity.h"
@implementation DDReceiveGroupAddMemberAPI
/**
 *  数据包中的serviceID
 *
 *  @return serviceID
 */
- (int)responseServiceID
{
    return MODULE_ID_GROUP;
}

/**
 *  数据包中的commandID
 *
 *  @return commandID
 */
- (int)responseCommandID
{
    return CMD_ID_GROUP_CHANGE_GROUP_RES;
}

/**
 *  解析数据包
 *
 *  @return 解析数据包的block
 */
- (UnrequestAPIAnalysis)unrequestAnalysis
{
    UnrequestAPIAnalysis analysis = (id)^(NSData* data)
    {
        DDDataInputStream* bodyData = [DDDataInputStream dataInputStreamWithData:data];
        uint32_t result = [bodyData readInt];
        DDGroupEntity* groupEntity = nil;
        if (result != 0)
        {
           // log4CInfo(@"change group member failure");
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
        
        NSLog(@"result: %d, goupId: %@", result, groupId);
        return groupEntity;
    };
    return analysis;
}
@end
