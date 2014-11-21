//
//  DDChatBaseCell.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-28.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDChatBaseCell.h"
#import "UIView+DDAddition.h"
#import "DDUserModule.h"
#import "ChattingMainViewController.h"
#import "PublicProfileViewControll.h"
#import <UIImageView+WebCache.h>
CGFloat const dd_avatarEdge = 5.0;                 //头像到边缘的距离
CGFloat const dd_avatarBubbleGap = 10;             //头像和气泡之间的距离
//CGFloat const dd_bubbleGap = 10;                   //气泡到非头像这边的距离
CGFloat const dd_bubbleUpDown = 10;                //气泡到上下边缘的距离
@interface DDChatBaseCell ()
@property(copy)NSString *currentUserID;

@end
@implementation DDChatBaseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [self.userAvatar setUserInteractionEnabled:YES];
        [self.contentView addSubview:self.userAvatar];
        self.userName =[[UILabel alloc] initWithFrame:CGRectMake(60, 10, 100, 15)];
        [self.userName setBackgroundColor:[UIColor clearColor]];
        [self.userName setFont:[UIFont systemFontOfSize:13.0]];
        [self.userName setTextColor:[UIColor grayColor]];
        [self.contentView addSubview:self.userName];
        self.bubbleImageView = [[MenuImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [self.contentView addSubview:self.bubbleImageView];
        [self.bubbleImageView setUserInteractionEnabled:YES];
        self.bubbleImageView.delegate = self;
        self.bubbleImageView.tag = 1000;
        
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.activityView setHidesWhenStopped:YES];
        [self.activityView setHidden:YES];
        [self.contentView addSubview:self.activityView];
        
        self.sendFailuredImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [self.sendFailuredImageView setImage:[UIImage imageNamed:@"dd_send_failed"]];
        [self.sendFailuredImageView setHidden:YES];
        self.sendFailuredImageView.userInteractionEnabled=YES;
        [self.contentView addSubview:self.sendFailuredImageView];
        [self.contentView setAutoresizesSubviews:NO];
        UITapGestureRecognizer *pan = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTheSendAgain)];
        [self.sendFailuredImageView addGestureRecognizer:pan];
        UITapGestureRecognizer *openProfile = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openProfilePage)];
        [self.userAvatar addGestureRecognizer:openProfile];
    }
    return self;
}
-(void)openProfilePage
{
    if (self.currentUserID) {
        [[DDUserModule shareInstance] getUserForUserID:self.currentUserID Block:^(DDUserEntity *user) {
            PublicProfileViewControll *public = [PublicProfileViewControll new];
            public.user=user;
                [[ChattingMainViewController shareInstance].navigationController pushViewController:public animated:YES];
        }];
    }
}
-(void)clickTheSendAgain
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"重发" message:@"是否重新发送此消息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self clickTheSendAgain:nil];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setContent:(DDMessageEntity*)content
{
    id<DDChatCellProtocol> cell = (id<DDChatCellProtocol>)self;
    //设置头像位置
  
    switch (self.location) {
        case DDBubbleLeft:
            self.userAvatar.left = dd_avatarEdge;
            break;
        case DDBubbleRight:
            self.userAvatar.right = self.width - dd_avatarEdge;
            break;
        default:
            break;
    }
    [self.userAvatar setContentMode:UIViewContentModeScaleAspectFill];
    [self.userAvatar setClipsToBounds:YES];
    [self.userAvatar setTop:dd_bubbleUpDown];
    self.currentUserID=content.senderId;
    [[DDUserModule shareInstance] getUserForUserID:content.senderId Block:^(DDUserEntity *user) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL* avatarURL = [NSURL URLWithString:user.avatar];
            [self.userAvatar sd_setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"user_placeholder"]];
            [self.userName setText:user.name];
        });
    }];
    
    
    
    //设置气泡位置
    CGSize size = [cell sizeForContent:content];
    float bubbleY = dd_bubbleUpDown;
    float bubbleheight = [cell contentUpGapWithBubble] + size.height + [cell contentDownGapWithBubble];
    float bubbleWidth = [cell contentLeftGapWithBubble] + size.width + [cell contentRightGapWithBubble];
    float bubbleX = 0;
    UIImage* bubbleImage = nil;
    switch (self.location)
    {
        case DDBubbleLeft:
            [self.userName setHidden:NO];
            bubbleImage = [UIImage imageNamed:@"left"];
            bubbleX = dd_avatarEdge + self.userAvatar.width + dd_avatarBubbleGap;
            break;
        case DDBubbleRight:
              [self.userName setHidden:YES];
            bubbleImage = [UIImage imageNamed:@"right"];
            bubbleX =  self.width - dd_avatarEdge - self.userAvatar.width - dd_avatarBubbleGap - bubbleWidth;
            break;
        default:
            break;
    }
    
    [self.bubbleImageView setFrame:CGRectMake(bubbleX, bubbleY+20, bubbleWidth, bubbleheight)];
    bubbleImage = [bubbleImage stretchableImageWithLeftCapWidth:20 topCapHeight:20];
    [self.bubbleImageView setImage:bubbleImage];
    
    //设置菊花位置
    switch (self.location)
    {
        case DDBubbleLeft:
            self.activityView.left = self.bubbleImageView.right + 10;
            self.sendFailuredImageView.left = self.bubbleImageView.right + 10;
            break;
        case DDBubbleRight:
            self.activityView.right = self.bubbleImageView.left - 10;
            self.sendFailuredImageView.right = self.bubbleImageView.left - 10;
            break;
        default:
            break;
    }
    
    DDImageShowMenu showMenu = 0;
    
    switch (content.state)
    {
        case DDMessageSending:
            [self.activityView startAnimating];
            self.sendFailuredImageView.hidden = YES;
            break;
        case DDMessageSendFailure:
            [self.activityView stopAnimating];
            self.sendFailuredImageView.hidden = NO;
            showMenu = DDShowSendAgain;
            break;
        case DDmessageSendSuccess:
            [self.activityView stopAnimating];
            self.sendFailuredImageView.hidden = YES;
            break;
    }
    
    self.activityView.centerY = self.bubbleImageView.centerY;
    self.sendFailuredImageView.centerY = self.bubbleImageView.centerY;
    
    //设置菜单
    switch (content.msgContentType) {
        case DDMessageTypeImage:
            showMenu = showMenu | DDShowPreview;
            break;
        case DDMessageTypeText:
            showMenu = showMenu | DDShowCopy;
            break;
        case DDMessageTypeVoice:
            showMenu = showMenu | DDShowEarphonePlay | DDShowSpeakerPlay;
            break;

    }
    [self.bubbleImageView setShowMenu:showMenu];
    
    //设置内容位置
    [cell layoutContentView:content];
}

- (void)showSendFailure
{
    [self.activityView stopAnimating];
    self.sendFailuredImageView.hidden = NO;
    DDImageShowMenu showMenu = self.bubbleImageView.showMenu | DDShowSendAgain;
    [self.bubbleImageView setShowMenu:showMenu];
}

- (void)showSendSuccess
{
    [self.activityView stopAnimating];
    self.sendFailuredImageView.hidden = YES;
}

- (void)showSending
{
    [self.activityView startAnimating];
    self.sendFailuredImageView.hidden = YES;
}

#pragma mark -
#pragma mark DDMenuImageView Delegate
- (void)clickTheCopy:(MenuImageView*)imageView
{
    //子类去继承
}

- (void)clickTheEarphonePlay:(MenuImageView*)imageView
{
    //子类去继承
}

- (void)clickTheSpeakerPlay:(MenuImageView*)imageView
{
    //子类去继承
}

- (void)clickTheSendAgain:(MenuImageView*)imageView
{
    //子类去继承
}

- (void)tapTheImageView:(MenuImageView*)imageView
{
    if (self.tapInBubble)
    {
        self.tapInBubble();
    }
}

- (void)clickThePreview:(MenuImageView *)imageView
{
    //子类去继承
}
@end
