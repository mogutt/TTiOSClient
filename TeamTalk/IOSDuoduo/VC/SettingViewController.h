//
//  DDSettingViewController.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-19.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property(weak)IBOutlet UITableView *tableView;
@end
