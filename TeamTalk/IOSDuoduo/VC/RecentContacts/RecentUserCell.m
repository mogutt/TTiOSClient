//
//  DDRecentUserCell.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "RecentUserCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSDate+DDAddition.h"
#import "UIView+DDAddition.h"
#import "std.h"
#import "DDUserEntity.h"
#import "DDMessageModule.h"
#import "DDUserModule.h"
@implementation RecentUserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected)
    {
        [_nameLabel setTextColor:[UIColor whiteColor]];
        [_lastmessageLabel setTextColor:[UIColor whiteColor]];
        [_dateLabel setTextColor:[UIColor whiteColor]];
    }
    else
    {
        [_nameLabel setTextColor:[UIColor blackColor]];
        [_lastmessageLabel setTextColor:RGB(135, 135, 135)];
        [_dateLabel setTextColor:RGB(135, 135, 135)];
    }
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated               // animate between regular and highlighted state
{
    if (highlighted && self.selected)
    {
        [_nameLabel setTextColor:[UIColor whiteColor]];
        [_lastmessageLabel setTextColor:[UIColor whiteColor]];
        [_dateLabel setTextColor:[UIColor whiteColor]];
    }
    else
    {
        [_nameLabel setTextColor:[UIColor blackColor]];
        [_lastmessageLabel setTextColor:RGB(135, 135, 135)];
        [_dateLabel setTextColor:RGB(135, 135, 135)];
    }
}

#pragma mark - public
- (void)setName:(NSString*)name
{
    if (!name)
    {
        [_nameLabel setText:@""];
    }
    else
    {
        [_nameLabel setText:name];
    }
}

- (void)setTimeStamp:(NSUInteger)timeStamp
{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSString* dateString = [date transformToFuzzyDate];
    [_dateLabel setText:dateString];
}

- (void)setLastMessage:(NSString*)message
{
    if (!message)
    {
        [_lastmessageLabel setText:@""];
    }
    else
    {
        [_lastmessageLabel setText:message];
    }
}

- (void)setAvatar:(NSString*)avatar
{
    NSURL* avatarURL = [NSURL URLWithString:avatar];
    [_avatarImageView setClipsToBounds:YES];
    [_avatarImageView.layer setCornerRadius:2.0];
    UIImage* placeholder = [UIImage imageNamed:@"user_placeholder"];
    [_avatarImageView setImageWithURL:avatarURL placeholderImage:placeholder];
}

- (void)setUnreadMessageCount:(NSUInteger)messageCount
{
    if (messageCount == 0)
    {
        [self.unreadMessageCountLabel setHidden:YES];
    }
    else if (messageCount < 10)
    {
        [self.unreadMessageCountLabel setHidden:NO];
        CGPoint center = self.unreadMessageCountLabel.center;
        NSString* title = [NSString stringWithFormat:@"%i",messageCount];
        [self.unreadMessageCountLabel setText:title];
        [self.unreadMessageCountLabel setWidth:16];
        [self.unreadMessageCountLabel setCenter:center];
        [self.unreadMessageCountLabel.layer setCornerRadius:8];
    }
    else if (messageCount < 99)
    {
        [self.unreadMessageCountLabel setHidden:NO];
        CGPoint center = self.unreadMessageCountLabel.center;
        NSString* title = [NSString stringWithFormat:@"%i",messageCount];
        [self.unreadMessageCountLabel setText:title];
        [self.unreadMessageCountLabel setWidth:25];
        [self.unreadMessageCountLabel setCenter:center];
        [self.unreadMessageCountLabel.layer setCornerRadius:8];
    }
    else
    {
        [self.unreadMessageCountLabel setHidden:NO];
        CGPoint center = self.unreadMessageCountLabel.center;
        NSString* title = @"99+";
        [self.unreadMessageCountLabel setText:title];
        [self.unreadMessageCountLabel setWidth:34];
        [self.unreadMessageCountLabel setCenter:center];
        [self.unreadMessageCountLabel.layer setCornerRadius:8];
    }
}
-(void)setShowGroup:(DDGroupEntity *)group
{
    [_nameLabel setText:group.name];
     [self setTimeStamp:group.lastUpdateTime];
    [[DDMessageModule shareInstance] getLastMessageForSessionID:group.groupId completion:^(DDMessageEntity *message) {
        if ( message.msgType == DDGroup_Message_TypeText ) {
            [self setLastMessage:message.msgContent];
        }else if ( message.msgType == DDGroup_MessageTypeVoice)
        {
             [self setLastMessage:@"[语音]"];
        }
        else if(message.msgType == DDMessageTypeImage)
        {
            [self setLastMessage:@"[图片]"];
        }
        else
        {
           [self setLastMessage:message.msgContent];
        }
    }];
    NSUInteger unreadMessageCount = [[DDMessageModule shareInstance] getUnreadMessageCountForSessionID:group.groupId];
    [self setUnreadMessageCount:unreadMessageCount];
}
-(void)setShowUser:(DDUserEntity *)user
{

        if ([user.nick length] > 0)
        {
            [self setName:user.nick];
        }
        else
        {
            [self setName:user.name];
        }
        [self setAvatar:user.avatar];
        [self setTimeStamp:user.lastUpdateTime];
        NSUInteger unreadMessageCount = [[DDMessageModule shareInstance] getUnreadMessageCountForSessionID:user.userId];
        [self setUnreadMessageCount:unreadMessageCount];
    [[DDMessageModule shareInstance] getLastMessageForSessionID:user.userId completion:^(DDMessageEntity *message) {
        if (message.msgType == DDMessageTypeText  ) {
            [self setLastMessage:message.msgContent];
        }else if (message.msgType == DDMessageTypeVoice)
        {
            [self setLastMessage:@"[语音]"];
        }
        else if(message.msgType == DDMessageTypeImage)
        {
            [self setLastMessage:@"[图片]"];
        }
        

    }];
   }
@end
