//
//  DDAnalysicImage.h
//  IOSDuoduo
//
//  Created by 东邪 on 14-6-6.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDMessageEntity.h"
@interface AnalysisImage : NSObject
+(void)analysisImage:(DDMessageEntity *)message Block:(void(^)(NSMutableArray *array))block;
@end
