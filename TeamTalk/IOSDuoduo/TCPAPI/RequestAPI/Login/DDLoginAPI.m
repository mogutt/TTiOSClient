//
//  DDLoginAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-6.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDLoginAPI.h"
#import "DDUserEntity.h"
@implementation DDLoginAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 5;
}

/**
 *  请求的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)requestServiceID
{
    return DDSERVICE_LOGIN;
}

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID
{
    return DDSERVICE_LOGIN;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return DDCMD_LOGIN_REQ_USERLOGIN;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return DDCMD_LOGIN_RES_USERLOGIN;
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
        //NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSInteger serverTime = [bodyData readInt];
        NSInteger loginResult = [bodyData readInt];
        NSDictionary* result = nil;
        if (loginResult !=0) {
            return result;
        }else
        {
            NSInteger onlineStatus = [bodyData readInt];
            NSString *userId =[bodyData readUTF];
            NSString *nickName = [bodyData readUTF];
            NSString *avatar = [bodyData readUTF];
            NSString *title = [bodyData readUTF];
            NSString *position = [bodyData readUTF];
            NSInteger isDeleted = [bodyData readInt];
            NSInteger sex = [bodyData readInt];
            NSString *departId = [bodyData readUTF];
            NSInteger jobNum = [bodyData readInt];
            NSString *telphone = [bodyData readUTF];
            NSString *email = [bodyData readUTF];
            NSString *token = [bodyData readUTF];
            result = @{@"serverTime":@(serverTime),
                       @"result":@(loginResult),
                       @"state":@(onlineStatus),
                       @"nickName":nickName,
                       @"userId":userId,
                       @"title":title,
                       @"position":position,
                       @"isDeleted":@(isDeleted),
                       @"sex":@(sex),
                       @"departId":departId,
                       @"jobNum":@(jobNum),
                       @"telphone":telphone,
                       @"avatar":avatar,
                       @"email":email,
                       @"token":token,
                       };
            return result;
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
    Package package = (id)^(id object,uint32_t seqNo)
    {
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        NSArray* array = (NSArray*)object;
        NSString* userID = array[0];
        NSString *password = array[1];
        NSString *clientVersion = @"1.1";
        NSInteger status = [array[2] intValue];
        NSInteger clientType = [array[3] intValue];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:DDSERVICE_LOGIN
                                    cId:DDCMD_LOGIN_REQ_USERLOGIN
                                  seqNo:seqNo];
        [dataout writeUTF:userID];
        [dataout writeUTF:password];
        [dataout writeInt:(uint32_t)status];
        [dataout writeInt:(uint32_t)clientType];
        [dataout writeUTF:clientVersion];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}
@end
