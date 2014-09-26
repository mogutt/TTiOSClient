//
//  DDChatBaseCell.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-28.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDChatCellProtocol.h"
#import "DDMessageEntity.h"
#import "MenuImageView.h"
extern CGFloat const dd_avatarEdge;                 //头像到边缘的距离
extern CGFloat const dd_avatarBubbleGap;             //头像和气泡之间的距离
//extern CGFloat const dd_bubbleGap;                   //气泡到非头像这边的距离
extern CGFloat const dd_bubbleUpDown;                //气泡到上下边缘的距离

typedef void(^DDSendAgain)();
typedef void(^DDTapInBubble)();
typedef NS_ENUM(NSUInteger, DDBubbleLocationType)
{
    DDBubbleLeft,
    DDBubbleRight
};

@interface DDChatBaseCell : UITableViewCell<MenuImageViewDelegate,UIAlertViewDelegate>
@property (nonatomic,assign)DDBubbleLocationType location;
@property (nonatomic,retain)MenuImageView* bubbleImageView;
@property (nonatomic,retain)UIImageView* userAvatar;
@property (strong) UILabel *userName;
@property (nonatomic,retain)UIActivityIndicatorView* activityView;
@property (nonatomic,retain)UIImageView* sendFailuredImageView;
@property (nonatomic,copy)DDSendAgain sendAgain;
@property (nonatomic,copy)DDTapInBubble tapInBubble;
- (void)setContent:(DDMessageEntity*)content;
- (void)showSendFailure;
- (void)showSendSuccess;
- (void)showSending;
@end
