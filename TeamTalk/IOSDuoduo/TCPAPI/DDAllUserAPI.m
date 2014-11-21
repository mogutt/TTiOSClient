//
//  DDAllUserAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-7.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDAllUserAPI.h"
#import "DDUserEntity.h"

@implementation DDAllUserAPI
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
    return DDSERVICE_FRI;
}

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID
{
    return DDSERVICE_FRI;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return CMD_FRI_ALL_USER_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_FRI_ALL_USER_RES;
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
        return userList;
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
        [dataout writeTcpProtocolHeader:DDSERVICE_FRI
                                    cId:CMD_FRI_ALL_USER_REQ
                                  seqNo:seqNo];
        [dataout writeDataCount];
        //        log4CInfo(@"serviceID:%i cmdID:%i --> get all user",MODULE_ID_FRIENDLIST,CMD_FRI_ALL_USER_REQ);
        return [dataout toByteArray];
    };
    return package;
}
@end
