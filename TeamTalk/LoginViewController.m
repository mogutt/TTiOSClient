//
//  DDLoginViewController.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "LoginViewController.h"
#import "ChattingMainViewController.h"
#import "RecentUsersViewController.h"
#import "DDClientStateMaintenanceManager.h"
#import "DDUserModule.h"
#import "DDMessageModule.h"
#import "LoginModule.h"
#import "DDNotificationHelp.h"
#import "std.h"
#import "ContactsModule.h"
#import "RuntimeStatus.h"
#import "MainViewControll.h"
#import "DDDatabaseUtil.h"
#import "DDGroupModule.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userNameTextField.leftViewMode=UITextFieldViewModeAlways;
     self.userPassTextField.leftViewMode=UITextFieldViewModeAlways;
    UIImageView *usernameLeftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"username"]];
    usernameLeftView.contentMode = UIViewContentModeCenter;
    usernameLeftView.frame=CGRectMake(0, 0, 19.5+15, 22.5);
    UIImageView *pwdLeftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"password"]];
    pwdLeftView.contentMode = UIViewContentModeCenter;
    pwdLeftView.frame=CGRectMake(0, 0, 19.5+15, 22.5);
    self.userNameTextField.leftView=usernameLeftView;
      self.userPassTextField.leftView=pwdLeftView;
    [self.userNameTextField.layer setBorderColor:RGB(211, 211, 211).CGColor];
    [self.userNameTextField.layer setBorderWidth:0.5];
    [self.userNameTextField.layer setCornerRadius:3];
    [self.userPassTextField.layer setBorderColor:RGB(211, 211, 211).CGColor];
    [self.userPassTextField.layer setBorderWidth:0.5];
    [self.userPassTextField.layer setCornerRadius:3];
    
    UITapGestureRecognizer * tapGestuer =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(hiddenKeyboard:)];
    [self.view addGestureRecognizer:tapGestuer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)hiddenKeyboard:(UITapGestureRecognizer*)gesture
{
    [self.view endEditing:YES];
}

- (IBAction)login:(UIButton*)button
{
    NSString* userName = _userNameTextField.text;
    userName = [userName length] != 0 ? userName : @"东邪";
    NSString* password = _userPassTextField.text;
    password = [password length] != 0 ? password : @"123456";
    [[LoginModule instance] loginWithUsername:userName password:password success:^(DDUserEntity *user) {
        if (user) {
            [RuntimeStatus instance].user=user ;
            [DDNotificationHelp postNotification:DDNotificationUserLoginSuccess userInfo:nil object:user];
            [self presentViewController:[MainViewControll new] animated:YES completion:^{
                
            }];
        }
    } failure:^(NSString *error) {
        
    }];
}
@end
