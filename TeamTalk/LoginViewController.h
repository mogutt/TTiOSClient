//
//  DDLoginViewController.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+JSMessagesView.h"
@interface LoginViewController : UIViewController<UITextFieldDelegate>
@property (assign)BOOL isAutoLogin;
@property (nonatomic,weak)IBOutlet UITextField* userNameTextField;
@property (weak)IBOutlet UIImageView *landspace;
@property (nonatomic,weak)IBOutlet UITextField* userPassTextField;
@property(assign)BOOL isRelogin;
- (IBAction)login:(UIButton*)button;
-(IBAction)hiddenKeyboard:(id)sender;
@end
