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
#import "UIImageView+WebCache.h"
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
@interface DDChattingEditViewController ()
@property(nonatomic,strong)ChattingEditModule *model;
@property(nonatomic,strong)NSMutableArray *temp;
@property(nonatomic,strong) DDUserEntity *plusImage;
@property(strong)NSMutableArray *willDeleteItems;
@property(nonatomic,strong)DDUserEntity *minus_sign;
@property(strong) UITableView *tableView;
@property(weak)IBOutlet UICollectionView *collectionView;
@property(assign)BOOL isShowEdit;
@property(strong)UIButton *btn;
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

    //[self.view addSubview:self.gridView];
    self.plusImage = [DDUserEntity new];
    self.plusImage.avatar=@"add";
    self.minus_sign = [DDUserEntity new];
    self.minus_sign.avatar=@"delete";
    self.users = [NSMutableArray new];
    self.temp = [NSMutableArray arrayWithArray:@[self.plusImage,self.minus_sign]];
    self.groupName=@"";
    [self.users addObjectsFromArray:self.temp];
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(-1, 304, 321, 132)];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.tableView.layer setBorderWidth:0.5];
    [self.tableView.layer setBorderColor:RGB(199, 199, 196).CGColor];
    [self.view addSubview:self.tableView];
    UIView *view = [[UIView alloc] initWithFrame:self.collectionView.frame];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenDeleteButton)];
    [view addGestureRecognizer:tap];
    self.collectionView.backgroundView=view;
    [self.collectionView registerClass:[DDPersonEditCollectionCell class] forCellWithReuseIdentifier:@"PersonCollectionCell"];
    

}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.users count];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    DDPersonEditCollectionCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:@"PersonCollectionCell" forIndexPath:indexPath];
    DDUserEntity *user = [self.users objectAtIndex:indexPath.row];
    [cell.name setText:user.nick];
    [cell.name setTextColor:GRAYCOLOR];
    if ([user.avatar isEqualToString:@"add"]) {
        cell.tag=100;
        cell.personIcon.image = [UIImage imageNamed:user.avatar];
        
    }else if([user.avatar isEqualToString:@"delete"])
    {
        cell.tag=101;
         cell.personIcon.image= [UIImage imageNamed:user.avatar];
    }else
    {
        [cell.personIcon sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"user_placeholder"]];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btn setImage:[UIImage imageNamed:@"dd_preview_select"] forState:UIControlStateNormal];
        btn.tag=indexPath.row;
        [btn addTarget:self action:@selector(deleteContact:) forControlEvents:UIControlEventTouchUpInside];
        [btn setFrame:CGRectMake(45, 0, 30, 30)];
        [btn setHidden:NO];
        if (self.isShowEdit)
            
            [btn setHidden:NO];
        else
            [btn setHidden:YES];
        
        [cell.contentView addSubview:btn];
        return cell ;
    }
    return cell ;
}
-(void)hiddenDeleteButton
{
    if (self.isShowEdit) {
        self.isShowEdit=NO;
        [self.collectionView reloadData];
        if ([self.willDeleteItems count]>0) {
            [self editUsersToGroup:self.willDeleteItems isAdd:1];
        }
       
    }

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    [self loadGroupUsers];
}


-(void)loadGroupUsers
{
    
    if([self.users count] >2)
        {
            [self.users removeObjectsInRange:NSMakeRange(0, [self.users count]-2)];
        }
        DDGroupEntity *group = [[DDGroupModule instance] getGroupByGId:self.session.sessionID];
        self.groupName = group.name;
        if ([group.groupUserIds count] >0) {
            [group.groupUserIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *userID = (NSString *)obj;
                [[DDDatabaseUtil instance] getUserFromID:userID completion:^(DDUserEntity *user) {
                    if (user) {
                        [self.users insertObject:user atIndex:0];
                        [self.collectionView reloadData];
                        [self.tableView reloadData];
                    }
                }];
            }];
    }

}

-(IBAction)deleteContact:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    DDUserEntity *user = [self.users objectAtIndex:btn.tag];
    [self.users removeObject:user];
    [self.willDeleteItems addObject:user];
    [self.collectionView reloadData];
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DDUserEntity *user = self.users[indexPath.row];
    if ([user.avatar isEqualToString:@"add"]) {
        //添加联系人
        
        EditGroupViewController *newEdit = [EditGroupViewController new];
        newEdit.users=self.users;
        newEdit.editControll=self;
//        ContactsViewController *selectContact=  [ContactsViewController new];
//        selectContact.block=^(NSArray *array)
//        {
//            if ([array count] !=0) {
//                BOOL isCreat = NO;
//                if ([self.users count] == 2) {
//                    isCreat=YES;
//                }
//                
//                [self.users removeObjectsInArray:array];
//                [self.users addObjectsFromArray:array];
//                [self.users removeObject:self.plusImage];
//                [self.users addObject:self.plusImage];
//                [self.users removeObject:self.minus_sign];
//                [self.users addObject:self.minus_sign];
//                if (isCreat) {
//                    [self createGroup];
//                }else
//                {
//                    [self editUsersToGroup:array isAdd:YES];
//                }
//                
//            }
//        };
        
        [self.navigationController pushViewController:newEdit animated:YES];
    }else if ([user.avatar isEqualToString:@"delete"])
    {
        //删除联系人
        self.isShowEdit =YES;
        
        [self.collectionView reloadData];
        
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
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ChatEditCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier ];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == 0) {
        [cell.textLabel setText:@"群聊名称"];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(135, 14, 150, 17)];
        [label setTextAlignment:NSTextAlignmentRight];
        [label setTextColor:GRAYCOLOR];
        [label setText:self.groupName];
        [cell.contentView addSubview:label];
    }else if(indexPath.row == 1)
    {
         [cell.textLabel setText:@"群二维码"];
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(220, 7, 30, 30)];
        [image setImage:[UIImage imageNamed:@"plus"]];
        [cell.contentView addSubview:image];
    }else if(indexPath.row == 2)
    {
         [cell.textLabel setText:@"通知"];
        UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220, 7, 40, 30)];
        [mySwitch setOn:NO];
        [mySwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:mySwitch];
    }
    return cell;

}
-(void)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
}
-(NSString *)creatGroupName
{
    DDUserEntity *user1 = [self.users objectAtIndex:0];
    DDUserEntity *user2 = [self.users objectAtIndex:1];
    DDUserEntity *user3 = [self.users objectAtIndex:2];
    NSString *string = [NSString stringWithFormat:@"%@,%@,%@",user1.nick,user2.nick,user3.nick];
    return string;
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
        self.session.sessionID=response.groupId;
        self.session.sessionType=SESSIONTYPE_TEMP_GROUP;
        DDSessionEntity *session = [[DDSessionEntity alloc] initWithSessionID:response.groupId type:SESSIONTYPE_TEMP_GROUP];
        [ChattingMainViewController shareInstance].module.sessionEntity =session;
        [self loadGroupUsers];
    }];
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
    [addMember requestWithObject:@[[self.session getSessionGroupID],userIDs,@(opreate)] Completion:^(id response, NSError *error) {
        DDGroupEntity *group = (DDGroupEntity *)response;
        self.session.sessionID=group.groupId;
        self.session.sessionType=SESSIONTYPE_TEMP_GROUP;
        [[DDGroupModule instance] addGroup:group];
        [self loadGroupUsers];
    }];
}
@end
