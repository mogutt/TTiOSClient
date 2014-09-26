//
//  DDLoginServer.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-12.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LoginEntity;
@interface DDLoginServer : NSObject

- (void)connectLoginServerSuccess:(void(^)(NSDictionary* loginEntity))success failure:(void(^)())failure;

@end
