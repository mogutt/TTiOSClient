//
//  DDAllotServiceAPI.m
//  Mogujie4iPhone
//
//  Created by 独嘉 on 14-6-17.
//  Copyright (c) 2014年 juangua. All rights reserved.
//

#import "DDAllotServiceAPI.h"
#import "DDUserEntity.h"
@implementation DDAllotServiceAPI
#pragma mark - DDAPIScheduleProtocol

- (int)requestTimeOutTimeInterval
{
    return 5;
}

- (int)requestServiceID
{
    return DDSERVICE_FRI;
}

- (int)responseServiceID
{
    return DDSERVICE_FRI;
}

- (int)requestCommendID
{
    return DDCMD_FRI_USER_SERVICE_REQ;
}

- (int)responseCommendID
{
    return DDCMD_FRI_USER_SERVICE_RES;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        DDDataInputStream* dataInputStream = [DDDataInputStream dataInputStreamWithData:data];
        NSString* shopID = [dataInputStream readUTF];
        int result = [dataInputStream readInt];
        DDUserEntity* user = nil;
        if (result == 0)
        {
            int status = [dataInputStream readInt];//在线状态
            NSString* userID = [dataInputStream readUTF];//客服ID
            NSString* name = [dataInputStream readUTF];//name
            NSString* nickName = [dataInputStream readUTF];//nickname
            NSString* avatar = [dataInputStream readUTF];//头像
            NSUInteger userType = [dataInputStream readInt];
            NSUInteger updated = [[NSDate date] timeIntervalSince1970];
            user = [[DDUserEntity alloc] initWithUserID:userID name:name nick:nickName avatar:avatar userRole:userType userUpdated:updated];
            if (shopID)
            {
                [user.info setValue:shopID forKeyPath:DD_USER_INFO_SHOP_ID_KEY];
            }
        }
        return user;
        
    };
    return analysis;
}

- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo)
    {
        NSString* shopID = object[0];
        int type = [object[1] intValue];
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        uint32_t totalLen = 24 + strLen(shopID);
        [dataout writeInt:totalLen];
        [dataout writeTcpProtocolHeader:DDSERVICE_FRI cId:DDCMD_FRI_USER_SERVICE_REQ seqNo:seqNo];
        [dataout writeUTF:shopID];
        [dataout writeInt:type];
        return [dataout toByteArray];
    };
    return package;
}

@end
