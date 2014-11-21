//
//  NetwrokStatusNotifyUI.h
//  TeamTalk
//
//  Created by Michael Scofield on 2014-10-13.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetwrokStatusNotifyUI : UIView
+ (void)showWithStatus:(NSString*)status;
+ (void)showErrorWithStatus:(NSString*)status;
+ (void)showSuccessWithStatus:(NSString*)status;
+ (void)dismiss;
@end
