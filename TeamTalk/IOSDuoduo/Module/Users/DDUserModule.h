//
//  DDUserModule.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDUserEntity.h"

typedef void(^DDLoadRecentUsersCompletion)();


@interface DDUserModule : NSObject

@property (nonatomic,strong)NSString* currentUserID;
@property (nonatomic,strong)NSMutableDictionary* recentUsers;
+ (instancetype)shareInstance;

//- (void)replaceUsers:(NSArray*)users;
- (void)addMaintanceUser:(DDUserEntity*)user;
- (void )getUserForUserID:(NSString*)userID Block:(void(^)(DDUserEntity *user))block;
- (void)addRecentUser:(DDUserEntity*)user;
- (void)sortRecentUsers;
- (void)p_saveLocalRecentContacts;
- (void)loadAllRecentUsers:(DDLoadRecentUsersCompletion)completion;
-(void)clearRecentUser;
-(NSArray *)getAllMaintanceUser;
@end
