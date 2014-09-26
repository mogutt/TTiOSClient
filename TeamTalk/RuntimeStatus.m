//
//  RuntimeStatus.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-07-31.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "RuntimeStatus.h"
#import "DDUserEntity.h"
#import "DDGroupModule.h"
#import "DDMessageModule.h"
#import "DDClientStateMaintenanceManager.h"
@interface RuntimeStatus()
@end
@implementation RuntimeStatus

+ (instancetype)instance
{
    static RuntimeStatus* g_runtimeState;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_runtimeState = [[RuntimeStatus alloc] init];
        
    });
    return g_runtimeState;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.user = [DDUserEntity new];
        [DDMessageModule shareInstance];
        [DDClientStateMaintenanceManager shareInstance];
    }
    return self;
}
@end
