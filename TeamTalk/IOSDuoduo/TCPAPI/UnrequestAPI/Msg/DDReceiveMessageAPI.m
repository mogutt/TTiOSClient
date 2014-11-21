//
//  DDReceiveMessageAPI.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-6-5.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDReceiveMessageAPI.h"
#import "DDMessageEntity.h"
#import "Encapsulator.h"
#import "DDMessageModule.h"
#import "RuntimeStatus.h"
@implementation DDReceiveMessageAPI
- (int)responseServiceID
{
    return DDSERVICE_MESSAGE;
}

- (int)responseCommandID
{
    return DDCMD_MSG_DATA;
}

- (UnrequestAPIAnalysis)unrequestAnalysis
{
    UnrequestAPIAnalysis analysis = (id)^(NSData *data)
    {
        DDDataInputStream* bodyData = [DDDataInputStream dataInputStreamWithData:data];
        DDMessageEntity *msg = [DDMessageEntity makeMessageFromStream:bodyData];
        return msg;
    };
    return analysis;
}
@end
