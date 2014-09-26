//
//  PublieProfileViewControll.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-07-16.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DDUserEntity;
@interface PublicProfileViewControll : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(strong)DDUserEntity *user;
@end
