//
//  DDRecentUsersViewController.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "RecentUsersViewController.h"
#import "RecentUserCell.h"
#import "RecentUserVCModule.h"
#import "DDUserModule.h"
#import "DDMessageModule.h"
#import "ChattingMainViewController.h"
#import "DDSessionEntity.h"
#import "std.h"
#import "RecentConactsAPI.h"
#import "DDDatabaseUtil.h"
#import "LoginModule.h"
#import "DDClientState.h"
#import "RuntimeStatus.h"
#import "DDUserModule.h"
#import "DDRecentGroupAPI.h"
#import "DDUnreadMessageGroupAPI.h"
#import "DDGroupsUnreadMessageAPI.h"
#import "DDGroupModule.h"
#import "DDFixedGroupAPI.h"
#import "SearchContentViewController.h"
#import "MBProgressHUD.h"
@interface RecentUsersViewController ()
@property(strong)UISearchDisplayController * searchController;
@property(strong)NSMutableArray *items;
@property(strong)MBProgressHUD *hud;
@property(strong)NSMutableDictionary *lastMsgs;
@property(strong)UISearchBar *bar;
- (void)n_receiveStartLoginNotification:(NSNotification*)notification;
- (void)n_receiveLoginSuccessNotification:(NSNotification*)notification;
- (void)n_receiveLoginFailureNotification:(NSNotification*)notification;
- (void)n_receiveRecentContactsUpdateNotification:(NSNotification*)notification;
- (void)n_receiveUserKickOffNotification:(NSNotification*)notification;
@end

@implementation RecentUsersViewController

+ (instancetype)shareInstance
{
    static RecentUsersViewController* g_recentUsersViewController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_recentUsersViewController = [RecentUsersViewController new];
    });
    return g_recentUsersViewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveLoginFailureNotification:) name:DDNotificationUserLoginFailure object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    if (isIOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
    }
    [super viewDidLoad];
//    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:self.hud];
//    self.hud.dimBackground = YES;
//    self.hud.labelText=@"正在加载...";
//    [self.hud show:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveUnreadMessageUpdateNotification:) name:DDNotificationUpdateUnReadMessage object:nil];
    self.items = [NSMutableArray new];
    [_tableView setFrame:self.view.frame];
      UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    searchBar.placeholder=@"搜索";
    [searchBar.layer setBorderWidth:0];
    [searchBar setBarTintColor:RGB(242, 242, 244)];
    searchBar.delegate=self;
    _tableView.tableHeaderView=searchBar;
    self.title=@"Team Talk";
   self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(searchBar.bounds));
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
[self.tableView setBackgroundColor:RGB(239,239,244)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"RefreshRecentData" object:nil];
    self.lastMsgs = [NSMutableDictionary new];
    self.module = [RecentUserVCModule new];
    self.items=self.module.items;
   
    
}

-(void)refreshData
{
    //[self.hud removeFromSuperview];
    [self.tableView reloadData];
    [self setToolbarBadge];
}

-(void)setToolbarBadge
{
    NSInteger count = [[DDMessageModule shareInstance] getUnreadMessgeCount];

    if (count !=0) {
        if (count > 99)
        {
            [self.parentViewController.tabBarItem setBadgeValue:@"99+"];

        }
        else
        {
            [self.parentViewController.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%ld",count]];

        }

    }else
    {
        [self.parentViewController.tabBarItem setBadgeValue:nil];
    }
}


-(void)searchContact
{
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setToolbarBadge];

}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self.tableView reloadData];
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (RecentUserVCModule*)module
{
    if (!_module)
    {
        _module = [[RecentUserVCModule alloc] init];
    }
    return _module;
}

#pragma mark public
- (void)showLinking
{
    self.title = @"正在连接...";
//    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
//    
//    UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    [activity setFrame:CGRectMake(30, 0, 44, 44)];
//    
//    UILabel* linkLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
//    [linkLabel setTextAlignment:NSTextAlignmentCenter];
//    [linkLabel setText:@"正在连接"];
//    
//    [activity startAnimating];
//    [titleView addSubview:activity];
//    [titleView addSubview:linkLabel];
//    
//    [self.navigationItem setTitleView:titleView];
}

#pragma mark -
#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    switch (buttonIndex)
//    {
//        case 1:
//        {
//            NSString* userID = [DDLoginModule instance].userID;
//            NSString* token = [DDLoginModule instance].token;
//            NSString* did = [DDLoginModule instance].did;
//            
//            [[DDLoginModule instance] loginIMWithUserID:userID token:token did:did success:^{
//                
//            } failure:^(NSString *error) {
//                
//            }];
//        }
//            break;
//    }
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"DDRecentUserCellIdentifier";
    RecentUserCell* cell = (RecentUserCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        UINib* nib = [UINib nibWithNibName:@"RecentUserCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
        cell = (RecentUserCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    UIView *view = [[UIView alloc] initWithFrame:cell.bounds];
    view.backgroundColor=RGB(229, 229, 229);
    cell.selectedBackgroundView=view;
    NSInteger row = [indexPath row];
    if ([self.items[row] isKindOfClass:[DDUserEntity class]]) {
        DDUserEntity* user = self.items[row];
        [cell setShowUser:user];
      
    }else
    {
        DDGroupEntity *group = self.items[row];
        [cell setShowGroup:group];
        [cell setName:group.name];
    }
       return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = [indexPath row];
    
    RecentUserCell* cell = (RecentUserCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell setUnreadMessageCount:0];
    if ([self.items[row] isKindOfClass:[DDUserEntity class]]) {
        DDUserEntity* userID = self.items[row];
        DDSessionEntity* session = [[DDSessionEntity alloc] initWithSessionID:userID.objID type:SESSIONTYPE_SINGLE];
        [[ChattingMainViewController shareInstance] showChattingContentForSession:session];
        [self.navigationController pushViewController:[ChattingMainViewController shareInstance] animated:YES];
    }else
    {
        DDGroupEntity *group = self.items[row];
        DDSessionEntity* session = [[DDSessionEntity alloc] initWithSessionID:group.objID type:SESSIONTYPE_TEMP_GROUP];
        [[ChattingMainViewController shareInstance] showChattingContentForSession:session];
        [self.navigationController pushViewController:[ChattingMainViewController shareInstance] animated:YES];
    }
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    DDBaseEntity *entity = self.items[row];
    if ([entity isKindOfClass:[DDUserEntity class]]) {
        DDUserEntity *temp =(DDUserEntity *)entity;
        if ([TheRuntime isInFixedTop:temp.objID]) {
            [TheRuntime removeFromFixedTop:temp.objID];
        }else
        {
            [TheRuntime insertToFixedTop:temp.objID];
        }
       
    }else
    {
        DDGroupEntity *group = (DDGroupEntity *)entity;
        if ([TheRuntime isInFixedTop:group.objID]) {
            [TheRuntime removeFromFixedTop:group.objID];
        }else
        {
         [TheRuntime insertToFixedTop:group.objID];
        }
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger row = [indexPath row];
    DDBaseEntity *entity = self.items[row];
    if ([entity isKindOfClass:[DDUserEntity class]]) {
        DDUserEntity *temp =(DDUserEntity *)entity;
        if ([TheRuntime isInFixedTop:temp.objID]) {
            return @"取消置顶";
        }
    }else
    {
        DDGroupEntity *group = (DDGroupEntity *)entity;
        if ([TheRuntime isInFixedTop:group.objID]) {
            return @"取消置顶";
        }
    }
    return @"置顶";
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.navigationController pushViewController:[SearchContentViewController new] animated:YES];
    return NO;
}
- (void)n_receiveUnreadMessageUpdateNotification:(NSNotification*)notification
{
    [self.tableView reloadData];
}
- (void)n_receiveLoginFailureNotification:(NSNotification*)notification
{
    self.title = @"未连接";
}
- (void)n_receiveStartLoginNotification:(NSNotification*)notification
{
     self.title = @"Team Talk";
}
@end
