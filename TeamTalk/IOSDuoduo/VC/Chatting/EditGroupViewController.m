//
//  EditGroupViewController.m
//  TeamTalk
//
//  Created by Michael Scofield on 2014-09-01.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "EditGroupViewController.h"
#import "EditGroupViewCell.h"
#import "DDUserEntity.h"
#import "EditContactsCell.h"
#import "DDAddMemberToGroupAPI.h"
#import "DDCreateGroupAPI.h"
#import "std.h"
#import "RuntimeStatus.h"
#import "DDSearch.h"
#import "ChattingMainViewController.h"
#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "DDGroupModule.h"
#import "ContactsModule.h"
#import "DDDeleteMemberFromGroupAPI.h"
@interface EditGroupViewController ()
@property(weak)IBOutlet UICollectionView *personView;
@property(weak)IBOutlet UITableView *tableView;
@property(weak)IBOutlet UISearchBar *searchBar;
@property(strong)NSDictionary *items;
@property(strong)UILabel *label;
@property(strong)NSMutableArray *backupArray;
@property(strong)NSMutableArray *editArray;
@property(strong)NSMutableArray *selectedArray;
@property(strong)NSArray *searchResult;
@property(strong)UISearchDisplayController *searchController;
@property(strong) ContactsModule*model;
@property(strong)MBProgressHUD *hud;
@end

@implementation EditGroupViewController

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
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    
    self.title=@"编辑群联系人";
    if ([self.users count] == 1) {
       self.label = [[UILabel alloc] initWithFrame:CGRectMake(90, 50, 200, 30)];
        [self.label setText:@"选择联系人添加进来"];
        [self.label setTextColor:GRAYCOLOR];
        [self.personView addSubview:self.label];
    }
    self.searchResult = [NSArray new];
    self.selectedArray = [NSMutableArray new];
    [self.users removeLastObject];
    self.editArray = [NSMutableArray arrayWithArray:self.users];
    self.sessionID=self.editControll.session.sessionID;
    [self.personView setBackgroundColor:[UIColor whiteColor]];
    [self.personView.layer setBorderWidth:0.5];
    [self.personView.layer setBorderColor:RGB(199, 199, 196).CGColor];
    self.personView.delegate = self;
	self.personView.dataSource = self;
    self.items = [NSMutableDictionary new];
    [self.personView registerClass:[EditGroupViewCell class] forCellWithReuseIdentifier:@"EditGroupViewCell"];
    self.model = [ContactsModule new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAllContacts) name:@"refreshAllContacts" object:nil];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveSelectItems)];
    super.navigationItem.rightBarButtonItem=item;
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate=self;
    self.searchController.searchResultsDataSource=self;
    self.searchController.searchResultsDelegate=self;
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.dimBackground = YES;
    self.hud.labelText=@"正在删除...";
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
-(void)saveSelectItems
{
    if (self.isCreat) {
        [self createGroup];
    }else
    {
        __block NSMutableArray *tempArray = [NSMutableArray new];
        [self.editArray enumerateObjectsUsingBlock:^(DDUserEntity *obj, NSUInteger idx, BOOL *stop) {
            if (![self.backupArray containsObject:obj]) {
                [tempArray addObject:obj];
            }
        }];
        if ([tempArray count] != 0) {
           [self addUsersToGroup:tempArray];
        }
        [self.backupArray removeObjectsInArray:self.editArray];
        if ([self.backupArray count] !=0) {
            [self deleteUserFromGroup];
        }
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
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    if ( [[self allKeys] count] == 0) {
        return NO;
    }
    [self.searchBar setShowsCancelButton:YES animated:YES];
    [self.searchController setActive:YES animated:YES];
    return YES;
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.tableView reloadData];
}

-(void)refreshAllContacts
{
    [self.hud removeFromSuperview];
    self.items = [self.model sortByContactFirstLetter];
    [self.model.contacts  enumerateObjectsUsingBlock:^(DDUserEntity *obj1, NSUInteger idx, BOOL *stop) {
        [self.editArray enumerateObjectsUsingBlock:^(DDUserEntity *obj2, NSUInteger idx2, BOOL *stop) {
            if ([obj1.objID isEqualToString:obj2.objID]) {
                [self.editArray replaceObjectAtIndex:idx2 withObject:obj1];
            }
        }];
    }];
    self.backupArray =[NSMutableArray arrayWithArray:self.editArray];
    [self.tableView reloadData];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return [self.editArray count];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    EditGroupViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:@"EditGroupViewCell" forIndexPath:indexPath];

    DDUserEntity *user = [self.editArray objectAtIndex:indexPath.row];
    [cell.name setText:user.nick];
    [cell.name setTextColor:GRAYCOLOR];
    
    [cell.personIcon sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"user_placeholder"]];
    [cell.button setTitle:user.objID forState:UIControlStateNormal];
    cell.button.tag=indexPath.row;
    [cell.button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [cell.button addTarget:self action:@selector(deletePerson:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
-(IBAction)deletePerson:(id)sender
{
    
    UIButton *btn = (UIButton *)sender;
    __block BOOL isInSelectArray = NO;
    [self.selectedArray enumerateObjectsUsingBlock:^(DDUserEntity *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.objID isEqualToString:btn.titleLabel.text]) {
            [self.selectedArray removeObjectAtIndex:idx];
            isInSelectArray=YES;
            [self.editArray enumerateObjectsUsingBlock:^(DDUserEntity *obj, NSUInteger idx, BOOL *stop) {
                if ([obj.objID isEqualToString:btn.titleLabel.text]) {
                    [self.editArray removeObjectAtIndex:btn.tag];
                    [self.personView reloadData];
                    [self.tableView reloadData];
                }}];
        }
    }];
    if (isInSelectArray) {
        return;
    }
    [self.hud show:YES];
    [self.editArray enumerateObjectsUsingBlock:^(DDUserEntity *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.objID isEqualToString:btn.titleLabel.text]) {
            
            if (!self.group) {
                [self.personView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]];
                [self.editArray removeObjectAtIndex:idx];
                [self.tableView reloadData];
            }else
            {
                if (self.isGroupCreator) {
                    DDDeleteMemberFromGroupAPI* deleteMemberAPI = [[DDDeleteMemberFromGroupAPI alloc] init];
                    NSArray* array = @[self.sessionID,@[obj.objID]];
                    [deleteMemberAPI requestWithObject:array Completion:^(id response, NSError *error) {
                        if (response)
                        {
                            [self.hud hide:YES];
                            [self.personView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]];
                            [self.editArray removeObjectAtIndex:idx];
                            [self.tableView reloadData];
                        }
                    }];
                }else
                {
                    [self showAlert:@"你不是该群的创建者，无法删除成员"];
                }
                
            }
           
        }
    }];
    [self.hud hide:YES];
  
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    EditGroupViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
 
    [cell showDeleteActionView];
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == 100) {
        return [[self.items allKeys] count];
    }
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    if (tableView.tag == 100) {
        NSString *keyStr = [self allKeys][(NSUInteger) (section)];
        NSArray *arr = (self.items)[keyStr];
        return [arr count];
    }
    
  return [self.searchResult count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  
        return [self allKeys][section];

}
-(NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView{
        NSMutableArray *arr = [NSMutableArray new];
        [[self allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            char firstLetter = getFirstChar((NSString *)obj);
            [arr addObject:[NSString stringWithFormat:@"%c",firstLetter]];
        }];
        return arr;
}

-(NSArray*)allKeys{
    return [[self.items allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
}
-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"contactsCell";
    EditContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier ];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if (cell == nil) {
        cell = [[EditContactsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (tableView.tag == 100) {
        NSString *keyStr = [[self allKeys] objectAtIndex:indexPath.section];
        NSArray *userArray =[self.items objectForKey:keyStr];
        DDUserEntity *user = [userArray objectAtIndex:indexPath.row];
        if ([self.editArray containsObject:user]) {
            [cell setCellToSelected:YES];
        }else
        {
            [cell setCellToSelected:NO];
        }
        cell.nameLabel.text=user.nick;
        UIImage* placeholder = [UIImage imageNamed:@"user_placeholder"];
        [cell.avatar sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:placeholder];
        
        return cell;
    }
    else
    {
        DDUserEntity *user =self.searchResult[indexPath.row];
        if ([self.editArray containsObject:user]) {
           [cell setCellToSelected:YES];
        }else
        {
           [cell setCellToSelected:NO];
        }
        cell.nameLabel.text=user.nick;
        UIImage* placeholder = [UIImage imageNamed:@"user_placeholder"];
        [cell.avatar sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:placeholder];
        return cell;
        
    }
    
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditContactsCell *oneCell =(EditContactsCell *) [tableView cellForRowAtIndexPath: indexPath];
    NSString *keyStr = [[self allKeys] objectAtIndex:indexPath.section];
    NSArray *userArray =[self.items objectForKey:keyStr];
    DDUserEntity *user = [userArray objectAtIndex:indexPath.row];
    if ([self.selectedArray containsObject:user]) {
        [oneCell setCellToSelected:YES];
    }else
    {
        [oneCell setCellToSelected:NO];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    DDUserEntity *user;
    if (tableView.tag == 100) {
        NSString *keyStr = [[self allKeys] objectAtIndex:indexPath.section];
        NSArray *userArray =[self.items objectForKey:keyStr];
        user = [userArray objectAtIndex:indexPath.row];
    }else
    {
        user = self.searchResult[indexPath.row];
        [self.searchController setActive:NO animated:NO];
    }
     EditContactsCell *oneCell =(EditContactsCell *) [tableView cellForRowAtIndexPath: indexPath];
    if (![self.editArray containsObject:user])
    {
       [oneCell setCellToSelected:YES];
        [self.editArray addObject:user];
        [self.selectedArray addObject:user];
        [self.personView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.editArray count]-1 inSection:0]]];
        [self.personView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self.editArray count]-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
        [UIView animateWithDuration:0.5 animations:^{
            self.label.alpha=0.0;
        }];
    }
    else
    {
       [oneCell setCellToSelected:NO];
        NSUInteger index =[self.editArray indexOfObject:user];
        [self.editArray removeObjectAtIndex:index];
        [self.selectedArray removeObject:user];
        [self.personView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
        
        if ([self.editArray count] == 0) {
            [UIView animateWithDuration:0.5 animations:^{
                self.label.alpha=1.0;
            }];
        }
        
     
    }
    
}
-(void)deleteUserFromGroup
{
    __block NSMutableArray *userIDs = [NSMutableArray new];
    [self.backupArray enumerateObjectsUsingBlock:^(DDUserEntity *obj, NSUInteger idx, BOOL *stop) {
        [userIDs addObject:obj.objID];
    }];
    DDDeleteMemberFromGroupAPI* deleteMemberAPI = [[DDDeleteMemberFromGroupAPI alloc] init];
    NSArray* array = @[self.sessionID,userIDs];
    [deleteMemberAPI requestWithObject:array Completion:^(DDGroupEntity *response, NSError *error) {
        if (error) {
            [self showAlert:error.domain?error.domain:@"未知错误"];
        }
        if (response)
        {
            [self.hud hide:YES];
            [self.tableView reloadData];
            [self.navigationController popToViewController:self.editControll animated:YES];
            [self.editControll refreshUsers:self.editArray];
        }else
        {
            [[DDGroupModule instance] getGroupInfogroupID:self.sessionID completion:^(DDGroupEntity *group) {
                [[DDGroupModule instance] addGroup:group];
                [self.hud hide:YES];
                [self.tableView reloadData];
                [self.navigationController popToViewController:self.editControll animated:YES];
                [self.editControll refreshUsers:self.editArray];
            }];

        }
    }];
}

-(void)addUsersToGroup:(NSMutableArray *)users
{
    DDAddMemberToGroupAPI *addMember = [[DDAddMemberToGroupAPI alloc] init];
    __block NSMutableArray *userIDs = [NSMutableArray new];

    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DDUserEntity *user = (DDUserEntity *)obj;
        if (user.objID) {
            [userIDs addObject:user.objID];
        }
    }];
    [addMember requestWithObject:@[self.sessionID,userIDs] Completion:^(DDGroupEntity * response, NSError *error) {
        if (response != nil) {
            
            [self.navigationController popToViewController:self.editControll animated:YES];
            [self.editControll refreshUsers:self.editArray];
        }else
        {
            [self showAlert:error.domain?error.domain:@"未知错误"];
        }
    }];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UITextField *tf=[alertView textFieldAtIndex:0];
        if(tf.text.length !=0)
        {
            
        }
        DDCreateGroupAPI *creatGroup = [[DDCreateGroupAPI alloc] init];
        __block NSMutableArray *userIDs = [NSMutableArray new];
        [userIDs addObject:TheRuntime.user.objID];
        [self.editArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            DDUserEntity *user = (DDUserEntity *)obj;
            if (user.objID) {
                [userIDs addObject:user.objID];
            }
        }];
        NSString *groupName = tf.text.length !=0?tf.text:[self creatGroupName];
        NSArray *array =@[groupName,@"",userIDs];
        [creatGroup requestWithObject:array Completion:^(DDGroupEntity * response, NSError *error) {
            if (response !=nil) {
                [[DDGroupModule instance] addGroup:response];
                [[DDGroupModule instance] addRecentlyGroup:@[response]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshRecentData" object:nil];
                [self.editControll refreshUsers:self.editArray];
                self.editControll.session.sessionID=response.objID;
                self.editControll.session.sessionType=SESSIONTYPE_TEMP_GROUP;
                DDSessionEntity *session = [[DDSessionEntity alloc] initWithSessionID:response.objID type:SESSIONTYPE_TEMP_GROUP];
                [ChattingMainViewController shareInstance].module.sessionEntity =session;
                [ChattingMainViewController shareInstance].title=response.name;
                [self.navigationController popToViewController:[ChattingMainViewController shareInstance] animated:YES];
            }else
            {
                [self showAlert:error.domain?error.domain:@"未知错误"];
            }
            
            
        }];
    }
}
-(void)createGroup
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"创建群" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle=UIAlertViewStylePlainTextInput;
    [alert show];
   
}

-(void)showAlert:(NSString *)string
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:string delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

-(NSString *)creatGroupName
{
    NSMutableString *string= [NSMutableString new];
    [self.selectedArray enumerateObjectsUsingBlock:^(DDUserEntity *obj, NSUInteger idx, BOOL *stop) {
        [string appendFormat:@"%@,",obj.name];
        if (idx == 3) {
            *stop=YES;
        }
    }];

    return string;
}
@end
