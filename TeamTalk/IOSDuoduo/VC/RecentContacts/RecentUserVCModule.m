//
//  DDRecentUserVCModule.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "RecentUserVCModule.h"
#import "RecentConactsAPI.h"
#import "DDUserModule.h"
#import "DDDatabaseUtil.h"
#import "DDGroupModule.h"
#import "DDMessageEntity.h"
#import "DDMessageModule.h"
#import "RuntimeStatus.h"
#import "DDRecentGroupAPI.h"
#import "DDUserDetailInfoAPI.h"
#import "GetGroupInfoAPI.h"
@interface RecentUserVCModule()
@property(strong)NSMutableArray *fixedArray;

@end
@implementation RecentUserVCModule
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.items= [NSMutableArray new];
        self.ids = [NSMutableArray new];
        self.fixedArray = [NSMutableArray new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveStartLoginNotification:) name:DDNotificationStartLogin object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveLoginSuccessNotification:) name:DDNotificationUserLoginSuccess object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(n_receiveMessageNotification:)
                                                     name:DDNotificationReceiveMessage
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveRecentContactsUpdateNotification:) name:DDNotificationRecentContactsUpdate object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveUserKickOffNotification:) name:DDNotificationUserKickouted object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sentMessageSuccessfull:) name:@"SentMessageSuccessfull" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveUnreadMessageUpdateNotification:) name:DDNotificationUpdateUnReadMessage object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocalGroup) name:DDNotificationLoadLocalGroupFinish object:nil];
        [self loadRecentUserAndGroup];
    }
    return self;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DDNotificationStartLogin" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DDNotificationUserLoginFailure" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DDNotificationUserLoginSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DDNotificationReceiveMessage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DDNotificationUserKickouted" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DDNotificationRecentContactsUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SentMessageSuccessfull" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DDNotificationUpdateUnReadMessage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DDNotificationLoadLocalGroupFinish" object:nil];
}

-(void)loadRecentUserAndGroup
{
    //优先加载本地联系人和群
    __block int i =0;
    [[DDDatabaseUtil instance] loadContactsCompletion:^(NSArray *contacts, NSError *error) {
        [contacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            DDUserEntity* user = (DDUserEntity*)obj;
            [[DDUserModule shareInstance] addRecentUser:user];
            [[DDUserModule shareInstance] addMaintanceUser:user];
            if (![self.ids containsObject:user.objID]) {
                [self.ids addObject:user.objID];
                [self.items addObject:user];
            }
            
        }];
        
        if (i == 1) {
              [self sortItems];
        }else
        {
            i=i+1;
        }
    }];
    [[[DDGroupModule instance] recentlyGroup] enumerateKeysAndObjectsUsingBlock:^(NSString *key, DDGroupEntity *obj, BOOL *stop) {
        if (![self.ids containsObject:key]) {
            [self.ids addObject:key];
            [self.items addObject:obj];
        }
        
    }];
    if (i == 1) {
        [self sortItems];
    }else
    {
        i=i+1;
    }
    __block int j =0;
        RecentConactsAPI* recentContactsAPI = [[RecentConactsAPI alloc] init];
        [recentContactsAPI requestWithObject:nil Completion:^(id response, NSError *error) {
            if (!error)
            {
                NSMutableArray* recentContacts = (NSMutableArray*)response;
                [recentContacts enumerateObjectsUsingBlock:^(DDUserEntity *obj, NSUInteger idx, BOOL *stop) {
                    
                    [[DDUserModule shareInstance] addRecentUser:obj];
                    if (![self.ids containsObject:obj.objID]) {
                        [self.ids addObject:obj.objID];
                        [self.items addObject:obj];
                        
                    }else{
                        NSLog(@"没发现最近联系人");
                    }

                }];
                
                if (j == 1) {
                    [self sortItems];
                }else
                {
                    j=j+1;
                }
            }
            else{
                
                DDLog(@"load recentUsers failure error:%@",error.domain);
            }
        }];
        
        DDRecentGroupAPI *recentGroup = [[DDRecentGroupAPI alloc] init];
        [recentGroup requestWithObject:nil Completion:^(id response, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[DDGroupModule instance] addRecentlyGroup:response];
                    [[[DDGroupModule instance] recentlyGroup] enumerateKeysAndObjectsUsingBlock:^(NSString *key, DDGroupEntity *obj, BOOL *stop) {
                        if (![self.ids containsObject:key]) {
                            [self.ids addObject:key];
                            [self.items addObject:obj];
                        }
                        
                    }];
                });

                if (j == 1) {
                    [self sortItems];
                }else
                {
                    j=j+1;
                }

            }else{
             DDLog(@"load recentGroup failure error:%@",error.domain);
            }
        }];
  
}
/**
 *   接收未读消息通知
 *
 *  @param notification <#notification description#>
 */
- (void)n_receiveUnreadMessageUpdateNotification:(NSNotification*)notification

{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *senderID = [notification object];
        NSString *newID = [senderID componentsSeparatedByString:@"_"][1];
        if ([senderID hasPrefix:@"user_"]) {
            if ([self.ids containsObject:newID]) {
                [self.items enumerateObjectsUsingBlock:^(DDBaseEntity *obj, NSUInteger idx, BOOL *stop) {
                    if ([obj.objID isEqualToString:newID]) {
                        [self.items removeObjectAtIndex:idx];
                        [self.items insertObject:obj atIndex:[TheRuntime getFixedTopCount]];
                        dispatch_async(dispatch_get_main_queue(),  ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshRecentData" object:nil];
                        });
           
                    }
                }];
            }else
            {
                [[DDUserModule shareInstance] getUserForUserID:newID Block:^(DDUserEntity *user) {
                    if (user) {
                        [self.ids addObject:user.objID];
                        [self.items insertObject:user atIndex:[TheRuntime getFixedTopCount]];
                        dispatch_async(dispatch_get_main_queue(),  ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshRecentData" object:nil];
                        });
                    }else{
                        DDLog(@"remove id unread message,from user,%@---->",newID);
                        [[DDMessageModule shareInstance] removeFromUnreadMessageButNotSendRead:newID];
                    }
                }];
            }
            
        }else
        {
           
           
                if ([self.ids containsObject:newID]) {
                    [self.items enumerateObjectsUsingBlock:^(DDBaseEntity *obj, NSUInteger idx, BOOL *stop) {
                        if ([obj.objID isEqualToString:newID]) {
                            [self.items removeObjectAtIndex:idx];
                            [self.items insertObject:obj atIndex:[TheRuntime getFixedTopCount]];
                            dispatch_async(dispatch_get_main_queue(),  ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshRecentData" object:nil];
                            });
                        }
                    }];
                    
                }else
                {
                    GetGroupInfoAPI *group = [[GetGroupInfoAPI alloc] init];
                    [group requestWithObject:newID Completion:^(DDGroupEntity *response, NSError *error) {
                        if (response) {
                            [self.ids addObject:newID];
                            [self.items insertObject:group atIndex:[TheRuntime getFixedTopCount]];
                            dispatch_async(dispatch_get_main_queue(),  ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshRecentData" object:nil];
                            });
                        }
                    }];
                }
      
            
        }
    });
    
    
 
    
}
/**
 *  收到消息通知
 *
 *  @param notification
 */
- (void)n_receiveMessageNotification:(NSNotification*)notification
{
    //如果当前items为空，则暂存
    
    DDMessageEntity* message = [notification object];
    __block BOOL findID =NO;
    [self.items enumerateObjectsUsingBlock:^(DDBaseEntity *obj, NSUInteger idx, BOOL *stop) {
        if ([message.sessionId isEqualToString:obj.objID]) {
            [self.items removeObject:obj];
            [self insertWhere:obj.objID Object:obj];
            findID=YES;
        }
        
    }];
    if (!findID) {
        BOOL isGroup = [message isGroupMessage];
        if (isGroup) {
            GetGroupInfoAPI *group = [[GetGroupInfoAPI alloc] init];
            [group requestWithObject:message.sessionId Completion:^(DDGroupEntity *response, NSError *error) {
                if (response) {
                    [self insertWhere:response.objID Object:response];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshRecentData" object:nil];
                }
            }];
        }else{
            [[DDUserModule shareInstance] getUserForUserID:message.sessionId Block:^(DDUserEntity *user) {
                if (user) {
                    [self.ids addObject:user.objID];
                    [self insertWhere:user.objID Object:user];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshRecentData" object:nil];
                }
            }];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshRecentData" object:nil];
}
/**
 *  对最近联系人和群组进行排序
 */
-(void)sortItems
{
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"_lastUpdateTime" ascending:NO];
    [self.items sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [self.items enumerateObjectsUsingBlock:^(DDBaseEntity *obj, NSUInteger idx, BOOL *stop) {
        if ([TheRuntime isInFixedTop:obj.objID]) {
            [self.fixedArray addObject:obj];
        }

    }];
    [self.items removeObjectsInArray:self.fixedArray];
    [self.items insertObjects:self.fixedArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.fixedArray count])]];
 
    [self.fixedArray removeAllObjects];
     [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshRecentData" object:nil];
}
- (void)n_receiveStartLoginNotification:(NSNotification*)notification
{
    
}

- (void)n_receiveLoginSuccessNotification:(NSNotification*)notification
{
    //self.title = @"最近联系人";
}


- (void)n_receiveUserKickOffNotification:(NSNotification*)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您的帐号在别处登录" delegate:self cancelButtonTitle:nil otherButtonTitles:@"重连", nil];
    [alert show];
    
}
-(void)sentMessageSuccessfull:(NSNotification *)notification
{
    NSString *senderID = [notification object];
    __block BOOL isInsert = NO;
    [self.items enumerateObjectsUsingBlock:^(DDBaseEntity *obj, NSUInteger idx, BOOL *stop) {
        if ([senderID isEqualToString:obj.objID]) {
            [self.items removeObject:obj];
            [self insertWhere:obj.objID Object:obj];
            isInsert = YES;
        }
        
    }];
    if (!isInsert) {
        DDGroupEntity *group = [[DDGroupModule instance] getGroupByGId:senderID];
        if (group) {
            [self insertWhere:group.objID Object:group];
        }else
        {
            [[DDUserModule shareInstance] getUserForUserID:senderID Block:^(DDUserEntity *user) {
                [self insertWhere:user.objID Object:user];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshRecentData" object:nil];
            }];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshRecentData" object:nil];
    
}
-(void)insertWhere:(NSString *)idString Object:(id)ins
{
    if ([TheRuntime isInFixedTop:idString]) {
        [self.items insertObject:ins atIndex:0];
    }else
    {
        
        [self.items insertObject:ins atIndex:[TheRuntime getFixedTopCount]];
    }
}
@end