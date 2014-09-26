//
//  DDGetUserInfoAPI.m
//  Mogujie4iPhone
//
//  Created by 独嘉 on 14-6-24.
//  Copyright (c) 2014年 juangua. All rights reserved.
//

#import "DDGetUserInfoAPI.h"
#import "DDUserEntity.h"
@implementation DDGetUserInfoAPI
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
    return DDCMD_USER_INFO_REQ;
}

- (int)responseCommendID
{
    return DDCMD_USER_INFO_RES;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        DDDataInputStream* bodyData = [DDDataInputStream dataInputStreamWithData:data];
        uint32_t userCnt = [bodyData readInt];
        NSMutableArray *userList = [[NSMutableArray alloc] init];
        
        for (uint32_t i = 0; i < userCnt; i++) {
            NSString *userId =[bodyData readUTF];
            NSString *username = [bodyData readUTF];
            NSString *nickName = [bodyData readUTF];
            NSString *avatar = [bodyData readUTF];
            NSString *title = [bodyData readUTF];
            NSString *position = [bodyData readUTF];
            NSInteger roleStatus = [bodyData readInt];
            NSInteger sex = [bodyData readInt];
            NSString *departId = [bodyData readUTF];
            NSInteger jobNum = [bodyData readInt];
            NSString *telphone = [bodyData readUTF];
            NSString *email = [bodyData readUTF];
            NSDictionary* result = nil;
            result = @{
                       @"name":username,
                       @"nickName":nickName,
                       @"userId":userId,
                       @"title":title,
                       @"position":position,
                       @"roleStatus":@(roleStatus),
                       @"sex":@(sex),
                       @"departId":departId,
                       @"jobNum":@(jobNum),
                       @"telphone":telphone,
                       @"avatar":avatar,
                       @"email":email,
                       };
            DDUserEntity *user = [DDUserEntity dicToUserEntity:result];
            [userList addObject:user];
        }
        DDLog(@"userListHandler, userCnt=%u", userCnt);
        return userList;
    };
    return analysis;
}

- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo)
    {
        NSArray* userList = (NSArray*)object;
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        uint32_t totalLen = IM_PDU_HEADER_LEN + 4;
        uint32_t userCnt = (uint32_t)[userList count];
        for (uint32_t i = 0; i < userCnt; i++) {
            totalLen += 4 + strLen((NSString*)[userList objectAtIndex:i]);
        }
        
        [dataout writeInt:totalLen];
        [dataout writeTcpProtocolHeader:DDSERVICE_FRI
                                    cId:DDCMD_USER_INFO_REQ
                                  seqNo:seqNo];
        [dataout writeInt:userCnt];
        for (uint32_t i = 0; i < userCnt; i++) {
            NSString *userId = (NSString*)[userList objectAtIndex:i];
            [dataout writeUTF:userId];
        }
        return [dataout toByteArray];
    };
    return package;
}
@end
