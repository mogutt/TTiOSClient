//
//  DDSettingViewController.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-19.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "SettingViewController.h"
#import "ClearImageCacheViewController.h"'
#import "PhotosCache.h"
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"moreInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier ];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    switch (indexPath.row) {
        case 0:
            [cell.textLabel setText:@"清理图片缓存"];
            break;
        case 1:
            [cell.textLabel setText:@"退出"];
            break;
        default:
            break;
    }
  
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否清理图片缓存" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
        }
            break;
            
        default:
            break;
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
            [[PhotosCache sharedPhotoCache] clearAllCache];
            break;
            
        default:
            break;
    }
}

@end
