//
//  PublieProfileViewControll.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-07-16.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "PublicProfileViewControll.h"
#import "DDUserEntity.h"
#import "DDSessionEntity.h"
#import "UIImageView+WebCache.h"
#import "ContactsModule.h"
#import "UIImageView+WebCache.h"
#import "ChattingMainViewController.h"
#import "RuntimeStatus.h"
#import "DDUserDetailInfoAPI.h"
#import "DDDatabaseUtil.h"
#import "DDAppDelegate.h"
#import "DDUserModule.h"
@interface PublicProfileViewControll ()
@property(weak)IBOutlet UILabel *nickName;
@property(weak)IBOutlet UILabel *realName;
@property(weak)IBOutlet UIImageView *avatar;
@property(weak)IBOutlet UITableView *tableView;
@property(weak)IBOutlet UIButton *conversationBtn;
-(IBAction)startConversation:(id)sender;
@end

@implementation PublicProfileViewControll

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
    self.nickName.text = self.user.nick;
    self.realName.text = self.user.name;
    if([self.user.objID isEqualToString:TheRuntime.user.objID])
    {
        [self.conversationBtn setHidden:YES];
    }else
    {
        [self.conversationBtn setHidden:NO];
    }
    __block NSString *departmentName = @" ";

    DDUserDetailInfoAPI* detailInfoAPI = [[DDUserDetailInfoAPI alloc] init];
    [detailInfoAPI requestWithObject:@[self.user.objID] Completion:^(id response, NSError *error) {
        if ([response count] > 0)
        {
            NSDictionary* userInfo = response[0];
            DDUserEntity *newUser = [DDUserEntity dicToUserEntity:userInfo];
            if (newUser) {
                self.user=newUser;
                self.nickName.text=newUser.nick;
                self.realName.text=newUser.name;
                [self.tableView reloadData];
            }
        }
        else
        {
        }
    }];
       [self initData];
    

    // Do any additional setup after loading the view from its nib.
}

-(void)initData
{
    UIImage* placeholder = [UIImage imageNamed:@"user_placeholder"];
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:self.user.avatar] placeholderImage:placeholder];
    [self.avatar setClipsToBounds:YES];
    [self.avatar.layer setCornerRadius:2.0];
    [self.avatar setUserInteractionEnabled:YES];
    if (![self.user.objID isEqualToString:TheRuntime.user.objID]) {
        UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"收藏" style:UIBarButtonItemStyleBordered target:self action:@selector(favThisContact)];
        self.navigationItem.rightBarButtonItem=barButtonItem;

    }
    [self.tableView setContentInset:UIEdgeInsetsMake(-64, 0, 0, 0)];
    self.conversationBtn.layer.masksToBounds = YES;
    self.conversationBtn.layer.cornerRadius = 4;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden:NO];
}
-(void)favThisContact
{
    [ContactsModule favContact:self.user];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"moreInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier ];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
//    if (indexPath.row == 0) {
//        cell.textLabel.text=self.user.department;
//    }
    switch (indexPath.row) {
        case 0:
            {
                NSString *string = [NSString stringWithFormat:@"部门            %@",self.user.department];
                [cell.textLabel setText:string];
                cell.userInteractionEnabled = NO;
                
            }
            break;
        case 1:
        {
            NSString *string = [NSString stringWithFormat:@"手机号码     %@",self.user.telphone];
            [cell.textLabel setText:string];
        }
            break;
        case 2:
        {
            NSString *string = [NSString stringWithFormat:@"邮箱地址     %@",self.user.email];
            [cell.textLabel setText:string];
            cell.userInteractionEnabled = NO;
        }
            break;
        default:
            break;
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 1:
            [self callPhoneNum:self.user.telphone];
            break;
        case 2:
            [self sendEmail:self.user.email];
            break;
            
        default:
            break;
    }
}
-(void)callPhoneNum:(NSString *)phoneNum
{
    if (!phoneNum) {
        return;
    }
    NSString *stringURL =[NSString stringWithFormat:@"tel:%@",phoneNum];
    NSURL *url = [NSURL URLWithString:stringURL];
    [[UIApplication sharedApplication] openURL:url];
}
-(void)sendEmail:(NSString *)address
{
    if (!address.length) {
        return;
    }
    NSString *stringURL =[NSString stringWithFormat:@"mailto:%@",address];
    NSURL *url = [NSURL URLWithString:stringURL];
    [[UIApplication sharedApplication] openURL:url];
}
-(IBAction)startConversation:(id)sender
{
     DDSessionEntity* session = [[DDSessionEntity alloc] initWithSessionID:self.user.objID type:SESSIONTYPE_SINGLE];
    [session setSessionName:self.user.nick];
    [[ChattingMainViewController shareInstance] showChattingContentForSession:session];
    NSLog(@"%@...",TheAppDel.nv);
    if ([[self.navigationController viewControllers] containsObject:[ChattingMainViewController shareInstance]]) {
         [self.navigationController popToViewController:[ChattingMainViewController shareInstance] animated:YES];
    }else
    {
        [self.navigationController pushViewController:[ChattingMainViewController shareInstance] animated:YES];

    }
   
    
}

/*设置标题头的宽度*/
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
/*设置标题尾的宽度*/
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
