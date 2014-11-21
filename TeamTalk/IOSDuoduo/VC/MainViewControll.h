//
//  MainViewControll.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-07-15.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactsViewController.h"
@interface MainViewControll : UITabBarController<UITabBarControllerDelegate,UITabBarDelegate>
@property(strong)UINavigationController *nv1;
@property(strong)ContactsViewController *contacts;
-(void)setselectIndex:(int)index;
@end
