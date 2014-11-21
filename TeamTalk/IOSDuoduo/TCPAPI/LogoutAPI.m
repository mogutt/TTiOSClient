//
//  LogoutAPI.m
//  TeamTalk
//
//  Created by Michael Scofield on 2014-10-20.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "LogoutAPI.h"

@implementation LogoutAPI
- (int)requestTimeOutTimeInterval
{
    return 5;
}

- (int)requestServiceID
{
    return DDSERVICE_LOGIN;
}

- (int)responseServiceID
{
    return DDSERVICE_LOGIN;
}

- (int)requestCommendID
{
    return DDSERVICE_LOGIN;
}

- (int)responseCommendID
{
    return DDSERVICE_LOGIN;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        DDDataInputStream* dataInputStream = [DDDataInputStream dataInputStreamWithData:data];
        int isok = [dataInputStream readInt];
        return isok;
    };
    return analysis;
}

- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo)
    {
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:IM_PDU_HEADER_LEN];
        [dataout writeTcpProtocolHeader:DDSERVICE_LOGIN cId:DDSERVICE_LOGIN seqNo:seqNo];
        return [dataout toByteArray];
    };
    return package;
}
@end
