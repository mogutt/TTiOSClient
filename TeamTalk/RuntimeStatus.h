//
//  RuntimeStatus.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-07-31.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDUserEntity.h"
#import "std.h"
@interface RuntimeStatus : NSObject
@property(strong)DDUserEntity *user;
@property(assign)int groupCount;
+ (instancetype)instance;
@end
