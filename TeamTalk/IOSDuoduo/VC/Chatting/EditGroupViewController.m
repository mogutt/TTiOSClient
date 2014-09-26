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
#import "DDContactsCell.h"
#import "DDAddMemberToGroupAPI.h"
#import "DDCreateGroupAPI.h"
#import "std.h"
#import "DDSearch.h"
#import "ChattingMainViewController.h"
#import "UIImageView+WebCache.h"
#import "DDGroupModule.h"
#import "ContactsModule.h"
@interface EditGroupViewController ()
@property(weak)IBOutlet UICollectionView *personView;
@property(weak)IBOutlet UITableView *tableView;
@property(weak)IBOutlet UISearchBar *searchBar;
@property(strong)NSDictionary *items;
@property(strong)UILabel *label;
@property(strong)NSArray *searchResult;
@property(strong)UISearchDisplayController *searchController;
@property(assign)BOOL isCreat;
@property(strong) ContactsModule*model;
@property(strong)NSMutableArray *backupArray;
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
    if ([self.users count] == 2) {
        self.isCreat=YES;
       self.label = [[UILabel alloc] initWithFrame:CGRectMake(90, 50, 200, 30)];
        [self.label setText:@"选择联系人添加进来"];
        [self.label setTextColor:GRAYCOLOR];
        [self.personView addSubview:self.label];
    }
    self.searchResult = [NSArray new];
    [self.users removeLastObject];
    [self.users removeLastObject];
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
    self.backupArray =[NSMutableArray new];
    self.backupArray = [self.users mutableCopy];
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate=self;
    self.searchController.searchResultsDataSource=self;
    self.searchController.searchResultsDelegate=self;
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DDUserEntity *plusImage = [DDUserEntity new];
    plusImage.avatar=@"add";
    DDUserEntity *minus_sign = [DDUserEntity new];
    minus_sign.avatar=@"delete";
    [self.backupArray addObject:plusImage];
    [self.backupArray addObject:minus_sign];
    self.editControll.users= self.backupArray;
}
-(void)saveSelectItems
{
    if (self.isCreat) {
        [self createGroup];
    }else
    {
        BOOL isDelete =([self.backupArray count] > [self.users count])?NO:YES;
        [self editUsersToGroup:self.users isAdd:isDelete];
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
     self.items = [self.model sortByContactFirstLetter];
    [self.tableView reloadData];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return [self.users count];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    EditGroupViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:@"EditGroupViewCell" forIndexPath:indexPath];

    DDUserEntity *user = [self.users objectAtIndex:indexPath.row];
    [cell.name setText:user.nick];
    [cell.name setTextColor:GRAYCOLOR];
    
    [cell.personIcon sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"user_placeholder"]];
    [cell.button setTitle:user.userId forState:UIControlStateNormal];
    [cell.button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [cell.button addTarget:self action:@selector(deletePerson:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
-(IBAction)deletePerson:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    [self.users enumerateObjectsUsingBlock:^(DDUserEntity *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.userId isEqualToString:btn.titleLabel.text]) {
            [self.users removeObject:obj];
            [self.personView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]];
            [self.tableView reloadData];
        }
    }];
  
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

-(NSArray*)allKeys{
    return [[self.items allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"contactsCell";
    DDContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier ];
    if (cell == nil) {
        cell = [[DDContactsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (tableView.tag == 100) {
        NSString *keyStr = [[self allKeys] objectAtIndex:indexPath.section];
        NSArray *userArray =[self.items objectForKey:keyStr];
        DDUserEntity *user = [userArray objectAtIndex:indexPath.row];
        if ([self.users containsObject:user]) {
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
        
        return cell;
    }
    else
    {
        DDUserEntity *user =self.searchResult[indexPath.row];
        if ([self.users containsObject:user]) {
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
        return cell;
        
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    DDUserEntity *user;
    if (tableView.tag == 100) {
        NSString *keyStr = [[self allKeys] objectAtIndex:indexPath.section];
        NSArray *userArray =[self.items objectForKey:keyStr];
        user = [userArray objectAtIndex:indexPath.row];
    }else
    {
        user = self.searchResult[indexPath.row];
    }
     UITableViewCell *oneCell = [tableView cellForRowAtIndexPath: indexPath];
    if (oneCell.accessoryType == UITableViewCellAccessoryNone)
    {
        oneCell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.users addObject:user];
        [self.personView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.users count]-1 inSection:0]]];
        [self.personView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self.users count]-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
        [UIView animateWithDuration:0.5 animations:^{
            self.label.alpha=0.0;
        }];
    }
    else
    {
        oneCell.accessoryType = UITableViewCellAccessoryNone;
        NSUInteger index =[self.users indexOfObject:user];
        [self.users removeObject:user];
        [self.personView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
        if (index>1) {
             [self.personView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        }
        
        if ([self.users count] == 0) {
            [UIView animateWithDuration:0.5 animations:^{
                self.label.alpha=1.0;
            }];
        }
        
     
    }
    
}
-(void)editUsersToGroup:(NSArray *)users isAdd:(BOOL)isadd
{
    int opreate = isadd?0:1;
    DDAddMemberToGroupAPI *addMember = [[DDAddMemberToGroupAPI alloc] init];
    __block NSMutableArray *userIDs = [NSMutableArray new];
    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DDUserEntity *user = (DDUserEntity *)obj;
        if (user.userId) {
            [userIDs addObject:user.userId];
        }
    }];
    [addMember requestWithObject:@[self.sessionID,userIDs,@(opreate)] Completion:^(DDGroupEntity * response, NSError *error) {
        self.editControll.session.sessionID=response.groupId;
        self.editControll.session.sessionType=SESSIONTYPE_TEMP_GROUP;
        [[DDGroupModule instance] addGroup:response];
        [self.navigationController popToViewController:self.editControll animated:YES];
 
    }];
}
-(void)createGroup
{
    DDCreateGroupAPI *creatGroup = [[DDCreateGroupAPI alloc] init];
    __block NSMutableArray *userIDs = [NSMutableArray new];
    [self.users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DDUserEntity *user = (DDUserEntity *)obj;
        if (user.userId) {
            [userIDs addObject:user.userId];
        }
    }];
    NSArray *array =@[[self creatGroupName],@"",userIDs];
    [creatGroup requestWithObject:array Completion:^(DDGroupEntity * response, NSError *error) {
        [[DDGroupModule instance] addGroup:response];
        self.editControll.session.sessionID=response.groupId;
        self.editControll.session.sessionType=SESSIONTYPE_TEMP_GROUP;
        DDSessionEntity *session = [[DDSessionEntity alloc] initWithSessionID:response.groupId type:SESSIONTYPE_TEMP_GROUP];
        [ChattingMainViewController shareInstance].module.sessionEntity =session;
        [ChattingMainViewController shareInstance].title=response.name;
        [self.navigationController popToViewController:self.editControll animated:YES];

    }];
}
-(NSString *)creatGroupName
{
    DDUserEntity *user1 = [self.users objectAtIndex:0];
    DDUserEntity *user2 = [self.users objectAtIndex:1];
    DDUserEntity *user3 = [self.users objectAtIndex:2];
    NSString *string = [NSString stringWithFormat:@"%@,%@,%@",user1.nick,user2.nick,user3.nick];
    return string;
}
@end
