//
//  MainViewControll.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-07-15.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "MainViewControll.h"
#import "RecentUsersViewController.h"
#import "ContactsViewController.h"
#import "MyProfileViewControll.h"
#import "DDClientStateMaintenanceManager.h"
#import "DDGroupModule.h"
#import "LoginViewController.h"
#import "std.h"
@interface MainViewControll ()
@property(strong) UINavigationController *nv2;
@end

@implementation MainViewControll

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

    self.nv1= [[UINavigationController alloc] initWithRootViewController:[RecentUsersViewController shareInstance]];
    

    UIImage* conversationSelected = [[UIImage imageNamed:@"conversation_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
   
    self.nv1.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"聊天" image:[UIImage imageNamed:@"conversation"] selectedImage:conversationSelected];
    self.nv1.tabBarItem.tag=0;//26 140 242
    [self.nv1.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:RGB(26, 140, 242) forKey:UITextAttributeTextColor] forState:UIControlStateSelected];
    
    UIImage* contactSelected = [[UIImage imageNamed:@"contact_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    UINavigationController *nv2= [[UINavigationController alloc] initWithRootViewController:[ContactsViewController new]];
    nv2.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"通讯录" image:[UIImage imageNamed:@"contact"] selectedImage:contactSelected];
    nv2.tabBarItem.tag=1;
    [nv2.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:RGB(26, 140, 242) forKey:UITextAttributeTextColor] forState:UIControlStateSelected];

    
    UIImage* myProfileSelected = [[UIImage imageNamed:@"myprofile_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UINavigationController *nv4= [[UINavigationController alloc] initWithRootViewController:[MyProfileViewControll new]];
    nv4.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"我" image:[UIImage imageNamed:@"myprofile"] selectedImage:myProfileSelected];
    nv4.tabBarItem.tag=3;

    [nv4.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:RGB(26, 140, 242) forKey:UITextAttributeTextColor] forState:UIControlStateSelected];

    
    self.viewControllers=@[self.nv1,nv2,nv4];
    self.delegate=self;
    self.title=@"Team Talk";

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if ([self.nv1.tabBarItem isEqual:item])
    {
        if ([[[RecentUsersViewController shareInstance].tableView visibleCells] count] > 0)
        {
            [[RecentUsersViewController shareInstance].tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

@end
