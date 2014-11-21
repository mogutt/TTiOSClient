//
//  ShieldGroupMessageAPI.m
//  TeamTalk
//
//  Created by Michael Scofield on 2014-10-20.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "ShieldGroupMessageAPI.h"

@implementation ShieldGroupMessageAPI
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
    return MODULE_ID_GROUP;
}

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID
{
    return MODULE_ID_GROUP;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return MODULE_ID_GROUP;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return MODULE_ID_GROUP;
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
        int isOk = [bodyData readInt];
        return nil;
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
        NSArray* array = (NSArray*)object;
        NSString* groupID = array[0];
        uint32_t isShield = [array[1] intValue];

        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        uint32_t totalLen = IM_PDU_HEADER_LEN + strLen(groupID) + 8;
        
      
        [dataout writeInt:totalLen];
        [dataout writeTcpProtocolHeader:MODULE_ID_GROUP
                                    cId:MODULE_ID_GROUP
                                  seqNo:seqNo];
        [dataout writeUTF:groupID];
        [dataout writeInt:isShield];
        return [dataout toByteArray];
    };
    return package;
}
@end
