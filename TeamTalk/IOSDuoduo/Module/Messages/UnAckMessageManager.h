//
//  UnAckMessageManage.h
//  TeamTalk
//
//  Created by Michael Scofield on 2014-10-16.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDMessageEntity.h"
@interface UnAckMessageManager : NSObject
+ (instancetype)instance;
-(void)removeMessageFromUnAckQueue:(DDMessageEntity *)message;
-(void)addMessageToUnAckQueue:(DDMessageEntity *)message;
-(BOOL)isInUnAckQueue:(DDMessageEntity *)message;
@end


@interface MessageAndTime : NSObject
@property(strong)DDMessageEntity *msg;
@property(assign)NSUInteger nowDate;
@end
