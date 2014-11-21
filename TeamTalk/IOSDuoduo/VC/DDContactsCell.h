//
//  DDContactsCell.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-22.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DDGroupEntity;
@interface DDContactsCell : UITableViewCell
@property(strong)UIButton *button;
@property(strong)UIImageView *avatar;
@property(strong)UILabel *nameLabel;
-(void)setCellContent:(NSString *)avater Name:(NSString *)nameLabel;
- (void)setGroupAvatar:(DDGroupEntity*)group;
@end
