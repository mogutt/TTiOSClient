//
//  DDAlbumDetailsBottomBar.m
//  IOSDuoduo
//
//  Created by 东邪 on 14-6-4.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "AlbumDetailsBottomBar.h"
#import "std.h"
#import "ChattingMainViewController.h"
@implementation AlbumDetailsBottomBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 1)];
        line.backgroundColor=RGB(228, 228, 228);
        [self addSubview:line];
        self.backgroundColor=RGB(249, 249, 249);
        UIButton *preview = [UIButton buttonWithType:UIButtonTypeCustom];
        preview.frame=CGRectMake(10, 0, 45, 45);
        [preview setTitle:@"预览" forState:UIControlStateNormal];
        [preview setTitle:@"预览" forState:UIControlStateHighlighted];
        [preview setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [preview addTarget:self action:@selector(previewPicture:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:preview];
        
        self.send = [UIButton buttonWithType:UIButtonTypeCustom];
        self.send.frame=CGRectMake(230, 5, 75, 35);
        [self.send setTitle:@"发送" forState:UIControlStateNormal];
        [self.send setTitle:@"发送" forState:UIControlStateHighlighted];
        [self.send setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.send setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.send setBackgroundColor:RGB(34, 157, 254)];
        [self.send addTarget:self action:@selector(sendPicture:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.send];
    }
    return self;
}
-(void)setSendButtonTitle:(int)num
{
    [self.send setTitle:[NSString stringWithFormat:@"%@(%d)",@"发送",num] forState:UIControlStateNormal];
    [self.send setTitle:[NSString stringWithFormat:@"%@(%d)",@"发送",num] forState:UIControlStateHighlighted];
}
-(IBAction)previewPicture:(id)sender
{
    self.Block(0);
}
-(IBAction)sendPicture:(id)sender
{
    self.Block(1);
#warning 跳转处理
    //    [TheAppDel.navigationController popToViewController:[DDChattingMainViewController shareInstance] animated:YES];
}

- (void)dealloc
{
    self.Block=nil;
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
