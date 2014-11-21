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
#import "DDGroupMsgReadACKAPI.h"
#import "DDSendMessageReadACKAPI.h"
#import "DDUserModule.h"
#import "DDUnreadMessageGroupAPI.h"
#import "DDReceiveMessageACKAPI.h"
#import "AnalysisImage.h"
#import "DDGroupsUnreadMessageAPI.h"
#import "RecentUsersViewController.h"
#define DDMessage_ID_Key                        @"DDMessage_ID_Key"

@interface DDMessageModule(PrivateAPI)

- (void)p_registerReceiveMessageAPI;
- (void)p_saveReceivedMessage:(DDMessageEntity*)message;
- (void)n_receiveLoginSuccessNotification:(NSNotification*)notification;
- (void)n_receiveUserLogoutNotification:(NSNotification*)notification;
- (NSArray*)p_spliteMessage:(DDMessageEntity*)message;

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
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (NSString *)getMessageID
{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    return uuid;
}

- ( void)getLastMessageForSessionID:(NSString*)sessionID block:(GetLastestMessageCompletion)block {
    NSArray *unReadMessage =[self getUnreadMessageBySessionID:sessionID];
    if([unReadMessage count]!=0)
    {
        block([unReadMessage lastObject]);
    }else
    {
        [[DDDatabaseUtil instance] getLastestMessageForSessionID:sessionID completion:^(DDMessageEntity *message, NSError *error) {
            block(message);
        }];
    }
    
}

- (void)addUnreadMessage:(DDMessageEntity*)message
{
    if (!message)
    {
        return;
    }
    if([message.sessionId isEqualToString:@"1szei2"])
    {
        return;
    }
    
    //senderId 即 sessionId
    if (![message isGroupMessage]) {
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
        [unreadMessages enumerateObjectsUsingBlock:^(DDMessageEntity* messageEntity, NSUInteger idx, BOOL *stop) {
            [[DDDatabaseUtil instance]insertMessages:@[messageEntity] success:^{
                if (![messageEntity isGroupMessage])
                {
                    DDSendMessageReadACKAPI* readACKAPI = [[DDSendMessageReadACKAPI alloc] init];
                    [readACKAPI requestWithObject:messageEntity.sessionId Completion:^(id response, NSError *error) {
                    }];
                }
                else
                {
                    DDLog(@"read group ack");
                    DDGroupMsgReadACKAPI* readACK = [[DDGroupMsgReadACKAPI alloc] init];
                    [readACK requestWithObject:messageEntity.sessionId Completion:nil];
                }
            } failure:^(NSString *errorDescripe) {
                NSLog(@"消息插入DB失败");
            }];
        }];
        
        
    }
    [unreadMessages removeAllObjects];
    [self setApplicationUnreadMsgCount];
}

- (NSUInteger)getUnreadMessageCountForSessionID:(NSString*)sessionID
{
    if ([sessionID isEqualToString:TheRuntime.userID]) {
        return 0;
    }
    
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
-(void)removeFromUnreadMessageButNotSendRead:(NSString*)sessionID
{
    
    NSMutableArray* messages = _unreadMessages[sessionID];
    DDLog(@" remove message %d--->,%@ id is ",[messages count],sessionID);
    if ([messages count]> 0)
    {
        [_unreadMessages removeObjectForKey:sessionID];
    }
    
}
- (NSArray*)popAllUnreadMessagesForSessionID:(NSString*)sessionID
{
    NSMutableArray* messages = _unreadMessages[sessionID];
    if ([messages count]> 0)
    {
        [[DDDatabaseUtil instance] insertMessages:messages success:^{
            DDMessageEntity* message = messages[0];
            if (![message isGroupMessage])
            {
                DDSendMessageReadACKAPI* readACKAPI = [[DDSendMessageReadACKAPI alloc] init];
                [readACKAPI requestWithObject:message.sessionId Completion:^(id response, NSError *error) {
                }];
            }
            else
            {
                DDLog(@"read group ack");
                DDGroupMsgReadACKAPI* readACK = [[DDGroupMsgReadACKAPI alloc] init];
                [readACK requestWithObject:message.sessionId Completion:nil];
            }
        } failure:^(NSString *errorDescripe) {
            NSLog(@"消息插入DB失败");
            
        }];
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
    [receiveMessageAPI registerAPIInAPIScheduleReceiveData:^(DDMessageEntity* object, NSError *error) {
        object.state=DDmessageSendSuccess;
        DDReceiveMessageACKAPI *rmack = [[DDReceiveMessageACKAPI alloc] init];
        [rmack requestWithObject:@[object.senderId,@(object.seqNo)] Completion:^(id response, NSError *error) {
            
        }];
        NSArray* messages = [self p_spliteMessage:object];
        [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self p_saveReceivedMessage:obj];
        }];
        
    }];
}

- (void)p_saveReceivedMessage:(DDMessageEntity*)messageEntity
{
    
    DDSessionEntity* session = [[DDSessionEntity alloc] initWithSessionID:messageEntity.sessionId type:messageEntity.msgType];
    [session updateUpdateTime:messageEntity.msgTime];
    if (messageEntity)
    {
        [AnalysisImage analysisImage:messageEntity Block:^(NSMutableArray *array) {
            [array enumerateObjectsUsingBlock:^(DDMessageEntity *obj, NSUInteger idx, BOOL *stop) {
                obj.state = DDmessageSendSuccess;
                if (![TheRuntime isInShielding:messageEntity.sessionId]) {
                    [self addUnreadMessage:obj];
                }
                [DDNotificationHelp postNotification:DDNotificationReceiveMessage userInfo:nil object:messageEntity];
                
            }];
        }];
        
    }
}

- (void)n_receiveLoginSuccessNotification:(NSNotification*)notification
{
    _unreadMessages = [[NSMutableDictionary alloc] init];
    DDGetUnreadMessageUsersAPI* getUnreadMessageUsersAPI = [[DDGetUnreadMessageUsersAPI alloc] init];
    [getUnreadMessageUsersAPI requestWithObject:nil Completion:^(id response, NSError *error) {
        if(error) {
            DDLog("message#get unread message user count response,%@",error);
            return;
        }
        NSArray* usersArray = (NSArray*)response;
        [usersArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString* userID = (NSString*)obj;
            DDGetUserUnreadMessagesAPI* getUserUnreadMessageAPI = [[DDGetUserUnreadMessagesAPI alloc] init];
            [getUserUnreadMessageAPI requestWithObject:userID Completion:^(id response, NSError *error) {
                if(error) {
                    DDLog("message#get user unread message response,%@",error);
                    return;
                }
                NSDictionary* dictionary = (NSDictionary*)response;
                NSArray* tempmessages = dictionary[@"msgArray"];
           
                for (int index = [tempmessages count] - 1; index >= 0; index --) {
                    DDMessageEntity* message = tempmessages[index];
                    message.state = DDmessageSendSuccess;
                    if(![message.sessionId isEqualToString:@"1szei2"])
                    {
                        NSArray* temp = [self p_spliteMessage:message];
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [temp enumerateObjectsUsingBlock:^(DDMessageEntity *obj, NSUInteger idx, BOOL *stop) {
                                //如果不是自己法的，插入未读
//                                if (![message.sessionId isEqualToString:TheRuntime.user.objID]) {
                                    [self addUnreadMessage:obj];
//                                }else
//                                {
//                                    //否则直接存入数据库并发送已读ack
//                                    DDSendMessageReadACKAPI* readACKAPI = [[DDSendMessageReadACKAPI alloc] init];
//                                    [readACKAPI requestWithObject:TheRuntime.user.objID Completion:^(id response, NSError *error) {
//                                    }];
//                                    [[DDDatabaseUtil instance]insertMessages:@[obj] success:^{
//                                        
//                                    } failure:^(NSString *errorDescripe) {
//                                        NSLog(@"消息插入DB失败");
//                                    }];
//                                }
                                
                            }];
                        });
                       
    
                    }
                    
                }
                if ([tempmessages count] > 0)
                {
                    [DDNotificationHelp postNotification:DDNotificationUpdateUnReadMessage userInfo:nil object:[NSString stringWithFormat:@"user_%@",userID]];
                    [[RecentUsersViewController shareInstance] setToolbarBadge];
                    
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
                NSDictionary* dic = (NSDictionary*)response;
                NSString* sessionID = dic[@"sessionId"];
                
                [self removeArrayMessage:sessionID];
                NSArray* tempmessages = dic[@"msgArray"];
                DDLog("message#get user unread message response,%d,%@",[tempmessages count],groupID);
  
                for (int index = [tempmessages count] - 1; index >= 0; index --) {
                    DDMessageEntity* message = tempmessages[index];
                    
                    message.state = DDmessageSendSuccess;
                    NSArray* temp = [self p_spliteMessage:message];
                    [temp enumerateObjectsUsingBlock:^(DDMessageEntity *obj, NSUInteger idx, BOOL *stop) {
                        //如果不是自己发的插入未读消息
                        NSLog(@"%@----->",TheRuntime.user.objID);
                        if (![message.sessionId isEqualToString:TheRuntime.user.objID]) {
                            DDLog(@"read group ack");
                            [self addUnreadMessage:obj];
                        }else
                        {
                            //否则直接存入数据库并发送已读ack
                            
                            DDGroupMsgReadACKAPI* readACK = [[DDGroupMsgReadACKAPI alloc] init];
                            [readACK requestWithObject:message.sessionId Completion:nil];
                            [[DDDatabaseUtil instance]insertMessages:@[obj] success:^{
                                
                            } failure:^(NSString *errorDescripe) {
                                NSLog(@"消息插入DB失败");
                            }];
                        }

                    }];
           
                }
                if ([tempmessages count] > 0)
                {
                    [DDNotificationHelp postNotification:DDNotificationUpdateUnReadMessage userInfo:nil object:[NSString stringWithFormat:@"group_%@",groupID]];
                    [[RecentUsersViewController shareInstance] setToolbarBadge];
                    
                }
            }];
        }];
    }];
    
    
    
}
-(void)removeArrayMessage:(NSString*)sessionId
{
    if(!sessionId)
        return;
    [_unreadMessages removeObjectForKey:sessionId];
    [self setApplicationUnreadMsgCount];
}

- (void)n_receiveUserLogoutNotification:(NSNotification*)notification
{
    _unreadMessages = nil;
    _unreadMessages = [[NSMutableDictionary alloc] init];
}

- (NSArray*)p_spliteMessage:(DDMessageEntity*)message
{
    NSMutableArray* messageContentArray = [[NSMutableArray alloc] init];
    if (message.msgContentType == DDMessageTypeImage || (message.msgContentType == DDMessageTypeText && [message.msgContent rangeOfString:DD_MESSAGE_IMAGE_PREFIX].length > 0))
    {
        NSString* messageContent = [message msgContent];
        NSArray* tempMessageContent = [messageContent componentsSeparatedByString:DD_MESSAGE_IMAGE_PREFIX];
        [tempMessageContent enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString* content = (NSString*)obj;
            if ([content length] > 0)
            {
                NSRange suffixRange = [content rangeOfString:DD_MESSAGE_IMAGE_SUFFIX];
                if (suffixRange.length > 0)
                {
                    //是图片,再拆分
                    NSString* imageContent = [NSString stringWithFormat:@"%@%@",DD_MESSAGE_IMAGE_PREFIX,[content substringToIndex:suffixRange.location + suffixRange.length]];
                    DDMessageEntity* messageEntity = [[DDMessageEntity alloc] initWithMsgID:[DDMessageModule getMessageID] msgType:message.msgType msgTime:message.msgTime sessionID:message.sessionId senderID:message.senderId msgContent:imageContent toUserID:message.toUserID];
                    messageEntity.msgContentType = DDMessageTypeImage;
                    messageEntity.state = DDmessageSendSuccess;
                    [messageContentArray addObject:messageEntity];
                    
                    
                    NSString* secondComponent = [content substringFromIndex:suffixRange.location + suffixRange.length];
                    if (secondComponent.length > 0)
                    {
               
                        DDMessageEntity* secondmessageEntity = [[DDMessageEntity alloc] initWithMsgID:[DDMessageModule getMessageID] msgType:message.msgType msgTime:message.msgTime sessionID:message.sessionId senderID:message.senderId msgContent:secondComponent toUserID:message.toUserID];
                        secondmessageEntity.msgContentType = DDMessageTypeText;
                        secondmessageEntity.state = DDmessageSendSuccess;
                        [messageContentArray addObject:secondmessageEntity];
                    }
                }
                else
                {
           
                    DDMessageEntity* messageEntity = [[DDMessageEntity alloc] initWithMsgID:[DDMessageModule getMessageID] msgType:message.msgType msgTime:message.msgTime sessionID:message.sessionId senderID:message.senderId msgContent:content toUserID:message.toUserID];
                    messageEntity.msgContentType = DDMessageTypeText;
                    messageEntity.state = DDmessageSendSuccess;
                    [messageContentArray addObject:messageEntity];
                }
            }
        }];
    }
    if ([messageContentArray count] == 0)
    {
        [messageContentArray addObject:message];
    }
    return messageContentArray;
}

-(void)setApplicationUnreadMsgCount
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[self getUnreadMessgeCount]];
}

@end