//
//  MD5.h
//  IOSDuoduo
//
//  Created by 东邪 on 14-5-23.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MD5 : NSObject {

}

+(NSString *) getMD5:(NSString *)originalString;

+ (NSString *)getEncryptedURLForWebView:(NSString *)originalURL;
+(NSString*)fileMD5:(NSString*)path;
@end
