//
//  EditGroupViewController.h
//  TeamTalk
//
//  Created by Michael Scofield on 2014-09-01.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDChattingEditViewController.h"
typedef void(^RefreshBlock)(NSString *sessionID);
@interface EditGroupViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate>
@property(strong)NSMutableArray *users;
@property(copy)NSString *sessionID;
@property(strong)DDChattingEditViewController *editControll;
@end
