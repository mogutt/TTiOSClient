//
//  QuickReplyView.m
//  TeamTalk
//
//  Created by Michael Scofield on 2014-08-29.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "QuickReplyView.h"
#import "DDMessageEntity.h"
#import "std.h"
#import "DDSessionEntity.h"
#import "UIImageView+WebCache.h"
#import "DDUserModule.h"
#import "ChattingMainViewController.h"
@interface QuickReplyView()
@property(strong) UILabel *description;
@property(strong)UIImageView *avater;
@property(strong)dispatch_source_t timer;
@property(strong)DDMessageEntity *msg;
@property(strong)UILabel *name ;
@end
#define ViewHeight  80
@implementation QuickReplyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame=CGRectMake(0, 0, 320, ViewHeight);
        self.alpha=0.0;
        self.userInteractionEnabled=YES;
        self.backgroundColor=RGB(242, 242, 242);
        [self setClipsToBounds:YES];
        [self.layer setCornerRadius:2];

        self.avater = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 50, 50)];
        [self.avater setImage:[UIImage imageNamed:@"user_placeholder"]];
        [self.avater setClipsToBounds:YES];
        [self.avater.layer setCornerRadius:self.avater.frame.size.width/2];
        
        [self addSubview:self.avater];
        
        self.name = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 100, 15)];
        self.name.text=@"东邪";
        [self addSubview:self.name];
        
        self.description = [[UILabel alloc] initWithFrame:CGRectMake(self.name.frame.origin.x, self.name.frame.origin.y+self.name.frame.size.height/2+6, 250, 50)];
        [self.description setFont:[UIFont systemFontOfSize:14]];
        self.description.textAlignment = NSTextAlignmentLeft;
        self.description.lineBreakMode = NSLineBreakByWordWrapping;
        self.description.numberOfLines = 0;
        [self.description setTextColor:[UIColor grayColor]];
        [self addSubview:self.description];
        [self initGestureRecognizer];
    }
    return self;
}
-(void)initGestureRecognizer
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startChat)];
    [self addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *panGR =
    [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(objectDidDragged:)];
    [panGR setMaximumNumberOfTouches:1];
    [panGR setMinimumNumberOfTouches:1];
    [self addGestureRecognizer:panGR];
}
- (void)objectDidDragged:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged ||
        sender.state == UIGestureRecognizerStateEnded) {
         dispatch_source_cancel(self.timer);
        CGPoint offset = [sender translationInView:self];
        [self setCenter:CGPointMake(self.center.x + offset.x, self.center.y)];
        [sender setTranslation:CGPointMake(0, 0) inView:self];
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.center.x >270) {
            [self draggedHiddenToRight];
        }else
        {
            [self fromRightBack];
        }
    }
}
-(void)fromRightBack
{
    [UIView animateWithDuration:0.3 animations:^{
        self.frame=CGRectMake(0, 65, 320, ViewHeight);
        self.alpha=1.0;
    }];
}
-(void)draggedHiddenToRight
{
    [UIView animateWithDuration:0.3 animations:^{
        self.frame=CGRectMake(320, 65, 320, ViewHeight);
        self.alpha=0.0;
    } completion:^(BOOL finished) {
        if (finished) {
             self.frame=CGRectMake(0, 0, 320, ViewHeight);
        }
    }];
}
-(void)showQuickReply
{
    
    [UIView animateWithDuration:0.5 animations:^{
            self.alpha=1.0;
            self.frame=CGRectMake(0, 65, 320, ViewHeight);
            self.frame=CGRectMake(0, 80, 320, ViewHeight);
            self.frame=CGRectMake(0, 65, 320, ViewHeight);
        
    } completion:^(BOOL finished) {
        [self countDown];
    }];
}
-(void)setDescriptionInfo:(DDMessageEntity *)message;
{
    
    self.msg=message;
    self.description.text=message.msgContent;
    __weak QuickReplyView *weakSelf=self;
    [[DDUserModule shareInstance] getUserForUserID:message.senderId Block:^(DDUserEntity *user) {
        weakSelf.name.text=user.name;
        [weakSelf.avater sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"user_placeholder"]];
    }];
    [self showQuickReply];
}
-(void)countDown
{
    __block int timeout = 2; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
     self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(self.timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(self.timer, ^{
        if(timeout<=0){
            dispatch_source_cancel(self.timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [self hiddenView];
            });
        }else{
            timeout--;
        }
    });
    dispatch_resume(self.timer);
}
-(void)hiddenView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.frame=CGRectMake(0, 0, 320, ViewHeight);
        self.alpha=0.0;
    }];
}
-(void)startChat
{
     dispatch_source_cancel(self.timer);
    SessionType type = self.msg.msgType>5?SESSIONTYPE_TEMP_GROUP:SESSIONTYPE_SINGLE;
    DDSessionEntity *session = [[DDSessionEntity alloc] initWithSessionID:self.msg.sessionId type:type];
    [self hiddenView];
    [[ChattingMainViewController shareInstance] showChattingContentForSession:session];
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
