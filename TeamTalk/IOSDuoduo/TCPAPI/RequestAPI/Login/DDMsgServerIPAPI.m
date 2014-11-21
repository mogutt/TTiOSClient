//
//  DDMsgServerIPAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-6.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDMsgServerIPAPI.h"
@implementation DDMsgServerIPAPI
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
    return DDCMD_LOGIN_REQ_MSGSERVER;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return DDCMD_LOGIN_RES_MSGSERVER;
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
        NSInteger result = [bodyData readInt];
        NSDictionary* resultDic = nil;
        if (result == 0)
        {
            NSString* ip1 = [bodyData readUTF];
            NSString* ip2 = [bodyData readUTF];
            int port = [bodyData readShort];
            resultDic = @{@"ip1":ip1,
                          @"ip2":ip2,
                          @"port":@(port)};
        }
        return resultDic;
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
        uint32_t totalLen = 12;
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:DDSERVICE_LOGIN cId:DDCMD_LOGIN_REQ_MSGSERVER seqNo:seqNo];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}
@end
