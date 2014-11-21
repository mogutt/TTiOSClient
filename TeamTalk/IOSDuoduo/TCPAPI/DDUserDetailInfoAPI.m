//
//  DDUserDetailInfoAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-22.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDUserDetailInfoAPI.h"

@implementation DDUserDetailInfoAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return TimeOutTimeInterval;
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
    return DDCMD_USER_INFO_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return DDCMD_USER_INFO_RES;
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
        NSMutableArray* userList = [[NSMutableArray alloc] init];
        for (uint32_t i = 0; i < userCnt; i ++)
        {
            NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
            NSString* userID = [bodyData readUTF];
            [dictionary setValue:userID forKey:@"userId"];
            NSString* realName = [bodyData readUTF];
            [dictionary setValue:realName forKey:@"name"];
            NSString* userName = [bodyData readUTF];
            [dictionary setValue:userName forKey:@"nickName"];
            NSString* avatar = [bodyData readUTF];
            [dictionary setValue:avatar forKey:@"avatar"];
            NSString *title = [bodyData readUTF];
            [dictionary setValue:title forKey:@"title"];
            NSString *position = [bodyData readUTF];
            [dictionary setValue:position forKey:@"position"];
            NSInteger roleStatus = [bodyData readInt];
            [dictionary setValue:@(roleStatus) forKey:@"roleStatus"];
            NSInteger sex = [bodyData readInt];
            [dictionary setValue:@(sex) forKey:@"sex"];
            NSString* department = [bodyData readUTF];
            [dictionary setValue:department forKey:@"department"];
            NSInteger jobNum = [bodyData readInt];
            [dictionary setValue:@(jobNum) forKey:@"jobNum"];
            NSString* tel = [bodyData readUTF];
            [dictionary setValue:tel forKey:@"telphone"];
            NSString* email = [bodyData readUTF];
            [dictionary setValue:email forKey:@"email"];
            [userList addObject:dictionary];
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
    Package package = (id)^(id object,uint16_t seqNo)
    {
        NSArray* users = (NSArray*)object;
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        int totalLen = IM_PDU_HEADER_LEN;
        totalLen += 4;
        uint32_t userCnt = (uint32_t)[users count];
        for (uint32_t i = 0; i < userCnt; i++) {
            totalLen += 4 + strLen((NSString*)[users objectAtIndex:i]);
        }
        
        [dataout writeInt:0];
        
        [dataout writeTcpProtocolHeader:DDSERVICE_FRI
                                    cId:DDCMD_USER_INFO_REQ
                                  seqNo:seqNo];
        
        [dataout writeInt:(int)[users count]];
        for (uint32_t i = 0; i < userCnt; i++) {
            NSString *userId = (NSString*)[users objectAtIndex:i];
            [dataout writeUTF:userId];
        }
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}
@end
