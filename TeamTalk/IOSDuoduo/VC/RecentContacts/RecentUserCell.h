//
//  DDRecentUserCell.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDGroupEntity.h"
#import "DDUserEntity.h"
@interface RecentUserCell : UITableViewCell
@property (weak)IBOutlet UIImageView* avatarImageView;
@property (weak)IBOutlet UILabel* nameLabel;
@property (weak)IBOutlet UILabel* dateLabel;
@property (weak)IBOutlet UILabel* lastmessageLabel;
@property (weak)IBOutlet UILabel* unreadMessageCountLabel;
@property (weak)IBOutlet UIImageView *onTopImage;
@property (assign)NSInteger time_sort;
- (void)setName:(NSString*)name;
- (void)setTimeStamp:(NSUInteger)timeStamp;
- (void)setLastMessage:(NSString*)message;
- (void)setAvatar:(NSString*)avatar;
- (void)setUnreadMessageCount:(NSUInteger)messageCount;
-(void)setShowGroup:(DDGroupEntity *)group;
-(void)setShowUser:(DDUserEntity *)user;
@end
