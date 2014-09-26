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

@interface RecentUserVCModule (PrivateAPI)

- (void)p_saveLocalRecentContacts;

@end

@implementation RecentUserVCModule
- (void)loadRecentContacts:(DDLoadRecentUsersCompletion)completion
{
    [[DDUserModule shareInstance] loadAllRecentUsers:completion];
}

@end
