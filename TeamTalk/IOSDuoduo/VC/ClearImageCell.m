//
//  ClearImageCell.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-01.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "ClearImageCell.h"

@implementation ClearImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 20, 20)];
        [self.selectImage setHighlightedImage:[UIImage imageNamed:@"dd_selected_photo@2x"]];
        [self.selectImage setImage:[UIImage imageNamed:@"dd_preview_unselected@2x"]];
        [self.contentView addSubview:self.selectImage];
        self.image = [[UIImageView alloc] initWithFrame:CGRectMake(60, 9, 45, 45)];
        [self.contentView addSubview:self.image];
        self.mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.image.frame.origin.x+7+self.image.frame.size.width, 13, 200, 15)];
        [self.mainLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        [self.contentView addSubview:self.mainLabel];
        self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.mainLabel.frame.origin.x,  36, 200, 15)];
        [self.detailLabel setTextColor:[UIColor colorWithRed:110.0/225.0 green:110.0/225.0 blue:110.0/225.0 alpha:1.0]];
        [self.detailLabel setFont:[UIFont systemFontOfSize:14.0]];
        [self.contentView addSubview:self.detailLabel];
    }
    return self;
}
-(void)setCellIsToHighlight:(BOOL)isHighlight
{
    self.isSelect=isHighlight;
    [self.selectImage setHighlighted:isHighlight];
    
}
- (void) layoutSubviews
{
    [super layoutSubviews];
    if (self.isSelect) {
        [self setCellIsToHighlight:YES];
    }else
        [self setCellIsToHighlight:NO];

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
