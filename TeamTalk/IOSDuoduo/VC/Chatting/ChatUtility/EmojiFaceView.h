//
//  DDEmojiFaceView.h
//  IOSDuoduo
//
//  Created by 东邪 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol facialViewDelegate

-(void)selectedFacialView:(NSString*)str;

@end
@interface EmojiFaceView : UIView
@property(nonatomic,assign)id<facialViewDelegate>delegate;
-(void)loadFacialView:(int)page size:(CGSize)size;
@end
