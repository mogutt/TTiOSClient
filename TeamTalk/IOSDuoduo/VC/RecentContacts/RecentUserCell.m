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
#import "RuntimeStatus.h"
#import "DDUserEntity.h"
#import "DDMessageModule.h"
#import "GroupAvatarImage.h"
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
    [[_avatarImageView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(UIView*)obj removeFromSuperview];
    }];
    
    NSURL* avatarURL = [NSURL URLWithString:avatar];
    [_avatarImageView setClipsToBounds:YES];
    [_avatarImageView.layer setCornerRadius:4];
    UIImage* placeholder = [UIImage imageNamed:@"user_placeholder"];
    [_avatarImageView sd_setImageWithURL:avatarURL placeholderImage:placeholder];
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
    
    [self setLastMessage:@" "];
    if ([TheRuntime isInFixedTop:group.objID]) {
        [self.onTopImage setHidden:NO];
    }else
    {
        [self.onTopImage setHidden:YES];
    }
   
    [[DDMessageModule shareInstance] getLastMessageForSessionID:group.objID block:^(DDMessageEntity *message) {
        [self setTimeStamp:message.msgTime];
#warning messagetype =3 的问题
        if ([message.sessionId isEqualToString:group.objID])
        {
            if ( message.msgContentType == DDMessageTypeText ) {
                [self setLastMessage:message.msgContent];
            }else if ( message.msgContentType == DDGroup_MessageTypeVoice ||message.msgContentType == DDMessageTypeVoice )
            {
                [self setLastMessage:@"[语音]"];
            }
            else if(message.msgContentType == DDMessageTypeImage)
            {
                [self setLastMessage:@"[图片]"];
            }
            else
            {
                [self setLastMessage:message.msgContent];
            }
        }
    }];
    NSUInteger unreadMessageCount = [[DDMessageModule shareInstance] getUnreadMessageCountForSessionID:group.objID];
    
    //assert(unreadMessageCount == 0);
    [self setUnreadMessageCount:unreadMessageCount];
    [self setAvatar:@"user_placeholder"];
    
    [[_avatarImageView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(UIView*)obj removeFromSuperview];
    }];
     [_avatarImageView setImage:nil];
    [_avatarImageView setBackgroundColor:RGB(222, 224, 224)];
    NSMutableArray* avatars = [[NSMutableArray alloc] init];
    [group.groupUserIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 21, 21)];
        [imageView.layer setCornerRadius:2.0];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageView setClipsToBounds:YES];
        NSString* userID = (NSString*)obj;
        [[DDUserModule shareInstance] getUserForUserID:userID Block:^(DDUserEntity *user) {
            NSString* avatar = user.avatar;
            NSURL* avatarURL = [[NSURL alloc] initWithString:avatar];
            [imageView sd_setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"user_placeholder"]];
        }];
        [avatars addObject:imageView];
        
        if ([avatars count] >= 4)
        {
            *stop = YES;
        }
    }];
    if ([avatars count] == 1)
    {
        UIImageView* imageView1 = avatars[0];
        [imageView1 setCenter:CGPointMake(_avatarImageView.width / 2, _avatarImageView.height / 2)];
    }
    else if ([avatars count] == 2)
    {
        UIImageView* imageView1 = avatars[0];
        [imageView1 setCenter:CGPointMake(_avatarImageView.width / 4 + 1, _avatarImageView.height / 2)];
        
        UIImageView* imageView2 = avatars[1];
        [imageView2 setCenter:CGPointMake(_avatarImageView.width / 4 * 3, _avatarImageView.height / 2)];
    }
    else if ([avatars count] == 3)
    {
        UIImageView* imageView1 = avatars[0];
        [imageView1 setCenter:CGPointMake(_avatarImageView.width / 2, _avatarImageView.height / 4 + 1)];
        
        UIImageView* imageView2 = avatars[1];
        [imageView2 setCenter:CGPointMake(_avatarImageView.width / 4 + 1, _avatarImageView.height / 4 * 3)];
        
        UIImageView* imageView3 = avatars[2];
        [imageView3 setCenter:CGPointMake(_avatarImageView.width / 4 * 3, _avatarImageView.height / 4 * 3)];
        
    }
    else if ([avatars count] == 4)
    {
        UIImageView* imageView1 = avatars[0];
        [imageView1 setCenter:CGPointMake(_avatarImageView.width / 4 + 1, _avatarImageView.height / 4 + 1)];
        
        UIImageView* imageView2 = avatars[1];
        [imageView2 setCenter:CGPointMake(_avatarImageView.width / 4 * 3, _avatarImageView.height / 4 + 1)];
        
        UIImageView* imageView3 = avatars[2];
        [imageView3 setCenter:CGPointMake(_avatarImageView.width / 4 + 1, _avatarImageView.height / 4 * 3)];
        
        UIImageView* imageView4 = avatars[3];
        [imageView4 setCenter:CGPointMake(_avatarImageView.width / 4 * 3, _avatarImageView.height / 4 * 3)];
    }
    [avatars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_avatarImageView addSubview:obj];
    }];

}
-(void)setShowUser:(DDUserEntity *)user
{
    
    [[_avatarImageView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(UIView*)obj removeFromSuperview];
    }];
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
    if ([TheRuntime isInFixedTop:user.objID]) {
        [self.onTopImage setHidden:NO];
    }else
    {
        [self.onTopImage setHidden:YES];
    }
    NSUInteger unreadMessageCount = [[DDMessageModule shareInstance] getUnreadMessageCountForSessionID:user.objID];
    
    [self setUnreadMessageCount:unreadMessageCount];
    [self setLastMessage:@"   "];
    [[DDMessageModule shareInstance] getLastMessageForSessionID:user.objID block:^(DDMessageEntity *message) {
        [self setTimeStamp:message.msgTime];
        if ([message.sessionId isEqualToString:user.objID])
        {
            if (message.msgContentType == DDMessageTypeText  ) {
                [self setLastMessage:message.msgContent];
            }else if (message.msgContentType == DDMessageTypeVoice)
            {
                [self setLastMessage:@"[语音]"];
            }
            else if(message.msgContentType == DDMessageTypeImage)
            {
                [self setLastMessage:@"[图片]"];
            }
        }
        
    }];
    }
@end
