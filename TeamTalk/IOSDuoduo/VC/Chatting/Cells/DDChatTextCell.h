//
//  DDChatTextCell.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-28.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDChatBaseCell.h"

@class DDMenuLabel;
@interface DDChatTextCell : DDChatBaseCell<DDChatCellProtocol>
@property (nonatomic,retain)UILabel* contentLabel;
-(void)sendTextAgain:(DDMessageEntity *)message;
@end
