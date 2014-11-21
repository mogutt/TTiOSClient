//
//  DDAnalysicImage.m
//  IOSDuoduo
//
//  Created by 东邪 on 14-6-6.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "AnalysisImage.h"
#import "DDMessageModule.h"
@implementation AnalysisImage
+(void)analysisImage:(DDMessageEntity *)message Block:(void(^)(NSMutableArray *array))block
{
 
    NSMutableArray *arr = [NSMutableArray new];
    if (message.msgContent.length>0) {
        NSMutableString *string = [NSMutableString stringWithString:message.msgContent];
        [string replaceOccurrencesOfString:DD_MESSAGE_IMAGE_SUFFIX withString:DD_MESSAGE_IMAGE_PREFIX options:NSCaseInsensitiveSearch range:NSMakeRange(0, string.length)];
        NSArray *msgArr = [string componentsSeparatedByString:DD_MESSAGE_IMAGE_PREFIX];
        if ([msgArr count]>0) {
            for (NSString *msg in msgArr) {
                if (msg.length>0) {
                    DDMessageEntity *tempMessage = [message copy];
                    if ([msg hasPrefix:@"http:"]) {
                        tempMessage.msgContentType=DDMessageTypeImage;
                    }
                    tempMessage.msgID=[DDMessageModule  getMessageID];
                    tempMessage.msgContent=msg;
                    [arr addObject:tempMessage];
                }
            }
        }else
        {
            if ([string hasPrefix:@"http:"]) {
                message.msgContentType=DDMessageTypeImage;
                message.msgContent=string;
            }
            [arr addObject:message];
        }
    }
    block(@[message]);
}
@end
