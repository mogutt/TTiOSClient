//
//  DDAFClient.h
//  IOSDuoduo
//
//  Created by 东邪 on 14-5-29.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
@interface DDAFClient : NSObject
+(void) startRequestFor:(NSURL *) url success:(void(^)(id JSON))success failure:(void(^)(NSError* err)) failure;
+(void) jsonFormPOSTRequest:(NSString *)url param:(NSDictionary *)param success:(void (^)(id))success failure:(void (^)(NSError *))failure;
+(void) jsonFormRequest:(NSString *)url param:(NSDictionary *)param fromBlock:(void (^)(id <AFMultipartFormData> formData))block success:(void (^)(id))success failure:(void (^)(NSError *))failure;
@end
#define BLOCK_SAFE_RUN(block, ...) block ? block(__VA_ARGS__) : nil;
