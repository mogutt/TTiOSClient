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
#import "DDAppDelegate.h"
#import "ContactsModule.h"
#import "RuntimeStatus.h"
#import "MainViewControll.h"
#import "DDDatabaseUtil.h"
#import "DDGroupModule.h"
#import "MBProgressHUD.h"
@interface LoginViewController ()
@property(assign)CGPoint defaultCenter;
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

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"username"]!=nil) {
        _userNameTextField.text =[[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"password"]!=nil) {
        _userPassTextField.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    }
    if(!self.isRelogin)
    {
      
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"username"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"password"])
            {
                [self login:nil];
            }else{
                 self.landspace.alpha=0.0;
            }
       
    }else
    {
        self.landspace.alpha=0.0;
    }
    
    self.defaultCenter=self.view.center;
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

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillShowKeyboard)
												 name:UIKeyboardWillShowNotification
                                               object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillHideKeyboard)
												 name:UIKeyboardWillHideNotification
                                               object:nil];

    
}
-(void)handleWillShowKeyboard
{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.center=CGPointMake(self.defaultCenter.x, self.defaultCenter.y-(IPHONE4?120:40));
    }];
}
-(void)handleWillHideKeyboard
{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.center=self.defaultCenter;
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)hiddenKeyboard:(id)sender
{
    [_userNameTextField resignFirstResponder];
    [_userPassTextField resignFirstResponder];
}

- (IBAction)login:(UIButton*)button
{
 
    NSString* userName = _userNameTextField.text;
    NSString* password = _userPassTextField.text;
    [[LoginModule instance] loginWithUsername:userName password:password success:^(DDUserEntity *user) {
        if (user) {
            [RuntimeStatus instance].user=user ;
      
            [self presentViewController:[MainViewControll new] animated:YES completion:^{
                
            }];
        }
    } failure:^(NSString *error) {
        
    }];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self login:nil];
    return YES;
}
@end
