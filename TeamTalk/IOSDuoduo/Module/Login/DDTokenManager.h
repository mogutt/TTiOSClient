//
//  DDTokenManager.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDTokenManager : NSObject
@property (nonatomic,retain)NSString* token;
@property (nonatomic,retain)NSString* dao;

/**
 *  刷新token
 *
 *  @param success 刷新成功
 *  @param failure 刷新失败
 */
- (void)refreshTokenWithDao:(NSString*)dao
                    Success:(void(^)(NSString* token))success
                    failure:(void(^)(id error))failure;


- (void)startAutoRefreshToken;
- (void)stopAutoRefreshToken;
@end
