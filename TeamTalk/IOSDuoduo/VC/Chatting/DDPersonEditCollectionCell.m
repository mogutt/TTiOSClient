//
//  DDPersonEditCollectionCell.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-20.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "DDPersonEditCollectionCell.h"
#import "UIImageView+WebCache.h"
#import "std.h"
@implementation DDPersonEditCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.personIcon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 60.5, 58.5)];
        [self.personIcon setClipsToBounds:YES];
        [self.personIcon setContentMode:UIViewContentModeScaleAspectFill];
        [self.contentView addSubview:self.personIcon];
        self.name = [[UILabel alloc] initWithFrame:CGRectMake(0,73, frame.size.width-5, 14)];
        [self.name setTextAlignment:NSTextAlignmentCenter];
        [self.name setFont:[UIFont systemFontOfSize:14.0]];
        [self.name setTextColor:GRAYCOLOR];
        [self.contentView addSubview:self.name];
        
    }
    return self;
}
-(void)setContent:(NSString *)name AvatarImage:(NSString *)urlString
{
        [self.name setText:name];
    if ([urlString isEqualToString:@"edit_100x100"]) {
        self.tag=100;
        self.personIcon.image = [UIImage imageNamed:@"edit"];
        
    }else
    {
        [self.personIcon sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"user_placeholder"]];
    }

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
