//
//  MyProfileViewControll.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-07-15.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "MyProfileViewControll.h"
#import "PublicProfileViewControll.h"
#import "RuntimeStatus.h"
#import "SettingViewController.h"
@interface MyProfileViewControll ()

@end

@implementation MyProfileViewControll

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
    self.title=@"关于我";
    self.profileView.userInteractionEnabled=true;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goPersonalProfile)];
    [self.profileView addGestureRecognizer:singleTap];
    
    self.realName.text=[RuntimeStatus instance].user.name;
    self.nickName.text=[RuntimeStatus instance].user.nick;
    [self.view1.layer setBorderColor:RGB(199, 199, 196).CGColor];
    [self.view1.layer setBorderWidth:0.5];
    [self.view2.layer setBorderColor:RGB(199, 199, 196).CGColor];
    [self.view2.layer setBorderWidth:0.5];
    
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:NO];
  
}

-(IBAction)goToSettingPage:(id)sender
{
    [self.navigationController pushViewController:[SettingViewController new] animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)goPersonalProfile
{
    PublicProfileViewControll *public = [PublicProfileViewControll new] ;
    public.user = [RuntimeStatus instance].user;
    [self.navigationController pushViewController:public animated:YES];
}

@end
