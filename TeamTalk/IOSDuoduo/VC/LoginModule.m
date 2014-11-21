//
//  DDLoginManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "LoginModule.h"
#import "DDHttpServer.h"
#import "DDTokenManager.h"
#import "DDMsgServer.h"
#import "DDTcpServer.h"
#import "SpellLibrary.h"
#import "DDUserModule.h"
#import "DDLoginServer.h"
#import "DDUserEntity.h"
#import "DDClientState.h"
#import "RuntimeStatus.h"
#import "ContactsModule.h"
#import "DDDatabaseUtil.h"
#import "DDAllUserAPI.h"
#import "ReceiveKickoffAPI.h"
@interface LoginModule(privateAPI)

- (void)p_registerAPI;
- (void)reloginAllFlowSuccess:(void(^)())success failure:(void(^)())failure;

@end

@implementation LoginModule
{
    NSString* _lastLoginUser;       //最后登录的用户ID
    NSString* _lastLoginPassword;
    NSString* _lastLoginUserName;
    NSString* _dao;
    
    BOOL _relogining;
}
+ (instancetype)instance
{
    static LoginModule *g_LoginManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_LoginManager = [[LoginModule alloc] init];
    });
    return g_LoginManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _httpServer = [[DDHttpServer alloc] init];
        _msgServer = [[DDMsgServer alloc] init];
        _tcpServer = [[DDTcpServer alloc] init];
        _loginServer = [[DDLoginServer alloc] init];
        _relogining = NO;
        [self p_registerAPI];
    }
    return self;
}


#pragma mark Public API
- (void)loginWithUsername:(NSString*)name password:(NSString*)password success:(void(^)(DDUserEntity* loginedUser))success failure:(void(^)(NSString* error))failure
{
    //连接登录服务器
    [_tcpServer loginTcpServerIP:SERVER_IP port:SERVER_PORT Success:^{
        //获取消息服务器ip
        [_loginServer connectLoginServerSuccess:^(NSDictionary *loginEntity) {
            //连接消息服务器
            [_tcpServer loginTcpServerIP:[loginEntity objectForKey:@"ip2"] port:[[loginEntity objectForKey:@"port"] intValue] Success:^{
                [_msgServer checkUserID:name Pwd:password token:nil success:^(id object) {
                    _lastLoginPassword=password;
                    _lastLoginUserName=name;
                    DDClientState* clientState = [DDClientState shareInstance];
                    clientState.userState=DDUserOnline;
                    _relogining=YES;
                    DDUserEntity* user = [DDUserEntity dicToUserEntity:(NSDictionary *)object];
                    TheRuntime.user=user;
                    [TheRuntime updateData];
                    [DDNotificationHelp postNotification:DDNotificationUserLoginSuccess userInfo:nil object:user];
                    [self p_loadAllUsersCompletion:^{
                        
                    }];
                    success(user);
                    [ContactsModule getDepartmentData:^(id response) {
                        if (response) {
                            NSArray *array = (NSArray *)response;
                            
                            [[DDDatabaseUtil instance] insertDepartments:array completion:^(NSError *error) {
                                if (!error) {
                                    NSLog(@"插入组织架构完成");
                                }
                            }];
                        }
                    }];
                    
                    
                } failure:^(id object) {
                    DDLog(@"登录验证失败");
                    
                    failure(@"登录验证失败");
                }];
            } failure:^{
                DDLog(@"连接消息服务器出错");
                
                failure(@"连接消息服务器出错");
            }];
        } failure:^{
            DDLog(@"获取消息服务器IP出错");
            
            failure(@"获取消息服务器IP出错");
        }];
    } failure:^{
        DDLog(@"连接登录服务器失败");
        
        failure(@"连接登录服务器失败");
    }];
}

- (void)reloginSuccess:(void(^)())success failure:(void(^)(NSString* error))failure
{
    
    [_tcpServer loginTcpServerIP:SERVER_IP port:SERVER_PORT Success:^{
        //获取消息服务器ip
        [_loginServer connectLoginServerSuccess:^(NSDictionary *loginEntity) {
            //连接消息服务器
            [_tcpServer loginTcpServerIP:[loginEntity objectForKey:@"ip2"] port:[[loginEntity objectForKey:@"port"] intValue] Success:^{
                
                [_msgServer checkUserID:_lastLoginUserName Pwd:_lastLoginPassword token:nil success:^(id object) {
                    DDClientState* clientState = [DDClientState shareInstance];
                    clientState.userState=DDUserOnline;
                    success();
                } failure:^(id object) {
                    DDLog(@"登录验证失败");
                    
                    failure(@"登录验证失败");
                }];
            } failure:^{
                DDLog(@"连接消息服务器出错");
                
                failure(@"连接消息服务器出错");
            }];
        } failure:^{
            DDLog(@"获取消息服务器IP出错");
            
            failure(@"获取消息服务器IP出错");
        }];
    } failure:^{
        DDLog(@"连接登录服务器失败");
        
        failure(@"连接登录服务器失败");
    }];
    
    
    
}

- (void)offlineCompletion:(void(^)())completion
{
    [_tcpServer disconnect];
    completion();
}

//#pragma mark - PrivateAPI
//- (void)reloginAllFlowSuccess:(void(^)())success failure:(void(^)())failure
//{
//    [self loginWithUsername:_lastLoginUserName password:_lastLoginPassword success:^(UserEntity *loginedUser) {
//        success();
//    } failure:^(NSString *error) {
//        failure();
//    }];
//}
//
- (void)p_registerAPI
{
        ReceiveKickoffAPI* api = [[ReceiveKickoffAPI alloc] init];
        [api registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
          
            [DDClientState shareInstance].userState = DDUserKickout;
        }];
}
/**
 *  登录成功后获取所有用户
 *
 *  @param completion 异步执行的block
 */
- (void)p_loadAllUsersCompletion:(void(^)())completion
{
    
    DDAllUserAPI* api = [[DDAllUserAPI alloc] init];
    [api requestWithObject:nil Completion:^(id response, NSError *error) {
        if (!error)
        {
            if ([response count] !=0) {
                [[DDSundriesCenter instance] pushTaskToSerialQueue:^{
                    //写入数据库
                    [response enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        [[SpellLibrary instance] addSpellForObject:obj];
                    }];
                    [[DDDatabaseUtil instance] insertAllUser:response completion:^(NSError *error) {
                        NSLog(@"插入全部用户成功");
                    }];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion();
                    });
                }];
                
            }
            
        }
        else
        {
            [self p_loadAllUsersCompletion:completion];
            DDLog(@"error:%@",[error domain]);
        }
    }];
    
}

@end
