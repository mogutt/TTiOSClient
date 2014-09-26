//
//  ChatEditTableViewCell.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-04.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "ChatEditTableViewCell.h"

@implementation ChatEditTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 15)];
        [self.contentView addSubview:self.title];
    
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
