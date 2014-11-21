//
//  SearchContentViewController.m
//  TeamTalk
//
//  Created by Michael Scofield on 2014-10-20.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "SearchContentViewController.h"
#import "std.h"
#import "DDSearch.h"
#import "DDContactsCell.h"
#import "DDUserEntity.h"
#import "PublicProfileViewControll.h"
#import "DDSessionEntity.h"
#import "ContactsViewController.h"
#import "DDAppDelegate.h"
#import "MBProgressHUD.h"
#import "ContactsModule.h"
#import "DDDatabaseUtil.h"
#import "SpellLibrary.h"
@interface SearchContentViewController ()
@property(weak) IBOutlet UISearchBar *searchBar;
@property(weak) IBOutlet UITableView *tableView;
@property(strong)NSString *keyString;
@property(strong) ContactsViewController *contact;
@property(strong)NSMutableArray *searchResult;
@property(strong)NSMutableArray *department;
@end

@implementation SearchContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"搜索";
    [self.searchBar becomeFirstResponder];
    [self.searchBar setBarTintColor:RGB(242, 242, 244)];
    self.searchResult = [NSMutableArray new];
    self.department = [NSMutableArray new];
    self.keyString=@"";
     DDLog(@"come to");
    if ([[SpellLibrary instance] isEmpty]) {
        DDLog(@"spelllibrary is empty");
        
        [[DDDatabaseUtil instance] getAllUsers:^(NSArray *contacts, NSError *error) {
            for (DDUserEntity *user in contacts) {
                [[SpellLibrary instance] addSpellForObject:user];
                [[SpellLibrary instance] addDeparmentSpellForObject:user];
            }}];

    }
         // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
{
    if ([searchText isEqualToString:@""]) {
        return ;
    }
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD show:YES];
    HUD.dimBackground = YES;
    HUD.labelText = @"正在搜索";
    [[DDSearch instance] searchDepartment:searchText completion:^(NSArray *result, NSError *error) {
        if ([result count] >0) {
            [self.department removeAllObjects];
            [result enumerateObjectsUsingBlock:^(DDUserEntity *obj, NSUInteger idx, BOOL *stop) {
                if (![self.department containsObject:obj.department]) {
                    [self.department addObject:obj.department];
                }
            }];
            
            [self.tableView reloadData];
            }
          [HUD removeFromSuperview];
        }
    ];
    [[DDSearch instance] searchContent:searchText completion:^(NSArray *result, NSError *error) {
        self.keyString=searchText;
        if ([result count] >0) {
            [self.searchResult removeAllObjects];
            [self.searchResult addObjectsFromArray:result];
            [self.tableView reloadData];
        }
          [HUD removeFromSuperview];
    }];
    
  
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.searchResult count];
    }else
    {
        return [self.department count];
    }
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"contactsCell";
    DDContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier ];
    if (cell == nil) {
        cell = [[DDContactsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    DDUserEntity *user=nil;
    if (indexPath.section == 0) {
        user = [self.searchResult objectAtIndex:indexPath.row];
        [cell setCellContent:user.avatar Name:user.name];
    }else
    {
      NSString *string = [self.department objectAtIndex:indexPath.row];
        [cell setCellContent:user.avatar Name:string];
    }
    
    
    
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [self.searchResult count]?@"联系人":@"";
    }
        return [self.searchResult count]?@"部门":@"";
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        DDUserEntity *user;
        user = self.searchResult[indexPath.row];
        PublicProfileViewControll *public = [PublicProfileViewControll new];
        public.user=user;
        [self.navigationController pushViewController:public animated:YES];
        return;
        
    }else
    {
//         NSString *string = [self.department objectAtIndex:indexPath.row];
//        [self.navigationController popToRootViewControllerAnimated:NO];
//        TheAppDel.mainViewControll.contacts.sectionTitle=string;
//        TheAppDel.mainViewControll.selectedIndex=1;
        
        NSString *string = [self.department objectAtIndex:indexPath.row];
        ContactsViewController *contact = [ContactsViewController new];
        contact.sectionTitle=string;
        contact.isSearchResult=YES;
        [self.navigationController pushViewController:contact animated:YES];

    }
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}
/*
#pragma mark - Navigation

 In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     Get the new view controller using [segue destinationViewController].
     Pass the selected object to the new view controller.
}
*/

@end
