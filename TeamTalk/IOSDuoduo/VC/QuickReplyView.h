//
//  QuickReplyView.h
//  TeamTalk
//
//  Created by Michael Scofield on 2014-08-29.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DDMessageEntity;
@interface QuickReplyView : UIView
-(void)showQuickReply;
-(void)setDescriptionInfo:(DDMessageEntity *)message;
@end
