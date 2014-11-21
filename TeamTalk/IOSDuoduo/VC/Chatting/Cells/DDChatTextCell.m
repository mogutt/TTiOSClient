//
//  DDChatTextCell.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-28.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDChatTextCell.h"
#import "UIView+DDAddition.h"
#import "std.h"
#import "DDDatabaseUtil.h"
#import "DDMessageSendManager.h"
static int const fontsize = 14;
static float const maxContentWidth = 200;

@interface DDChatTextCell(PrivateAPI)

- (void)layoutLeftLocationContent:(NSString*)content;
- (void)layoutRightLocationContent:(NSString*)content;


@end
static CGFloat const contentMaxWidth = 300.0;

@implementation DDChatTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.contentLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContent:(DDMessageEntity*)content
{
    [super setContent:content];
    
    [self.contentLabel setFont:[UIFont systemFontOfSize:fontsize]];
    [self.contentLabel setNumberOfLines:10000];
    [self.contentLabel setBackgroundColor:[UIColor clearColor]];
    [self.contentLabel setText:content.msgContent];
    
    switch (self.location)
    {
        case DDBubbleLeft:
            [self.contentLabel setTextColor:RGB(61, 61, 61)];
            break;
        case DDBubbleRight:
            [self.contentLabel setTextColor:[UIColor whiteColor]];
            break;
    }
    
    DDLog(@"%@",NSStringFromCGRect(self.contentLabel.frame));
}
#pragma mark - DDChatCellProtocol
- (CGSize)sizeForContent:(DDMessageEntity*)message
{
    NSString* content = message.msgContent;
    UIFont* font = [UIFont systemFontOfSize:fontsize];
    CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(maxContentWidth, 1000000) lineBreakMode:NSLineBreakByWordWrapping];
    return size;
}

- (float)contentUpGapWithBubble
{
    return 11;
}

- (float)contentDownGapWithBubble
{
    return 11;
}

- (float)contentLeftGapWithBubble
{
    switch (self.location) {
        case DDBubbleLeft:
            return 20;
        case DDBubbleRight:
            return 10;
    }
}

- (float)contentRightGapWithBubble
{
    switch (self.location)
    {
        case DDBubbleLeft:
            return 10;
        case DDBubbleRight:
            return 20;
    }
}

- (void)layoutContentView:(DDMessageEntity*)content
{
    float x = self.bubbleImageView.left + [self contentLeftGapWithBubble];
    float y = self.bubbleImageView.top + [self contentUpGapWithBubble];
    CGSize size = [self sizeForContent:content];
    [self.contentLabel setFrame:CGRectMake(x, y, size.width, size.height)];
}

- (float)cellHeightForMessage:(DDMessageEntity*)message
{
    CGSize size = [self sizeForContent:message];
    float height = [self contentUpGapWithBubble] + [self contentDownGapWithBubble] + size.height + dd_bubbleUpDown * 2;
    return height;
}

#pragma mark -
#pragma mark DDMenuImageView Delegate
- (void)clickTheCopy:(MenuImageView*)imageView
{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.contentLabel.text;
}

- (void)clickTheEarphonePlay:(MenuImageView*)imageView
{
}

- (void)clickTheSpeakerPlay:(MenuImageView*)imageView
{
}

- (void)clickTheSendAgain:(MenuImageView*)imageView
{
    if (self.sendAgain)
    {
        self.sendAgain();
    }
}

- (void)tapTheImageView:(MenuImageView*)imageView
{
    //子类去继承
    [super tapTheImageView:imageView];
}
-(void)sendTextAgain:(DDMessageEntity *)message
{
    message.state = DDMessageSending;
    [self showSending];
    [[DDMessageSendManager instance] sendMessage:message isGroup:[message isGroupMessage]  forSessionID:message.sessionId completion:^(DDMessageEntity* theMessage,NSError *error) {
        if (error)
        {
            DDLog(@"发送消息失败");
            //刷新消息所在行
             [self showSendFailure];
            message.state = DDMessageSendFailure;
            [[DDDatabaseUtil instance] updateMessageForMessage:message completion:^(BOOL result) {
                if (result)
                {
                   
                }
            }];
        }
        else
        {
            [self showSendSuccess];
            DDLog(@"发送消息成功,content:%@",message.msgContent);
            //刷新消息所在行
            message.state = DDmessageSendSuccess;
            //刷新DB
            [[DDDatabaseUtil instance] updateMessageForMessage:message completion:^(BOOL result) {
                if (result)
                {
                    
                }
            }];
        }
    }];

}
@end
