//
//  DDRecentUsersViewController.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RecentUserVCModule;
@interface RecentUsersViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
@property(nonatomic,weak)IBOutlet UITableView* tableView;
@property(nonatomic,strong)RecentUserVCModule* module;

+ (instancetype)shareInstance;
-(void)moveSessionToTop:(NSString *)sesstionID;
- (void)showLinking;
-(void)setToolbarBadge;
@end
