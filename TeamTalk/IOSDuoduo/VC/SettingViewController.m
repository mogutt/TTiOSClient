//
//  DDSettingViewController.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-19.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "SettingViewController.h"
#import "ClearImageCacheViewController.h"'
#import "std.h"
#import "RuntimeStatus.h"
#import "PhotosCache.h"
#import "LogoutAPI.h"
#import "LoginViewController.h"
#import "DDTcpClientManager.h"
#import "DDClientState.h"
@interface SettingViewController ()
@end

@implementation SettingViewController

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
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)clearCache:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否清理图片缓存" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag != 100) {
        if (buttonIndex == 1) {
             [[PhotosCache sharedPhotoCache] clearAllCache];
        }
    }else
    {
        if (buttonIndex == 1) {
            LogoutAPI *logout = [LogoutAPI new];
            [logout requestWithObject:nil Completion:^(id response, NSError *error) {
                if (response == 0) {
                    LoginViewController *login = [LoginViewController new];
                    login.isRelogin=YES;
                    [self presentViewController:login animated:YES completion:^{
                        TheRuntime.user =nil;
                        TheRuntime.userID =nil;
                        [DDClientState shareInstance].userState = DDUserOffLineInitiative;
                        [[DDTcpClientManager instance] disconnect];
                    }];
                }
            }];
        }
    }
}

-(IBAction)logout:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否确认退出?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag=100;
    [alert show];

   
}
#pragma mark -
#pragma mark DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"settingIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    NSInteger row = [indexPath row];
    [cell.detailTextLabel setText:nil];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    switch (row)
    {
        case 0:
            [cell.textLabel setText:@"清理图片缓存"];
            [cell.detailTextLabel setText:@""];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            break;
        case 1:
            [cell.textLabel setText:@"退出"];
            [cell.detailTextLabel setText:@""];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            break;
        case 2:
            [cell.textLabel setText:@"版本"];
            [cell.detailTextLabel setText:@"2014102601"];
        default:
            break;
    }
    return cell;
}

#pragma mark -
#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    switch (row)
    {
        case 0:
            [self clearCache:nil];
            break;
        case 1:
            [self logout:nil];
            break;
        default:
            break;
    }
}
@end
