//
//  DDMsgServer.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDMsgServer.h"
//#import "LoginEntity.h"
#import "DDTcpClientManager.h"
#import "DDLoginAPI.h"
#import "MD5.h"
//#import "LoginEntity.h"
static int const timeOutTimeInterval = 10;

typedef void(^Success)(id object);

@interface DDMsgServer(PrivateAPI)

- (void)n_receiveLoginMsgServerNotification:(NSNotification*)notification;
- (void)n_receiveLoginLoginServerNotification:(NSNotification*)notification;

@end

@implementation DDMsgServer
{
    Success _success;
    Failure _failure;
    
    BOOL _connecting;
    NSUInteger _connectTimes;
}
- (id)init
{
    self = [super init];
    if (self)
    {
        _connecting = NO;
        _connectTimes = 0;
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveLoginMsgServerNotification:) name:notificationLoginMsgServerSuccess object:nil];
    }
    return self;
}

-(void)checkUserID:(NSString*)userID Pwd:(NSString *)password token:(NSString*)token success:(void(^)(id object))success failure:(void(^)(id object))failure
{
    if(userID && password)
    {
        if (!_connecting)
        {
            
            NSNumber* clientType = @(17);
            
            NSArray* parameter = @[userID,[MD5 getMD5:password],[NSNumber numberWithInteger:1],clientType];
            
            DDLoginAPI* api = [[DDLoginAPI alloc] init];
            [api requestWithObject:parameter Completion:^(id response, NSError *error) {
                if (!error)
                {
                    if (response)
                    {
                        /*
                         result = @{@"serverTime":@(serverTime),
                         @"result":@(loginResult),
                         @"state":@(state),
                         @"userName":userName,
                         @"nickName":nickName,
                         @"avatar":avatar,
                         @"userType":@(userType)};
                         */
                        success(response);
                    }
                    else
                    {
                        NSError* newError = [NSError errorWithDomain:@"登录验证失败" code:6 userInfo:nil];
                        failure(newError);
                    }
                }
                else
                {
                    DDLog(@"error:%@",[error domain]);
                    failure(error);
                }
            }];
        }else{
            failure([NSError errorWithDomain:@"用户名密码未空" code:909 userInfo:nil]);
        }
    
   
    }
}

@end
