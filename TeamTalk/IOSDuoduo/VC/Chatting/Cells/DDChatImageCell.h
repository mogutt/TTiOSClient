//
//  DDChatImageCell.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-06-09.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "DDChatBaseCell.h"
#import "MWPhotoBrowser.h"

typedef void(^DDPreview)();
typedef void(^DDTapPreview)();
@interface DDChatImageCell : DDChatBaseCell<DDChatCellProtocol,MWPhotoBrowserDelegate>
@property(nonatomic,strong)UIImageView *imgView;
@property(nonatomic,strong)NSMutableArray *photos;
@property(nonatomic,strong)DDPreview preview;
-(void)showPreview;
- (void)sendImageAgain:(DDMessageEntity*)message;
@end
