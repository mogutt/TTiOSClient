//
//  DDLoginViewController.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (nonatomic,weak)IBOutlet UITextField* userNameTextField;
@property (nonatomic,weak)IBOutlet UITextField* userPassTextField;

- (IBAction)login:(UIButton*)button;
-(IBAction)hiddenKeyboard:(id)sender;
@end
