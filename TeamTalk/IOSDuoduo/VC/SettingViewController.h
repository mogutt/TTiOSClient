//
//  DDSettingViewController.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-19.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,weak)IBOutlet UITableView* tableView;
-(IBAction)clearCache:(id)sender;
-(IBAction)logout:(id)sender;
@end
