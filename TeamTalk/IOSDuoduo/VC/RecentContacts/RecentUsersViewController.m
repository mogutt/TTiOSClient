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
#import "DDUserModule.h"
#import "DDRecentGroupAPI.h"
#import "DDUnreadMessageGroupAPI.h"
#import "DDGroupsUnreadMessageAPI.h"
#import "DDGroupModule.h"
#import "DDFixedGroupAPI.h"
@interface RecentUsersViewController ()
@property(strong)UISearchDisplayController * searchController;
@property(strong)NSMutableArray *items;

@property(strong)UISearchBar *bar;
- (void)n_receiveStartLoginNotification:(NSNotification*)notification;
- (void)n_receiveLoginSuccessNotification:(NSNotification*)notification;
- (void)n_receiveLoginFailureNotification:(NSNotification*)notification;
- (void)n_receiveMessageNotification:(NSNotification*)notification;
- (void)n_receiveUnreadMessageUpdateNotification:(NSNotification*)notification;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveStartLoginNotification:) name:DDNotificationStartLogin object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveLoginFailureNotification:) name:DDNotificationUserLoginFailure object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveLoginSuccessNotification:) name:DDNotificationUserLoginSuccess object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(n_receiveMessageNotification:)
                                                     name:DDNotificationReceiveMessage
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveRecentContactsUpdateNotification:) name:DDNotificationRecentContactsUpdate object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveUnreadMessageUpdateNotification:) name:DDNotificationUpdateUnReadMessage object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveUserKickOffNotification:) name:DDNotificationUserKickouted object:nil];
        
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
    self.items = [NSMutableArray new];
    [_tableView setFrame:self.view.frame];
//    [self addNavigationBar];
       self.title=@"Team Talk";
   
    [self.tableView setContentInset:UIEdgeInsetsMake(-3, 0, 0, 0)];
    [self loadRecentUserAndGroup];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sentMessageSuccessfull:) name:@"SentMessageSuccessfull" object:nil];
   
  
}
-(void)setToolbarBadge
{
    NSInteger count = [[DDMessageModule shareInstance] getUnreadMessgeCount];
    if (count !=0) {
         [self.parentViewController.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%d",count]];
    }
   
}
-(void)sentMessageSuccessfull:(NSNotification *)notification
{
    NSString *senderID = [notification object];
    __block BOOL isInsert = NO;
    [self.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DDBaseEntity *base = (DDBaseEntity *)obj;
        if ([base isKindOfClass:[DDGroupEntity class]]) {
            DDGroupEntity *group = (DDGroupEntity *)obj;
            if ([senderID isEqualToString:group.groupId]) {
                [self.items removeObject:obj];
                [self.items insertObject:obj atIndex:0];
                isInsert = YES;
                [self.tableView reloadData];
            }
        }else
        {
            DDUserEntity *user = (DDUserEntity *)obj;
            if ([senderID isEqualToString:user.userId]) {
                [self.items removeObject:obj];
                [self.items insertObject:obj atIndex:0];
                isInsert=YES;
                [self.tableView reloadData];
            }
        }
    }];
    if (!isInsert) {
        DDGroupEntity *group = [[DDGroupModule instance] getGroupByGId:senderID];
        if (group) {
             [self.items insertObject:group atIndex:0];
             [self.tableView reloadData];
        }else
        {
            [[DDUserModule shareInstance] getUserForUserID:senderID Block:^(DDUserEntity *user) {
                 [self.items insertObject:user atIndex:0];
                 [self.tableView reloadData];
            }];
        }
    }
  
}

-(void)searchContact
{
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self setToolbarBadge];
    [self.tabBarController.tabBar setHidden:NO];

}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    NSInteger row = [indexPath row];
    if ([self.items[row] isKindOfClass:[DDUserEntity class]]) {
        DDUserEntity* user = self.items[row];
        UIView *view = [[UIView alloc] initWithFrame:cell.bounds];
        view.backgroundColor=RGB(246, 93, 137);
        cell.selectedBackgroundView=view;
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
    NSInteger row = [indexPath row];
    
    RecentUserCell* cell = (RecentUserCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell setUnreadMessageCount:0];
    if ([self.items[row] isKindOfClass:[DDUserEntity class]]) {
        DDUserEntity* userID = self.items[row];
        DDSessionEntity* session = [[DDSessionEntity alloc] initWithSessionID:userID.userId type:SESSIONTYPE_SINGLE];
        [[ChattingMainViewController shareInstance] showChattingContentForSession:session];
        [self.navigationController pushViewController:[ChattingMainViewController shareInstance] animated:YES];
    }else
    {
        DDGroupEntity *group = self.items[row];
        DDSessionEntity* session = [[DDSessionEntity alloc] initWithSessionID:group.groupId type:SESSIONTYPE_TEMP_GROUP];
        [[ChattingMainViewController shareInstance] showChattingContentForSession:session];
        [self.navigationController pushViewController:[ChattingMainViewController shareInstance] animated:YES];
    }
}

#pragma mark - PrivateAPI
- (void)n_receiveStartLoginNotification:(NSNotification*)notification
{
    [self showLinking];
}

- (void)n_receiveLoginSuccessNotification:(NSNotification*)notification
{
    //self.title = @"最近联系人";
}

- (void)n_receiveLoginFailureNotification:(NSNotification*)notification
{
    self.title = @"未连接";

}

- (void)n_receiveMessageNotification:(NSNotification*)notification
{
    
    DDMessageEntity* message = [notification object];
    if (message.msgType == DDGroup_Message_TypeText || message.msgType == DDGroup_MessageTypeVoice) {
        [self.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[DDGroupEntity class]]) {
                DDGroupEntity *group = (DDGroupEntity *)obj;
                if ([message.toUserID isEqualToString:group.groupId]) {
                        [self.items removeObject:obj];
                        [self.items insertObject:obj atIndex:0];
                        [self.tableView reloadData];
                    }
                
            }
        }];
    }else
    {
        __block BOOL isInsert = NO;
        [self.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[DDUserEntity class]]) {
                DDUserEntity *user = (DDUserEntity *)obj;
                if ([message.senderId isEqualToString:user.userId]) {
                    isInsert = YES;
                    [self.items removeObject:obj];
                    [self.items insertObject:obj atIndex:0];
                    [self.tableView reloadData];
                }
            }
        }];
        if (!isInsert) {
            [[DDUserModule shareInstance] getUserForUserID:message.senderId Block:^(DDUserEntity *user) {
                if (user) {
                    [self.items insertObject:user atIndex:0];
                    [self.tableView reloadData];
                }
            }];
        }

    }
     [self setToolbarBadge];
    [self.tableView reloadData];
}

- (void)n_receiveUnreadMessageUpdateNotification:(NSNotification*)notification
{

    NSString *senderID = [notification object];
    NSString *newID = [senderID componentsSeparatedByString:@"_"][1];
    if ([senderID hasPrefix:@"user_"]) {
        
        __block BOOL hadUserInItems =NO;
        [self.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[DDUserModule class]]) {
                DDUserEntity *user = (DDUserEntity *)obj;
                if ([user.userId isEqualToString:newID]) {
                    hadUserInItems=YES;
                    [self.tableView reloadData];
                }
            }
        }];
        if (!hadUserInItems) {
            [[DDUserModule shareInstance] getUserForUserID:newID Block:^(DDUserEntity *user) {
                if (user) {
                    [self.items insertObject:user atIndex:0];
                    [self.tableView reloadData];
                }
            }];
        }
    }else
    {
        __block BOOL hadUserInItems =NO;
        [self.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[DDGroupEntity class]]) {
                DDGroupEntity *group = (DDGroupEntity *)obj;
                if ([group.groupId isEqualToString:newID]) {
                    hadUserInItems=YES;
                    [self.items replaceObjectAtIndex:0 withObject:group];
                    [self.tableView reloadData];
                }
            }
        }];
        if (!hadUserInItems) {
           DDGroupEntity *group= [[DDGroupModule instance]getGroupByGId:newID];
            if (group) {
                [self.items insertObject:group atIndex:0];
                [self.tableView reloadData];
            }
            
        }

    }
   

}

- (void)n_receiveRecentContactsUpdateNotification:(NSNotification*)notification
{
//    [self.module loadRecentContacts:^{
//        [self p_reloadRecentUserTableView:^(bool isFinish) {
//            if (isFinish) {
//                [self sortItems];
//            }
//        }];
//    }];

}

- (void)n_receiveUserKickOffNotification:(NSNotification*)notification
{
    if ([self.navigationController.topViewController isEqual:self])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您的帐号在别处登录" delegate:self cancelButtonTitle:nil otherButtonTitles:@"重连", nil];
        [alert show];
    }
}


- (void)p_reloadRecentUserTableView:(void(^)(bool isFinish))block
{
    [[DDSundriesCenter instance] pushTaskToSerialQueue:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *temp = [NSMutableArray new];
            [[[DDUserModule shareInstance] recentUsers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSUInteger unreadMessageCount = [[DDMessageModule shareInstance] getUnreadMessageCountForSessionID:obj];
                if (unreadMessageCount !=0) {
                    [temp addObject:obj];
                }
            }];
            if ([temp count] !=0) {
                [[[DDUserModule shareInstance] recentUsers] removeObjectsInArray:temp];
                [temp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [[[DDUserModule shareInstance] recentUsers] insertObject:obj atIndex:0];
                }];
            }
            [self.items removeObjectsInArray:[[DDUserModule shareInstance] recentUsers]];
            [self.items addObjectsFromArray:[[DDUserModule shareInstance] recentUsers]];
            [self.items addObjectsFromArray:[[DDGroupModule instance].recentlyGroup allValues]];
            block(YES);
        });
    }];
}


-(void)sortItems
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"_lastUpdateTime" ascending:NO];
    [self.items sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
     [self.tableView reloadData];
   

}
-(void)loadRecentUserAndGroup
{
    [self.items addObjectsFromArray:[[[DDGroupModule instance] recentlyGroup] allValues]];
    [self.items addObjectsFromArray:[[DDUserModule shareInstance] recentUsers]];
    [self sortItems];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        
        [[DDDatabaseUtil instance] loadContactsCompletion:^(NSArray *contacts, NSError *error) {
                [contacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    DDUserEntity* user = (DDUserEntity*)obj;
                    
                    [[DDUserModule shareInstance] addRecentUser:user];
                    [[DDUserModule shareInstance] addMaintanceUser:user];
                }];
            dispatch_group_leave(group);
        }];
        
        //加载网络最近联系人
        dispatch_group_enter(group);
        [[DDSundriesCenter instance] pushTaskToSerialQueue:^{
            RecentConactsAPI* recentContactsAPI = [[RecentConactsAPI alloc] init];
            [recentContactsAPI requestWithObject:recentContactsAPI Completion:^(id response, NSError *error) {
                if (!error)
                {
                        NSMutableArray* recentContacts = (NSMutableArray*)response;
                        [recentContacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            DDUserEntity* user = (DDUserEntity*)obj;
                            [[DDUserModule shareInstance] addRecentUser:user];
                            [[DDUserModule shareInstance] addMaintanceUser:user];
                        }];
                        [[DDUserModule shareInstance] p_saveLocalRecentContacts];
                }
                else
                {
                    DDLog(@"load recentUsers failure error:%@",error.domain);
                }
                   dispatch_group_leave(group);
            }];
        }];
    });
    dispatch_group_enter(group);
    DDRecentGroupAPI *recentGroup = [[DDRecentGroupAPI alloc] init];
    [recentGroup requestWithObject:nil Completion:^(id response, NSError *error) {
        if (response) {
            [[DDGroupModule instance] addRecentlyGroup:response];
            
        }
        dispatch_group_leave(group);
    }];
    //获取固定群
    dispatch_group_enter(group);
    DDFixedGroupAPI *fixedGroup = [[DDFixedGroupAPI alloc] init];
    [fixedGroup requestWithObject:nil Completion:^(id response, NSError *error) {
        if (response) {
            NSArray *groups = (NSArray *)response;
            
            [groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                DDGroupEntity *group =(DDGroupEntity *)obj;
                [[DDGroupModule instance] addGroup:group];
            }];
            
        }
        dispatch_group_leave(group);
    }];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self.items addObjectsFromArray:[[[DDGroupModule instance] recentlyGroup] allValues]];
        [self.items addObjectsFromArray:[[DDUserModule shareInstance] recentUsers]];
        [self sortItems];
    });

}
@end
