//
//  DDTokenManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDTokenManager.h"
#import "DDAFClient.h"
#import "RuntimeStatus.h"
static NSInteger const refreshTokenTimeInterval = 60 * 30;

@interface DDTokenManager(privateAPI)

- (void)p_refreshTokenTimer:(NSTimer*)timer;

@end

@implementation DDTokenManager
{
    NSTimer* _timer;
}
- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)refreshTokenWithDao:(NSString*)dao
                    Success:(void(^)(NSString* token))success
                    failure:(void(^)(id error))failure
{
    //DDHttpModule* module = [DDHttpModule shareInstance];
    NSMutableDictionary* dictParams = [NSMutableDictionary dictionary];
    [dictParams setObject:@"imclient" forKey:@"mac"];
    [dictParams setObject:dao forKey:@"dao"];
    [DDAFClient jsonFormPOSTRequest:@"mtalk/iauth" param:dictParams success:^(id result) {
        TheRuntime.token=[result valueForKey:@"token"];
          [self setToken:[result valueForKey:@"token"]];
    } failure:^(NSError *error) {
        failure(error);
    }];

}

- (void)startAutoRefreshToken
{
    if (!_timer && ![_timer isValid])
    {
         _timer = [NSTimer scheduledTimerWithTimeInterval:refreshTokenTimeInterval target:self selector:@selector(p_refreshTokenTimer:) userInfo:nil repeats:YES];
    }
}

- (void)stopAutoRefreshToken
{
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark privateAPI
- (void)p_refreshTokenTimer:(NSTimer *)timer
{
    [self refreshTokenWithDao:TheRuntime.dao Success:^(NSString *token) {
        DDLog(@"刷新Token成功");
    } failure:^(id error) {
        NSLog(@"------%@",TheRuntime.token);
        DDLog(@"刷新Token失败");
    }];
}
@end
