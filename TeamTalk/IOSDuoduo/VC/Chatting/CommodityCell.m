//
//  DDCommodityCell.m
//  IOSDuoduo
//
//  Created by 东邪 on 14-6-3.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "CommodityCell.h"

@implementation CommodityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        
    }
    return self;
}
-(void)setOldPrice:(float )price
{
    [self.priceOld setText:[NSString stringWithFormat:@"$%.2f",price]];
}
-(void)setNewPrice:(float )price
{
    [self.priceNew setText:[NSString stringWithFormat:@"$%.2f",price]];
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

- (void)setMessage:(DDMessageEntity*)message
{
    
}

@end
