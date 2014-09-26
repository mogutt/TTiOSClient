//
//  DDEmojiFaceView.m
//  IOSDuoduo
//
//  Created by 东邪 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "EmojiFaceView.h"
#import "EmotionsModule.h"
#define DD_MAC_EMOTIONS_COUNT_PERPAGE                           20
#define DD_EMOTIONS_PERROW                                      7
#define DD_EMPTIONS_ROWS                                        3

@implementation EmojiFaceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)loadFacialView:(int)page size:(CGSize)size
{
	//row number
    NSArray* emotions = [EmotionsModule shareInstance].emotions;
	for (int i=0; i<DD_EMPTIONS_ROWS; i++) {
		//column numer
		for (int y=0; y<DD_EMOTIONS_PERROW; y++) {
			UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundColor:[UIColor clearColor]];
            [button setFrame:CGRectMake(y*size.width, i*size.height, size.width, size.height)];
            if ((i * DD_EMOTIONS_PERROW + y + page * DD_MAC_EMOTIONS_COUNT_PERPAGE) > [emotions count]) {
                return;
            }else{
                if (i * DD_EMOTIONS_PERROW + y == DD_MAC_EMOTIONS_COUNT_PERPAGE || (i * DD_EMOTIONS_PERROW + y + page * DD_MAC_EMOTIONS_COUNT_PERPAGE) == [emotions count])
                {
                    [button setImage:[UIImage imageNamed:@"dd_emoji_delete"] forState:UIControlStateNormal];
                    button.tag=10000;
                    [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
                    [self addSubview:button];
                }
                else
                {
                    [button.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:27.0]];
                    [button setTitle: [emotions objectAtIndex:i*DD_EMOTIONS_PERROW+y+(page*DD_MAC_EMOTIONS_COUNT_PERPAGE)]forState:UIControlStateNormal];
                    button.tag=i*DD_EMOTIONS_PERROW+y+(page*DD_MAC_EMOTIONS_COUNT_PERPAGE);
                    [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
                    [self addSubview:button];
                }
            }
		}
	}
}
-(void)selected:(UIButton*)bt
{
    NSArray* emotions = [EmotionsModule shareInstance].emotions;
    if (bt.tag==10000) {
        [self.delegate selectedFacialView:@"delete"];
    }else{
        NSString *str=[emotions objectAtIndex:bt.tag];
        [self.delegate selectedFacialView:str];
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
