//
//  DDPromptCell.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-6-9.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDPromptCell.h"
#import "UIView+DDAddition.h"
@implementation DDPromptCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
//        [_promptLabel setBackgroundColor:RGB(193, 193, 193)];
        [_promptLabel setBackgroundColor:[UIColor blackColor]];
        [_promptLabel setAlpha:0.2];
        [_promptLabel setTextColor:[UIColor whiteColor]];
        [_promptLabel setFont:[UIFont systemFontOfSize:12]];
        [_promptLabel setTextAlignment:NSTextAlignmentCenter];
        [_promptLabel.layer setCornerRadius:5];
        [_promptLabel setClipsToBounds:YES];
        [self.contentView addSubview:_promptLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setprompt:(NSString*)prompt
{
    UIFont* font = [UIFont systemFontOfSize:12];
    CGSize size = [prompt sizeWithFont:font constrainedToSize:CGSizeMake(320, 1000000) lineBreakMode:NSLineBreakByWordWrapping];
    [_promptLabel setSize:CGSizeMake(size.width + 30, size.height + 6)];
    [_promptLabel setCenter:self.contentView.center];
    [_promptLabel setText:prompt];
}

@end
