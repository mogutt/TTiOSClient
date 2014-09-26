//
//  DDLoginServer.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-12.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDLoginServer.h"
#import "DDTcpClientManager.h"
#import "DDMsgServerIPAPI.h"

typedef void(^LoginServerSuccess)(id loginEntity);
typedef void(^LoginServerFailure)();

static NSInteger const timeoutInterval = 10;

@interface DDLoginServer(Notification)


@end

@implementation DDLoginServer
{
    LoginServerSuccess _success;
    LoginServerFailure _failure;
    BOOL _logining;
    NSUInteger _connectTimes;
}
- (id)init
{
    self = [super init];
    if (self)
    {
        _logining = NO;
        _connectTimes = 0;
    }
    return self;
}

- (void)connectLoginServerSuccess:(void(^)(NSDictionary* loginEntity))success failure:(void(^)())failure
{
    //系统发送请求消息服务器IP,端口
    
    if (!_logining)
    {
        DDMsgServerIPAPI* api = [[DDMsgServerIPAPI alloc] init];
        NSNumber* type = @0;
        [api requestWithObject:type Completion:^(id response, NSError *error) {
            if (!error) {
                _logining = NO;
                success(response);
            }
            else
            {
                DDLog(@"error:%@",[error domain]);
                failure();
            }
        }];
    }
}


@end
