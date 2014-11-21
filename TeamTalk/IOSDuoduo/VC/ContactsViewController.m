//
//  ContactsViewController.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-07-15.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "ContactsViewController.h"
#import "std.h"
#import "PublicProfileViewControll.h"
#import "ContactsModule.h"
#import "DDGroupEntity.h"
#import "DDSearch.h"
#import "ContactAvatarTools.h"
#import "DDContactsCell.h"
#import "DDUserDetailInfoAPI.h"
#import "DDGroupModule.h"
#import "ChattingMainViewController.h"
#import "SearchContentViewController.h"
#import "MBProgressHUD.h"
#import "DDFixedGroupAPI.h"
@interface ContactsViewController ()
@property(strong)UISegmentedControl *seg;
@property(strong)NSMutableDictionary *items;
@property(strong)NSMutableDictionary *keys;
@property(strong)ContactsModule *model;
@property(strong)NSMutableArray *groups;
@property(strong)NSArray *searchResult;
@property(strong)UITableView *tableView;
@property(strong)UISearchBar *searchBar;
@property(strong)ContactAvatarTools *tools;
@property(strong)UISearchDisplayController *searchController;
@property(strong)MBProgressHUD *hud;
@property(assign)int selectIndex;
@end

@implementation ContactsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.dimBackground = YES;
    self.hud.labelText=@"正在加载...";
    [self.hud show:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAllContacts) name:@"refreshAllContacts" object:nil];
    self.groups = [NSMutableArray new];
    self.title=@"联系人";
    self.model = [ContactsModule new];
    self.searchResult = [NSArray new];
    self.seg = [[UISegmentedControl alloc] initWithItems:@[@"全部",@"部门"]];
    self.seg.selectedSegmentIndex=0;
    self.seg.frame=CGRectMake(80.0f, 8.0f, 200.0f, 30.0f);
    [self.seg addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView=self.seg;
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [self.searchBar setPlaceholder:@"搜索"];
    [self.searchBar setBarTintColor:RGB(242, 242, 244)];
    self.searchBar.delegate=self;
    [self.searchBar setBarStyle:UIBarStyleDefault];
    [self.view addSubview:self.searchBar];
   
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320,(self.tabBarController.tabBar.isHidden?self.view.frame.size.height:self.view.frame.size.height-152))];
    self.tableView.delegate=self;
    self.tableView.tag=100;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    DDFixedGroupAPI *fixedGroupApi = [DDFixedGroupAPI new];
    [fixedGroupApi requestWithObject:nil Completion:^(NSArray *response, NSError *error) {
        [self.groups addObjectsFromArray:response];
        [self.tableView reloadData];
    }];
//    NSArray *array = [[DDGroupModule instance] getAllGroups];
//    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        DDGroupEntity *group = (DDGroupEntity *)obj;
//        if (group.groupType == GROUP_TYPE_FIXED) {
//            [self.groups addObject:group];
//        }
//    }];
    
}
-(void)scrollToTitle:(NSNotification *)notification
{
    NSString *string = [notification object];
    self.sectionTitle=string;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.sectionTitle=nil;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isSearchResult) {
        [self.tabBarController.tabBar setHidden:YES];
    }else
    {
        [self.tabBarController.tabBar setHidden:NO];
    }
    if (self.sectionTitle) {
        [self.seg setSelectedSegmentIndex:1];
        self.selectIndex=1;
        [self swichToShowDepartment];
        if ([self.allKeys count]) {
            int location = [self.allKeys indexOfObject:self.sectionTitle];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:location] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        return;
    }

   
}
-(void)refreshAllContacts
{
    if (self.sectionTitle) {
        [self.seg setSelectedSegmentIndex:1];
        self.selectIndex=1;
        [self swichToShowDepartment];
        int location = [self.allKeys indexOfObject:self.sectionTitle];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:location] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        return;
    }

    switch (self.selectIndex) {
        case 0:
            [self swichContactsToALl];
            break;
        case 1:
            [self swichToShowDepartment];
        default:
            break;
    }
    

}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
-(void)swichContactsToALl
{
    //[self.items removeAllObjects];
    self.items = [self.model sortByContactFirstLetter];

    [self.tableView reloadData];
}
-(void)swichToShowDepartment
{
    // [self.items removeAllObjects];
    self.items = [self.model sortByDepartment];
    [self.tableView reloadData];
}
-(NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    if (self.selectIndex == 1) {
        [[self allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            char firstLetter = getFirstChar((NSString *)obj);
            [array addObject:[[NSString stringWithFormat:@"%c",firstLetter] uppercaseString]];
        }];
    }
    else
    {
        NSArray* allKeys = [self allKeys];
        [allKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [array addObject:[obj uppercaseString]];
        }];
    }
    return array;
}
-(IBAction)segmentAction:(UISegmentedControl *)sender
{
    int index = sender.selectedSegmentIndex;
    switch (index) {
        case 0:
            self.selectIndex=0;
            [self swichContactsToALl];
            break;
        case 1:
            self.selectIndex=1;
            [self swichToShowDepartment];
        default:
            break;
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(NSArray*)allKeys{
    return [[self.items allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
        if (self.selectIndex == 0) {
            return [[self.items allKeys] count]+2;
        }
        return [[self.items allKeys] count];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        if (self.selectIndex == 0) {
            if (section == 0) {
                return [self.groups count];
            }else if (section == 1)
            {
                NSLog(@"%d........",[[ContactsModule getFavContact] count]);
                return [[ContactsModule getFavContact] count];
            }
            else
            {
                NSString *keyStr = [self allKeys][(NSUInteger) (section - 2)];
                NSArray *arr = (self.items)[keyStr];
                return [arr count];
            }
        }
        
        NSString *keyStr = [self allKeys][(NSUInteger) (section)];
        NSArray *arr = (self.items)[keyStr];
        return [arr count];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
        if (self.selectIndex == 0) {
            if (section == 0) {
                return @"群";
            }else if (section == 1)
            {
                return @"收藏";
            }
            return [self.allKeys[section - 2] uppercaseString];
        }else
        {
              return [self.allKeys[section] uppercaseString];
        }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"contactsCell";
    DDContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier ];
    if (cell == nil) {
        cell = [[DDContactsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
        if (self.selectIndex == 0) {
            if (indexPath.section == 0) {
                DDGroupEntity *group = [self.groups objectAtIndex:indexPath.row];
                cell.nameLabel.text=group.name;
                UIImage* placeholder = [UIImage imageNamed:@"user_placeholder"];
                [cell setGroupAvatar:group];
            }else if (indexPath.section == 1)
            {
                NSArray *arr = [ContactsModule getFavContact];
                DDUserEntity *user = [arr objectAtIndex:indexPath.row];

                NSString *name =user.nick?user.nick:user.name;
                [cell setCellContent:user.avatar Name:name];
               
            }else
            {
                NSString *keyStr = [[self allKeys] objectAtIndex:indexPath.section-2];
                NSArray *userArray =[self.items objectForKey:keyStr];
                DDUserEntity *user = [userArray objectAtIndex:indexPath.row];
         
                [cell setCellContent:user.avatar Name:user.nick];
                cell.button.tag=indexPath.row;
                [cell.button setTitle:keyStr forState:UIControlStateNormal];
                [cell.button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                [cell.button addTarget:self action:@selector(showActions:) forControlEvents:UIControlEventTouchUpInside];
            }
        }else
        {
            NSString *keyStr = [[self allKeys] objectAtIndex:indexPath.section];
            NSArray *userArray =[self.items objectForKey:keyStr];
            DDUserEntity *user = [userArray objectAtIndex:indexPath.row];
            [cell setCellContent:user.avatar Name:user.nick];
            cell.button.tag=indexPath.row;
            [cell.button setTitle:keyStr forState:UIControlStateNormal];
            [cell.button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
            [cell.button addTarget:self action:@selector(showActions:) forControlEvents:UIControlEventTouchUpInside];
        }
    
    return cell;
}

-(IBAction)showActions:(id)sender
{
    if (self.tools.isShow) {
        [self.tools hiddenSelf];
    }
    UIButton *btn = (UIButton *)sender;
    NSArray *userArray =[self.items objectForKey:btn.titleLabel.text];
    DDBaseEntity *user = [userArray objectAtIndex:btn.tag];
    CGRect rect = [self.tableView convertRect:self.tableView.frame fromView:btn];
    self.tools = [[ContactAvatarTools alloc] initWithFrame:CGRectMake(rect.origin.x+btn.frame.size.width+5, rect.origin.y-70, 100, 100)];
    __weak ContactsViewController *weakSelf = self;
    if ([user isKindOfClass:[DDUserEntity class]]) {
        __block DDUserEntity *newUser;
        DDUserDetailInfoAPI* detailInfoAPI = [[DDUserDetailInfoAPI alloc] init];
        [detailInfoAPI requestWithObject:@[((DDUserEntity *)user).objID] Completion:^(id response, NSError *error) {
            if ([response count] > 0)
            {
                NSDictionary* userInfo = response[0];
                newUser = [DDUserEntity dicToUserEntity:userInfo];
            }
            else
            {
            }
        }];
        self.tools.block=^(int index){
            switch (index) {
                case 1:
                    [weakSelf callNum:newUser];
                    break;
                case 2:
                    [weakSelf sendEmail:newUser];
                    break;
                case 3:
                    [weakSelf chatTo:newUser];
                default:
                    break;
            }
        };
    }
    [self.tableView addSubview:self.tools];
}

-(void)callNum:(DDUserEntity *)user
{
    if (user == nil) {
        return;
    }
    NSString *string = [NSString stringWithFormat:@"tel:%@",user.telphone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
}
-(void)sendEmail:(DDUserEntity *)user
{
    if (user == nil) {
    return;
    }
    NSString *string = [NSString stringWithFormat:@"mailto:%@",user.email];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
}
-(void)chatTo:(DDUserEntity *)user
{
    if (user == nil) {
        return;
    }
    DDSessionEntity* session = [[DDSessionEntity alloc] initWithSessionID:user.objID type:SESSIONTYPE_SINGLE];
    [session setSessionName:user.nick];
    [[ChattingMainViewController shareInstance] showChattingContentForSession:session];
    [self.navigationController pushViewController:[ChattingMainViewController shareInstance] animated:YES];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.tools.isShow) {
        [self.tools hiddenSelf];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.tools.isShow) {
        [self.tools hiddenSelf];
        return;
    }
        if (self.selectIndex == 0) {
            if (indexPath.section == 0) {
                DDGroupEntity *group = [self.groups objectAtIndex:indexPath.row];
                DDSessionEntity *session = [[DDSessionEntity alloc] initWithSessionID:group.objID type:SESSIONTYPE_GROUP];
                [session setSessionName:group.name];
                ChattingMainViewController *main = [ChattingMainViewController shareInstance];
                [main showChattingContentForSession:session];
                [self.navigationController pushViewController:main animated:YES];
                return;
            }
            if (indexPath.section == 1) {
                DDUserEntity *user;
                user = [ContactsModule getFavContact][indexPath.row];
                PublicProfileViewControll *public = [PublicProfileViewControll new];
                public.user=user;
                [self.navigationController pushViewController:public animated:YES];
                return;
            }
            NSString *keyStr = [[self allKeys] objectAtIndex:indexPath.section-2];
            NSArray *userArray =[self.items objectForKey:keyStr];
            DDUserEntity *user;
            user = [userArray objectAtIndex:indexPath.row];
            PublicProfileViewControll *public = [PublicProfileViewControll new];
            public.user=user;
            [self.navigationController pushViewController:public animated:YES];
    }else
    {
        NSString *keyStr = [[self allKeys] objectAtIndex:indexPath.section];
        NSArray *userArray =[self.items objectForKey:keyStr];
        DDUserEntity *user;
        user = [userArray objectAtIndex:indexPath.row];
        PublicProfileViewControll *public = [PublicProfileViewControll new];
        public.user=user;
        [self.navigationController pushViewController:public animated:YES];

    }
   
}
-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.navigationController pushViewController:[SearchContentViewController new] animated:YES];
    return NO;
}
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self == [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToTitle:) name:@"SearchDerpartment" object:nil];
    }
    return self;
}

@end