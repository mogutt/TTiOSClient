//
//  DDRecentUserVCModule.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDUserModule.h"

@interface RecentUserVCModule : NSObject
- (void)loadRecentContacts:(DDLoadRecentUsersCompletion)completion;
@end
