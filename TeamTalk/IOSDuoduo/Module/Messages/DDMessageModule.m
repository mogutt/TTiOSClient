//
//  DDMessageModule.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-27.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDMessageModule.h"
#import "DDDatabaseUtil.h"
#import "DDReceiveMessageAPI.h"
#import "DDGetUnreadMessageUsersAPI.h"
#import "DDGetUserUnreadMessagesAPI.h"
#import "DDAFClient.h"
#import "DDSessionEntity.h"
#import "RuntimeStatus.h"
#import "DDSendMessageReadACKAPI.h"
#import "DDUserModule.h"
#import "DDUnreadMessageGroupAPI.h"
#import "DDReceiveMessageACKAPI.h"
#import "DDGroupsUnreadMessageAPI.h"
#define DDMessage_ID_Key                        @"DDMessage_ID_Key"

@interface DDMessageModule(PrivateAPI)

- (void)p_registerReceiveMessageAPI;
- (void)p_saveReceivedMessage:(DDMessageEntity*)message;
- (void)n_receiveLoginSuccessNotification:(NSNotification*)notification;
- (void)n_receiveUserLogoutNotification:(NSNotification*)notification;

@end

@implementation DDMessageModule
{
    NSMutableDictionary* _unreadMessages;
}
+ (instancetype)shareInstance
{
    static DDMessageModule* g_messageModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_messageModule = [[DDMessageModule alloc] init];
    });
    return g_messageModule;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        //注册收到消息API
        _unreadMessages = [[NSMutableDictionary alloc] init];
        [self p_registerReceiveMessageAPI];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveLoginSuccessNotification:) name:DDNotificationUserLoginSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveLoginSuccessNotification:) name:DDNotificationUserReloginSuccess object:nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveUserLogoutNotification:) name:MGJUserDidLogoutNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (NSUInteger)getMessageID
{
    NSInteger messageID = [[NSUserDefaults standardUserDefaults] integerForKey:DDMessage_ID_Key];
    NSInteger resultMessageID = messageID;
    messageID ++;
    [[NSUserDefaults standardUserDefaults] setInteger:messageID forKey:DDMessage_ID_Key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return resultMessageID;
}

- (void)getLastMessageForSessionID:(NSString*)sessionID completion:(GetLastestMessageCompletion)completion
{
    //有未读消息
    if ([_unreadMessages[sessionID] count] > 0)
    {
        NSMutableArray* unreadMessages = _unreadMessages[sessionID];
        DDMessageEntity* message = [unreadMessages lastObject];
        completion(message);
        return;
    }
    //没有未读消息，读数据库
    [[DDDatabaseUtil instance] getLastestMessageForSessionID:sessionID completion:^(DDMessageEntity *message, NSError *error) {
        completion(message);
    }];
}

- (void)addUnreadMessage:(DDMessageEntity*)message
{
    if (!message)
    {
        return;
    }
    //senderId 即 sessionId
    if (message.msgType == DDMessageTypeText || message.msgType == DDMessageTypeVoice) {
        if ([[_unreadMessages allKeys] containsObject:message.senderId])
        {
            NSMutableArray* unreadMessage = _unreadMessages[message.senderId];
            [unreadMessage addObject:message];
        }
        else
        {
            NSMutableArray* unreadMessages = [[NSMutableArray alloc] init];
            [unreadMessages addObject:message];
            [_unreadMessages setObject:unreadMessages forKey:message.senderId];
        }
    }else
    {
        if ([[_unreadMessages allKeys] containsObject:message.sessionId])
        {
            NSMutableArray* unreadMessage = _unreadMessages[message.sessionId];
            [unreadMessage addObject:message];
        }
        else
        {
            NSMutableArray* unreadMessages = [[NSMutableArray alloc] init];
            [unreadMessages addObject:message];
            [_unreadMessages setObject:unreadMessages forKey:message.sessionId];
        }
    }
    
}

- (void)clearUnreadMessagesForSessionID:(NSString*)sessionID
{
    NSMutableArray* unreadMessages = _unreadMessages[sessionID];
    if (unreadMessages)
    {
        DDSendMessageReadACKAPI* sendMessageReadACKAPI = [[DDSendMessageReadACKAPI alloc] init];
        [sendMessageReadACKAPI requestWithObject:sessionID Completion:nil];
        
    }
        [unreadMessages removeAllObjects];
}

- (NSUInteger)getUnreadMessageCountForSessionID:(NSString*)sessionID
{
    NSMutableArray* unreadMessages = _unreadMessages[sessionID];
    return [unreadMessages count];
}
-(NSArray *)getUnreadMessageBySessionID:(NSString *)sessionID
{
    return _unreadMessages[sessionID];
}

- (NSUInteger)getUnreadMessgeCount
{
    __block NSUInteger count = 0;
    [_unreadMessages enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        count += [obj count];
    }];
    return count;
}

- (NSArray*)popAllUnreadMessagesForSessionID:(NSString*)sessionID
{
    NSMutableArray* messages = _unreadMessages[sessionID];
    if ([messages count]> 0)
    {
        [_unreadMessages removeObjectForKey:sessionID];
        return messages;
    }
    else
    {
        return nil;
    }
}

#pragma mark - privateAPI
- (void)p_registerReceiveMessageAPI
{
    DDReceiveMessageAPI* receiveMessageAPI = [[DDReceiveMessageAPI alloc] init];
    [receiveMessageAPI registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
        DDReceiveMessageACKAPI *rmack = [[DDReceiveMessageACKAPI alloc] init];
        [rmack requestWithObject:@[[RuntimeStatus instance].user.userId,object[1]] Completion:^(id response, NSError *error) {
            
        }];
        DDMessageEntity* messageEntity = (DDMessageEntity*)object[0];
        
        [self p_saveReceivedMessage:messageEntity];
        

    }];
    
    
}

- (void)p_saveReceivedMessage:(DDMessageEntity*)messageEntity
{
    //保存到数据库

    [[DDDatabaseUtil instance]insertMessages:@[messageEntity] success:^{
        
    } failure:^(NSString *errorDescripe) {
        NSLog(@"消息插入DB失败");
    }];
    SessionType type =messageEntity.msgType<5?SESSIONTYPE_SINGLE:SESSIONTYPE_TEMP_GROUP;
    DDSessionEntity* session = [[DDSessionEntity alloc] initWithSessionID:messageEntity.senderId type:type];
    [session updateUpdateTime:messageEntity.msgTime];
    if (messageEntity)
    {
        if (messageEntity.msgContent)
        {
   
                [self addUnreadMessage:messageEntity];
                [DDNotificationHelp postNotification:DDNotificationReceiveMessage userInfo:nil object:messageEntity];

        }
    }
}

- (void)n_receiveLoginSuccessNotification:(NSNotification*)notification
{
    DDGetUnreadMessageUsersAPI* getUnreadMessageUsersAPI = [[DDGetUnreadMessageUsersAPI alloc] init];
    [getUnreadMessageUsersAPI requestWithObject:nil Completion:^(id response, NSError *error) {
        NSArray* usersArray = (NSArray*)response;
        [usersArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString* userID = (NSString*)obj;
            DDGetUserUnreadMessagesAPI* getUserUnreadMessageAPI = [[DDGetUserUnreadMessagesAPI alloc] init];
            [getUserUnreadMessageAPI requestWithObject:userID Completion:^(id response, NSError *error) {
                
                [self clearUnreadMessagesForSessionID:userID];
                NSDictionary* dictionary = (NSDictionary*)response;
                NSArray* messages = dictionary[@"msgArray"];
                for (int index = [messages count] - 1; index >= 0; index --) {
                    DDMessageEntity* message = messages[index];
                    message.state = DDmessageSendSuccess;
                    [self addUnreadMessage:message];
                }
                if ([messages count] > 0)
                {
                    [DDNotificationHelp postNotification:DDNotificationUpdateUnReadMessage userInfo:nil object:[NSString stringWithFormat:@"user_%@",userID]];
                }
            }];
        }];
    }];
    
    
    DDUnreadMessageGroupAPI* getUnreadMessageGroupsAPI = [[DDUnreadMessageGroupAPI alloc] init];
    [getUnreadMessageGroupsAPI requestWithObject:nil Completion:^(id response, NSError *error) {
        NSArray* usersArray = (NSArray*)response;
        [usersArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString* groupID = (NSString*)obj;
            DDGroupsUnreadMessageAPI* getUserUnreadMessageAPI = [[DDGroupsUnreadMessageAPI alloc] init];
            [getUserUnreadMessageAPI requestWithObject:groupID Completion:^(id response, NSError *error) {
                
                [self clearUnreadMessagesForSessionID:groupID];
                NSArray* messages =(NSArray*)response;
                for (int index = [messages count] - 1; index >= 0; index --) {
                    DDMessageEntity* message = messages[index];
                    message.state = DDmessageSendSuccess;
                    [self addUnreadMessage:message];
                }
                if ([messages count] > 0)
                {
                    [DDNotificationHelp postNotification:DDNotificationUpdateUnReadMessage userInfo:nil object:[NSString stringWithFormat:@"group_%@",groupID]];
                }
            }];
        }];
    }];
    
    
    
}

- (void)n_receiveUserLogoutNotification:(NSNotification*)notification
{
    _unreadMessages = nil;
    _unreadMessages = [[NSMutableDictionary alloc] init];
}

@end
