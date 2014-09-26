//
//  ContactsViewController.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-07-15.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDSessionEntity.h"
typedef void(^Block)(NSArray *array);
@interface ContactsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UIScrollViewDelegate>
@property(copy)Block block;
@end
