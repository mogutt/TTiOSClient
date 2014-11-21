//
//  DDRecentConactsAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-24.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "RecentConactsAPI.h"
#import "DDUserEntity.h"
#import "DDDatabaseUtil.h"
#import "DDUserModule.h"
@implementation RecentConactsAPI

#pragma mark - DDAPIScheduleProtocol

- (int)requestTimeOutTimeInterval
{
    return 10;
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
    return DDCMD_FRI_RECENT_CONTACTS_REQ;
}

- (int)responseCommendID
{
    return DDCMD_FRI_RECENT_CONTACTS_RES;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        DDDataInputStream* dataInputStream = [DDDataInputStream dataInputStreamWithData:data];
        NSInteger userCnt = [dataInputStream readInt];
        DDLog(@"    **** 返回最近联系人列表,有%d个最近联系人.",userCnt);
        NSMutableArray* recentlyContactContent = [[NSMutableArray alloc] init];
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        if (userCnt == 0) {
            dispatch_semaphore_signal(sema);
        }else
        {
            for (int i=0; i<userCnt; i++) {
                NSString *userId = [dataInputStream readUTF];
                NSInteger userUpdated = [dataInputStream readInt];
                [[DDUserModule shareInstance] getUserForUserID:userId Block:^(DDUserEntity *user) {
                    user.lastUpdateTime=userUpdated;
                    if (user) {
                        [recentlyContactContent addObject:user];
                    }
                    
                }];
                if (userCnt == i+1) {
                    dispatch_semaphore_signal(sema);
                }
            }
        }
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        return recentlyContactContent;
    };
    return analysis;
}

- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo)
    {
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        uint32_t totalLen = IM_PDU_HEADER_LEN + 4;
        [dataout writeInt:totalLen];
        [dataout writeTcpProtocolHeader:DDSERVICE_FRI cId:DDCMD_FRI_RECENT_CONTACTS_REQ seqNo:seqNo];
        [dataout writeInt:0];
        return [dataout toByteArray];
    };
    return package;
}
@end
