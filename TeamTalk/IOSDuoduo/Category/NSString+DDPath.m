//
//  NSString+DDPath.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-6-3.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "NSString+DDPath.h"
#import "DDUserModule.h"
@implementation NSString (DDPath)
+ (NSString*)userExclusiveDirection
{
    NSString* myName = [[DDUserModule shareInstance] currentUserID];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"duoduo"];
    
    NSString* directorPath = [documentsDirectory stringByAppendingPathComponent:myName];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:directorPath])
    {
        [fileManager createDirectoryAtPath:directorPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return directorPath;
}
@end
