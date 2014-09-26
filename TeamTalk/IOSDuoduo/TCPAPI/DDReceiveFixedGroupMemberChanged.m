//
//  DDReceiveFixedGroupMemberChanged.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-13.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "DDReceiveFixedGroupMemberChanged.h"
#import "DDGroupEntity.h"
#import "DDGroupModule.h"
#import "RuntimeStatus.h"
@implementation DDReceiveFixedGroupMemberChanged
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
    return CMD_ID_FIXED_GROUP_CHANGED;
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
        if (groupEntity) {
            for (uint32_t i = 0; i < userCnt; i++) {
                NSString* userId = [bodyData readUTF];
                if (![groupEntity.groupUserIds containsObject:userId]) {
                    [groupEntity.groupUserIds addObject:userId];
                    [groupEntity addFixOrderGroupUserIDS:userId];
                }
            }
        }
        return groupEntity;
    };
    return analysis;
}
@end
