//
//  DDContactsCell.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-22.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "DDContactsCell.h"

@implementation DDContactsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame=CGRectMake(15, 5, 40, 40);
        self.button.showsTouchWhenHighlighted=YES;
        [self addSubview:self.button];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
