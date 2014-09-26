//
//  DDChatImagePreviewViewController.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-06-11.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"
@interface DDChatImagePreviewViewController : UIViewController<MWPhotoBrowserDelegate>
@property(nonatomic,strong)NSMutableArray *photos;
@end