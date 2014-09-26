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
#import "ContactsModule.h"
#import "UIImageView+WebCache.h"
#import "ChattingMainViewController.h"
#import "RuntimeStatus.h"
#import "DDDatabaseUtil.h"
@interface PublicProfileViewControll ()
@property(weak)IBOutlet UILabel *nickName;
@property(weak)IBOutlet UILabel *realName;
@property(weak)IBOutlet UIImageView *avatar;
@property(weak)IBOutlet UITableView *tableView;
@property(weak)IBOutlet UIButton *conversationBtn;
@property(strong)NSArray *infoArray;
@property(strong)NSMutableDictionary *profileInfos;
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
    if (self.user) {
        self.nickName.text=self.user.nick;
        self.realName.text =self.user.name;
        //[self.avatar setImageWithURL:[NSURL URLWithString:self.user.avatar]];
        //self.infoArray = [[NSArray alloc] initWithObjects:self.user.department, nil];

    }
    [self initData];
    

    // Do any additional setup after loading the view from its nib.
}

-(void)initData
{
    __block NSString *departmentName = @" ";
    if (self.user.departId) {
         [[DDDatabaseUtil instance] getDepartmentFromID:self.user.departId completion:^(DDepartment *department) {
             departmentName=department.title;
             [self.tableView reloadData];
         }];
    }
   
    self.profileInfos = [NSMutableDictionary dictionaryWithCapacity:5];
    [self.profileInfos setObject:[NSArray arrayWithObjects:@"职位", self.user.title?self.user.title:@" ", nil] forKey:@"1"];
    [self.profileInfos setObject:[NSArray arrayWithObjects:@"部门", departmentName?departmentName:@" ", nil] forKey:@"2"];
    [self.profileInfos setObject:[NSArray arrayWithObjects:@"手机号码", self.user.telphone?self.user.telphone:@" ", nil] forKey:@"3"];
    [self.profileInfos setObject:[NSArray arrayWithObjects:@"生日", @"1990/12/19", nil] forKey:@"4"];
    [self.profileInfos setObject:[NSArray arrayWithObjects:@"邮箱地址", self.user.email?self.user.email:@" ", nil] forKey:@"5"];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(favThisContact)];
    self.navigationItem.rightBarButtonItem=item;
    [self.tableView setContentInset:UIEdgeInsetsMake(-64, 0, 0, 0)];
    
    self.conversationBtn.layer.masksToBounds = YES;
    self.conversationBtn.layer.cornerRadius = 4;
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
    int index = indexPath.row+1;
    NSString *key = [NSString stringWithFormat :@"%d",(index)];
    NSArray *elementInfo = [self.profileInfos objectForKey:key];
    UILabel *titleNameTab = [[UILabel alloc]initWithFrame:CGRectMake(13, 12, 87, 19)];
    titleNameTab.text=[elementInfo objectAtIndex:0];
    
    UILabel *titleValueTab = [[UILabel alloc]initWithFrame:CGRectMake(101, 12, 219, 19)];
    titleValueTab.text=[elementInfo objectAtIndex:1];
    
    // 设置cell上文本内容
    [cell addSubview:titleNameTab];
    [cell addSubview:titleValueTab];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = indexPath.row+1;
    NSString *key = [NSString stringWithFormat :@"%d",(index)];
    NSArray *elementInfo = [self.profileInfos objectForKey:key];
    
    switch (indexPath.row) {
        case 2:
            [self callPhoneNum:elementInfo[1]];
            break;
        case 4:
            [self sendEmail:elementInfo[1]];
            break;
            
        default:
            break;
    }
}
-(void)callPhoneNum:(NSString *)phoneNum
{
    NSString *stringURL =[NSString stringWithFormat:@"tel:%@",phoneNum];
    NSURL *url = [NSURL URLWithString:stringURL];
    [[UIApplication sharedApplication] openURL:url];
}
-(void)sendEmail:(NSString *)address
{
    NSString *stringURL =[NSString stringWithFormat:@"mailto:%@",address];
    NSURL *url = [NSURL URLWithString:stringURL];
    [[UIApplication sharedApplication] openURL:url];
}
-(IBAction)startConversation:(id)sender
{
     DDSessionEntity* session = [[DDSessionEntity alloc] initWithSessionID:self.user.userId type:SESSIONTYPE_SINGLE];
    
    [[ChattingMainViewController shareInstance] showChattingContentForSession:session];
    [self.navigationController pushViewController:[ChattingMainViewController shareInstance] animated:YES];
    
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
