//
//  DDPersonEditCollectionCell.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-20.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "DDPersonEditCollectionCell.h"

@implementation DDPersonEditCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.personIcon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 58, 58)];
        [self.contentView addSubview:self.personIcon];
        self.name = [[UILabel alloc] initWithFrame:CGRectMake(0,73, frame.size.width-5, 14)];
        [self.name setTextAlignment:NSTextAlignmentCenter];
        [self.name setFont:[UIFont systemFontOfSize:14.0]];
        [self.contentView addSubview:self.name];
        
    }
    return self;
}
-(IBAction)deletePerson:(id)sender
{
    
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
