//
//  DDChattingEditViewController.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-07-17.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "DDChattingEditViewController.h"
#import "ImageGridViewCell.h"
#import "ChattingEditModule.h"
#import "DDUserModule.h"
#import "ChatEditTableViewCell.h"
#import "ContactsViewController.h"
#import "DDCreateGroupAPI.h"
#import "RuntimeStatus.h"
#import "DDGroupModule.h"
#import "EditGroupViewController.h"
#import "DDAddMemberToGroupAPI.h"
#import "DDGetUserInfoAPI.h"
#import "PublicProfileViewControll.h"
#import "DDDatabaseUtil.h"
#import "DDPersonEditCollectionCell.h"
#import "DDMessageModule.h"
#import "ChattingMainViewController.h"
#import "ShieldGroupMessageAPI.h"
@interface DDChattingEditViewController ()
@property(nonatomic,strong)ChattingEditModule *model;
@property(nonatomic,strong)NSMutableArray *temp;
@property(nonatomic,strong) DDUserEntity *edit;
@property(strong)NSMutableArray *willDeleteItems;
@property(strong)UISwitch *shieldingOn;
@property(strong) UITableView *tableView;
@property(weak)IBOutlet UICollectionView *collectionView;
@property(assign)BOOL isShowEdit;
@property(strong)UIButton *btn;
@property(strong)DDGroupEntity *group;
@end

@implementation DDChattingEditViewController

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
    self.title=@"聊天设置";
    self.willDeleteItems = [NSMutableArray new];
    
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView.layer setBorderWidth:0.5];
    [self.collectionView.layer setBorderColor:RGB(199, 199, 196).CGColor];
    self.collectionView.delegate = self;
	self.collectionView.dataSource = self;

    self.edit = [DDUserEntity new];
    self.edit.avatar=@"edit";
    self.edit.userRole=99999;
    self.items = [NSMutableArray new];
    self.temp = [NSMutableArray arrayWithArray:@[self.edit]];
    self.groupName=@"";
    [self.items addObjectsFromArray:self.temp];
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 304, 321, 188) style:UITableViewStyleGrouped];
    self.tableView.delegate=self;
    self.tableView.scrollEnabled=NO;
    self.tableView.dataSource=self;
//    [self.tableView.layer setBorderWidth:0.5];
//    [self.tableView.layer setBorderColor:RGB(199, 199, 196).CGColor];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
    [self.collectionView registerClass:[DDPersonEditCollectionCell class] forCellWithReuseIdentifier:@"PersonCollectionCell"];
     [self loadGroupUsers];

}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.items count];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    DDPersonEditCollectionCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:@"PersonCollectionCell" forIndexPath:indexPath];
    DDUserEntity *user = [self.items objectAtIndex:indexPath.row];
    [cell setContent:user.nick AvatarImage:user.avatar];
    return cell ;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    DDUserEntity *user = [self.items lastObject];
    if (user.userRole!=99999) {
        [self.items addObject:self.edit];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
     [self.tabBarController.tabBar setHidden:YES];
}

-(void)loadGroupUsers
{
    
    if([self.items count] >2)
    {
        [self.items removeObjectsInRange:NSMakeRange(0, [self.items count]-2)];
    }
   self.group = [[DDGroupModule instance] getGroupByGId:self.session.sessionID];
    self.groupName = self.group.name;
    if ([self.group.groupUserIds count] >0) {
        [self.group.groupUserIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *userID = (NSString *)obj;
            [[DDDatabaseUtil instance] getUserFromID:userID completion:^(DDUserEntity *user) {
                if (user) {
                    [self.items insertObject:user atIndex:0];
                    [self.collectionView reloadData];
                    [self.tableView reloadData];
                }
            }];
        }];
    }
    if (!self.group)
    {
        DDSessionEntity* session = self.session;
        [[DDUserModule shareInstance] getUserForUserID:session.sessionID Block:^(DDUserEntity *user) {
            [self.items insertObject:user atIndex:0];
            [self.collectionView reloadData];
        }];
    }
}
-(void)refreshUsers:(NSMutableArray *)array
{
    
    [self.items removeAllObjects];
    [self.items addObjectsFromArray:array];
    [self.items addObject:self.edit];
    [self.collectionView reloadData];
    [self.tableView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DDUserEntity *user = self.items[indexPath.row];
    if (user.userRole == 99999) {
        //添加联系人
        EditGroupViewController *newEdit = [EditGroupViewController new];
        newEdit.group=self.group;
        newEdit.isGroupCreator=[self.group.groupCreatorId isEqualToString:TheRuntime.user.objID]?YES:NO;
        newEdit.isCreat=self.group.objID?NO:YES;
        newEdit.users=self.items;
        newEdit.editControll=self;
        [self.navigationController pushViewController:newEdit animated:YES];
    }else if (user) {
        PublicProfileViewControll *public = [PublicProfileViewControll new];
        public.user=user;
        [self.navigationController pushViewController:public animated:YES];
        
    }
}


- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) gridView
{
    return CGSizeMake(65, 90);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return 1;
   
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ChatEditCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier ];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (self.groupName)
    {
        if (indexPath.row == 0) {
            [cell.textLabel setText:@"群聊名称"];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(135, 14, 150, 17)];
            [label setTextAlignment:NSTextAlignmentRight];
            [label setTextColor:GRAYCOLOR];
            [label setText:self.groupName];
            [cell.contentView addSubview:label];
        }

    }
    return cell;

}


@end
