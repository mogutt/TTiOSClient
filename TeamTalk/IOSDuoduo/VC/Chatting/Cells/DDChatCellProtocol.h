//
//  DDChatCellProtocol.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-28.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DDMessageEntity;
@protocol DDChatCellProtocol <NSObject>

- (CGSize)sizeForContent:(DDMessageEntity*)content;

- (float)contentUpGapWithBubble;

- (float)contentDownGapWithBubble;

- (float)contentLeftGapWithBubble;

- (float)contentRightGapWithBubble;

- (void)layoutContentView:(DDMessageEntity*)content;

- (float)cellHeightForMessage:(DDMessageEntity*)message;
@end
