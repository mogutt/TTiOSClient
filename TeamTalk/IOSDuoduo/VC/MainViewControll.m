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
@interface MainViewControll ()

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
    UINavigationController *nv1= [[UINavigationController alloc] initWithRootViewController:[RecentUsersViewController new]];
    
    nv1.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"聊天" image:[UIImage imageNamed:@"conversation"] selectedImage:[UIImage imageNamed:@"conversation_selected"]];
    nv1.tabBarItem.tag=0;
    UINavigationController *nv2= [[UINavigationController alloc] initWithRootViewController:[ContactsViewController new]];
    nv2.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"通讯录" image:[UIImage imageNamed:@"contact"] selectedImage:[UIImage imageNamed:@"contact_selected"]];
    nv2.tabBarItem.tag=1;
    UINavigationController *nv3= [[UINavigationController alloc] initWithRootViewController:[MyProfileViewControll new]];
    nv3.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"通讯录" image:[UIImage imageNamed:@"myprofile"] selectedImage:[UIImage imageNamed:@"myprofile_selected"]];
    nv3.tabBarItem.tag=2;
    self.viewControllers=@[nv1,nv2,nv3];
    self.selectedIndex=0;
    self.delegate=self;
    self.title=@"Team Talk";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
}
@end
