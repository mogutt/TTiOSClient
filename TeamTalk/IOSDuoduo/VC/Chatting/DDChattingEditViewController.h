//
//  DDChattingEditViewController.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-07-17.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridView.h"
#import "DDSessionEntity.h"
@interface DDChattingEditViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
@property(assign)BOOL isGroup;
@property(strong)NSString *groupName;
@property(nonatomic,strong)NSMutableArray *items;
@property(strong)DDSessionEntity *session;
-(void)refreshUsers:(NSMutableArray *)array;
@end
