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
#import "UIImageView+WebCache.h"
#import "DDGroupEntity.h"
#import "DDSearch.h"
#import "ContactAvatarTools.h"
#import "DDContactsCell.h"
#import "DDGroupModule.h"
#import "ChattingMainViewController.h"
@interface ContactsViewController ()
@property(strong)UISegmentedControl *seg;
@property(strong)NSMutableDictionary *items;
@property(strong)NSMutableDictionary *keys;
@property(strong)ContactsModule *model;
@property(strong)NSMutableArray *groups;
@property(strong)NSArray *searchResult;
@property(strong)UITableView *tableView;
@property(strong)UISearchBar *searchBar;
@property(strong)NSMutableArray *selectedItems;
@property(strong)ContactAvatarTools *tools;
@property(strong)UISearchDisplayController *searchController;
@property(assign)int selectIndex;
@end

@implementation ContactsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAllContacts) name:@"refreshAllContacts" object:nil];
    self.groups = [NSMutableArray new];
    self.title=@"联系人";
    self.model = [ContactsModule new];
    self.selectedItems = [NSMutableArray new];
    self.searchResult = [NSArray new];
    self.seg = [[UISegmentedControl alloc] initWithItems:@[@"全部",@"部门"]];
    self.seg.selectedSegmentIndex=0;
    self.seg.frame=CGRectMake(80.0f, 8.0f, 200.0f, 30.0f);
    [self.seg addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView=self.seg;
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [self.searchBar setPlaceholder:@"输入名字搜索"];
    self.searchBar.delegate=self;
    [self.searchBar setBarStyle:UIBarStyleDefault];
    [self.view addSubview:self.searchBar];
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate=self;
    self.searchController.searchResultsDataSource=self;
    self.searchController.searchResultsDelegate=self;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, self.view.frame.size.height-155)];
    self.tableView.delegate=self;
    self.tableView.tag=100;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    
    if (self.block) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveSelectItems)];
        super.navigationItem.rightBarButtonItem=item;
    }
    
    NSArray *array = [[DDGroupModule instance] getAllGroups];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DDGroupEntity *group = (DDGroupEntity *)obj;
        if (group.groupType == GROUP_TYPE_FIXED) {
            [self.groups addObject:group];
        }
    }];
 
}
-(void)refreshAllContacts
{
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


-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if ([searchString isEqualToString:@""]) {
        return NO;
    }
    [[DDSearch instance] searchContent:searchString completion:^(NSArray *result, NSError *error) {
        self.searchResult=result;
        [self.self.searchDisplayController.searchResultsTableView reloadData];
    }];
  
    return YES;
}


-(void)saveSelectItems
{
    self.block(self.selectedItems);
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    [self.searchController setActive:YES animated:YES];
    return YES;
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
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
    if (self.selectIndex == 1) {
        NSMutableArray *arr = [NSMutableArray new];
        [[self allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            char firstLetter = getFirstChar((NSString *)obj);
            [arr addObject:[NSString stringWithFormat:@"%c",firstLetter]];
        }];
        return arr;
    }
    return [self allKeys];
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
    
    // Return the number of sections.
    if (tableView.tag == 100) {
        return [[self.items allKeys] count]+2;
    }
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    if (tableView.tag ==100) {
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
    
    return [self.searchResult count];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 100) {
        if (section == 0) {
            return @"群";
        }else if (section == 1)
        {
            return @"收藏";
        }
        return self.allKeys[section - 2];
    }
    return @"搜索结果";
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"contactsCell";
    DDContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier ];
    if (cell == nil) {
        cell = [[DDContactsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (tableView.tag == 100) {
        if (indexPath.section == 0) {
            DDGroupEntity *group = [self.groups objectAtIndex:indexPath.row];
            cell.textLabel.text=group.name;
        }else if (indexPath.section == 1)
        {
            NSArray *arr = [ContactsModule getFavContact];
            DDUserEntity *user = [arr objectAtIndex:indexPath.row];
            
            if ([self.selectedItems containsObject:user]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            cell.textLabel.text=user.nick?user.nick:user.name;
        }else
        {
            NSString *keyStr = [[self allKeys] objectAtIndex:indexPath.section-2];
            NSArray *userArray =[self.items objectForKey:keyStr];
            DDUserEntity *user = [userArray objectAtIndex:indexPath.row];
            if ([self.selectedItems containsObject:user]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            cell.textLabel.text=user.nick;
            NSURL* avatarURL = [NSURL URLWithString:user.avatar];
            [cell.imageView setClipsToBounds:YES];
            [cell.imageView.layer setCornerRadius:2.0];
            [cell.imageView setUserInteractionEnabled:YES];
            UIImage* placeholder = [UIImage imageNamed:@"user_placeholder"];
            [cell.imageView setImageWithURL:avatarURL placeholderImage:placeholder];
            cell.button.tag=indexPath.row;
            [cell.button setTitle:keyStr forState:UIControlStateNormal];
            [cell.button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
            [cell.button addTarget:self action:@selector(showActions:) forControlEvents:UIControlEventTouchUpInside];
        }

    }else
    {
        DDUserEntity *user =self.searchResult[indexPath.row];
        cell.textLabel.text=user.nick;
        
    }
    
    // Configure the cell...
    
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
        self.tools.block=^(int index){
            switch (index) {
                case 1:
                    [weakSelf callNum:(DDUserEntity *)user];
                    break;
                case 2:
                    [weakSelf sendEmail:(DDUserEntity *)user];
                    break;
                case 3:
                    [weakSelf chatTo:(DDUserEntity *)user];
                default:
                    break;
            }
        };
    }
    [self.tableView addSubview:self.tools];
}

-(void)callNum:(DDUserEntity *)user
{
    NSString *string = [NSString stringWithFormat:@"tel:%@",user.telphone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
}
-(void)sendEmail:(DDUserEntity *)user
{
    NSString *string = [NSString stringWithFormat:@"mailto:%@",user.email];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
}
-(void)chatTo:(DDUserEntity *)user
{
    DDSessionEntity* session = [[DDSessionEntity alloc] initWithSessionID:user.userId type:SESSIONTYPE_SINGLE];
    
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
    if (tableView.tag == 100) {
    if (indexPath.section == 0) {
        DDGroupEntity *group = [self.groups objectAtIndex:indexPath.row];
        DDSessionEntity *session = [[DDSessionEntity alloc] initWithSessionID:group.groupId type:SESSIONTYPE_GROUP];
        ChattingMainViewController *main = [ChattingMainViewController shareInstance];
        [main showChattingContentForSession:session];
        [self.navigationController pushViewController:main animated:YES];
        return;
    }
    if (self.block) {
        
        UITableViewCell *oneCell = [tableView cellForRowAtIndexPath: indexPath];
        DDUserEntity *user =nil;
        if (indexPath.section == 1) {
            user = [[ContactsModule getFavContact] objectAtIndex:indexPath.row];
        }else
        {
            NSString *keyStr = [[self allKeys] objectAtIndex:indexPath.section-2];
            NSArray *userArray =[self.items objectForKey:keyStr];
            user = [userArray objectAtIndex:indexPath.row];
        }
        if (oneCell.accessoryType == UITableViewCellAccessoryNone)
        {
            oneCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            [self.selectedItems addObject:user];
        }
        else
        {
            oneCell.accessoryType = UITableViewCellAccessoryNone;
            [self.selectedItems removeObject:user];
        }
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
        
        DDUserEntity *user;
        user = self.searchResult[indexPath.row];
        PublicProfileViewControll *public = [PublicProfileViewControll new];
        public.user=user;
        [self.navigationController pushViewController:public animated:YES];
    }
}
-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
