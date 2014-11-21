//
//  NSString+Additions.h
//  IOSDuoduo
//
//  Created by 东邪 on 14-5-23.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TTString)

+(NSString *)documentPath;
+(NSString *)cachePath;
+(NSString *)formatCurrentDate;
+(NSString *)formatCurrentDay;
- (NSString*)removeAllSpace;
- (NSURL *) toURL;
- (BOOL) isEmpty;
- (NSString *) MD5;
-(NSString *)trim;
@end
