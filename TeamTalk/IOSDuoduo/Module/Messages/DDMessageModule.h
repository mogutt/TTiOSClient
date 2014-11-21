//
//  DDMessageModule.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-27.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDMessageEntity.h"

typedef void(^GetLastestMessageCompletion)(DDMessageEntity* message);
typedef void(^GetUnreadMessageCount)(NSInteger count);
@interface DDMessageModule : NSObject
+ (instancetype)shareInstance;

+ (NSString *)getMessageID;

/**
 *  获得最新的消息
 *
 *  @param sessionID  会话ID
 *  @param completion 完成获取
 */
- ( void)getLastMessageForSessionID:(NSString*)sessionID block:(GetLastestMessageCompletion)block;
-(void)removeFromUnreadMessageButNotSendRead:(NSString*)sessionID;
- (void)addUnreadMessage:(DDMessageEntity*)message;
- (void)clearUnreadMessagesForSessionID:(NSString*)sessionID;
- (NSUInteger)getUnreadMessgeCount;
-(NSArray *)getUnreadMessageBySessionID:(NSString *)sessionID;
- (NSUInteger)getUnreadMessageCountForSessionID:(NSString*)sessionID;
- (NSArray*)popAllUnreadMessagesForSessionID:(NSString*)sessionID;
@end
