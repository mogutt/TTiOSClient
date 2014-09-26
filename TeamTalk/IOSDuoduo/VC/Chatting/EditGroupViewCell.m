//
//  EditGroupViewCell.m
//  TeamTalk
//
//  Created by Michael Scofield on 2014-09-01.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "EditGroupViewCell.h"
#import "std.h"
@interface EditGroupViewCell()

@end
@implementation EditGroupViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.personIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [self.contentView addSubview:self.personIcon];
        self.name = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, 50, 25)];
        [self.name setFont:[UIFont systemFontOfSize:14.0]];
        [self.contentView addSubview:self.name];
        [self.layer setBorderWidth:0.5];
        [self.layer setBorderColor:RGB(199, 199, 196).CGColor];
        self.button = [[UIButton alloc] initWithFrame:CGRectMake(0, self.personIcon.frame.origin.y+self.personIcon.frame.size.height, 25, 0)];
        
        [self.button setBackgroundColor:[UIColor redColor]];
        self.button.alpha=0.0 ;
        [self.contentView addSubview:self.button];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDeleteActionView)];
        //[self addGestureRecognizer:tap];
        
    }
    return self;
}
-(void)showDeleteActionView
{
    if (self.button.alpha==1.0) {
        [UIView animateWithDuration:0.5 animations:^{
            self.button.alpha=0.0 ;
            self.button.frame=CGRectMake(0, self.personIcon.frame.origin.y+self.personIcon.frame.size.height, 25, 0);
        }];
    }else
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.button.alpha=1.0 ;
            self.button.frame=CGRectMake(0, 0, 25, 25);
        }];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
