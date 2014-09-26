//
//  DDImagesPreviewViewController.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-06-11.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "MWPhotoBrowser.h"
@interface ImagesPreviewViewController : UIViewController<MWPhotoBrowserDelegate>
@property(nonatomic,strong)NSMutableArray *imageArray;

@end
