//
//  DDReceiveMessageACKAPI.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-09.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "DDReceiveMessageACKAPI.h"

@implementation DDReceiveMessageACKAPI

- (int)requestTimeOutTimeInterval
{
    return 0;
}

- (int)requestServiceID
{
    return DDSERVICE_MESSAGE;
}

- (int)responseServiceID
{
    return DDSERVICE_MESSAGE;
}

- (int)requestCommendID
{
    return 2;
}

- (int)responseCommendID
{
    return 2;
}

- (Analysis)analysisReturnData
{
    return nil;
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
        int seqNum =[object[1] intValue];
        uint32_t totalLen = IM_PDU_HEADER_LEN + 4 + strLen(object[0])+sizeof(seqNum);
        [dataout writeInt:totalLen];
        [dataout writeTcpProtocolHeader:DDSERVICE_MESSAGE cId:2 seqNo:seqNo];
        [dataout writeInt:seqNum];
        [dataout writeUTF:object[0]];
        return [dataout toByteArray];
    };
    return package;
}
@end
