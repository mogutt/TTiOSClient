//
//  EditGroupViewController.h
//  TeamTalk
//
//  Created by Michael Scofield on 2014-09-01.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDGroupEntity.h"
#import "DDChattingEditViewController.h"
typedef void(^RefreshBlock)(NSString *sessionID);
@interface EditGroupViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property(strong)NSMutableArray *users;
@property(copy)NSString *sessionID;
@property(assign)BOOL isGroupCreator;
@property(assign)BOOL isCreat;
@property(weak)DDGroupEntity *group;
@property(strong)DDChattingEditViewController *editControll;
@end
