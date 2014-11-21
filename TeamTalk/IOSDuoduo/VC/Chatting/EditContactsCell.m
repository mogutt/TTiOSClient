//
//  EditContactsCell.m
//  TeamTalk
//
//  Created by Michael Scofield on 2014-09-10.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "EditContactsCell.h"
@interface EditContactsCell()
@property(strong)UIImageView *selectView;
@end
@implementation EditContactsCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 22, 22)];
        [self.selectView setImage:[UIImage imageNamed:@"unselected"]];
        [self.selectView setHighlightedImage:[UIImage imageNamed:@"select"]];
        [self addSubview:self.selectView];
        self.avatar.frame=CGRectMake(45, 10, 35, 35);
        self.nameLabel.frame=CGRectMake(90, 20, 100, 15);
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}
-(void)setCellToSelected:(BOOL)select
{
    [self.selectView setHighlighted:select];
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
