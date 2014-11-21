//
//  DDChatVoiceCell.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-6-5.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDChatVoiceCell.h"
#import "DDMessageEntity.h"
#import "UIView+DDAddition.h"
#import "PlayerManager.h"
#import "RecorderManager.h"
#import "DDDatabaseUtil.h"
#import "DDMessageSendManager.h"
static float const maxCellLength = 180;
static float const minCellLength = 30;

@interface DDChatVoiceCell(privateAPI)

- (float)lengthForVoiceLength:(float)voiceLength;

@end

@implementation DDChatVoiceCell
{
    NSString* _voicePath;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _voiceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [self.contentView addSubview:_voiceImageView];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_timeLabel setFont:[UIFont systemFontOfSize:12]];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_timeLabel];
        
        _playedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [_playedLabel setBackgroundColor:[UIColor redColor]];
        [_playedLabel.layer setCornerRadius:5];
        [_playedLabel setClipsToBounds:YES];
        [self.contentView addSubview:_playedLabel];
    }
    return self;
}

- (void)setContent:(DDMessageEntity *)content
{
    [super setContent:content];
    
    if ([content.info[DDVOICE_PLAYED] intValue])
    {
        [_playedLabel setHidden:YES];
    }
    else
    {
        [_playedLabel setHidden:NO];
    }
    
    _voicePath = [content.msgContent copy];
    NSArray* imageArray = nil;
    
    switch (self.location)
    {
        case DDBubbleLeft:
            self.activityView.left = self.bubbleImageView.right + 10;
            self.sendFailuredImageView.left = self.bubbleImageView.right + 10;
            break;
        case DDBubbleRight:
            self.activityView.right = self.bubbleImageView.left - 10;
            self.sendFailuredImageView.right = self.bubbleImageView.left - 10;
            break;
        default:
            break;
    }
    
    switch (self.location) {
        case DDBubbleLeft:
            imageArray = @[[UIImage imageNamed:@"dd_left_voice_one"],[UIImage imageNamed:@"dd_left_voice_two"],[UIImage imageNamed:@"dd_left_voice_three"]];
            [_voiceImageView setContentMode:UIViewContentModeLeft];
            [_voiceImageView setImage:[UIImage imageNamed:@"dd_left_voice_three"]];
            break;
        case DDBubbleRight:
            imageArray = @[[UIImage imageNamed:@"dd_right_voice_one"],[UIImage imageNamed:@"dd_right_voice_two"],[UIImage imageNamed:@"dd_right_voice_three"]];
            [_voiceImageView setContentMode:UIViewContentModeRight];
            [_voiceImageView setImage:[UIImage imageNamed:@"dd_right_voice_three"]];
            self.activityView.right = self.bubbleImageView.left - 25;
            self.sendFailuredImageView.right = self.bubbleImageView.left - 25;
            [_playedLabel setHidden:YES];
            break;
    }
    float voiceLength = [content.info[VOICE_LENGTH] floatValue];
    [_voiceImageView setAnimationImages:imageArray];
    [_voiceImageView setAnimationRepeatCount:voiceLength];
    [_voiceImageView setAnimationDuration:1];
    
    NSUInteger timeLength = [content.info[VOICE_LENGTH] longValue];
    NSString* lengthString = [NSString stringWithFormat:@"%i\"",timeLength];
    [_timeLabel setText:lengthString];
}

- (void)showVoicePlayed
{
    [_playedLabel setHidden:YES];
}

- (void)stopVoicePlayAnimation
{
    [_voiceImageView stopAnimating];
}

#pragma mark -
#pragma mark DDChatCellProtocol Protocol
- (CGSize)sizeForContent:(DDMessageEntity*)content
{
    float voiceLength = [content.info[VOICE_LENGTH] floatValue];
    float width = [self lengthForVoiceLength:voiceLength];
    return CGSizeMake(width, 17);
}

- (float)contentUpGapWithBubble
{
    return 13;
}

- (float)contentDownGapWithBubble
{
    return 13;
}

- (float)contentLeftGapWithBubble
{
    switch (self.location)
    {
        case DDBubbleRight:
            return 0;
        case DDBubbleLeft:
            return 15;
    }
    return 0;
}

- (float)contentRightGapWithBubble
{
    switch (self.location)
    {
        case DDBubbleRight:
            return 15;
            break;
        case DDBubbleLeft:
            return 0;
            break;
    }
    return 0;
}

- (void)layoutContentView:(DDMessageEntity*)content
{
//    float x = self.bubbleImageView.left + [self contentLeftGapWithBubble];
    float y = self.bubbleImageView.top + [self contentUpGapWithBubble];
    [_voiceImageView setFrame:CGRectMake(0, y, 11, 17)];
    switch (self.location)
    {
        case DDBubbleLeft:
            _voiceImageView.left = self.bubbleImageView.left + [self contentLeftGapWithBubble];
            [_timeLabel setFrame:CGRectMake(self.bubbleImageView.right + 5, 0, 20, 15)];
            _timeLabel.centerY = self.bubbleImageView.centerY;
            [_timeLabel setTextAlignment:NSTextAlignmentLeft];
            
            _playedLabel.left = _timeLabel.left + 3;
            _playedLabel.top = self.bubbleImageView.top - 2;
        
            break;
        case DDBubbleRight:
            _voiceImageView.right = self.bubbleImageView.right - [self contentRightGapWithBubble];
            [_timeLabel setFrame:CGRectMake(0, 0, 20, 15)];
            _timeLabel.right = self.bubbleImageView.left - 5;
            _timeLabel.centerY = self.bubbleImageView.centerY;
            [_timeLabel setTextAlignment:NSTextAlignmentRight];
            
            _playedLabel.right = _timeLabel.right - 3;
            _playedLabel.top = self.bubbleImageView.top - 2;
            break;
    }
}

- (float)cellHeightForMessage:(DDMessageEntity*)message
{
    return 27 + 2 * dd_bubbleUpDown;
}


#pragma mark - 
#pragma mark PrivateAPI
- (float)lengthForVoiceLength:(float)voiceLength
{
    float gap = maxCellLength - minCellLength;
    if (voiceLength > 20)
    {
        return maxCellLength;
    }
    else
    {
        float length = (gap / 20) * voiceLength + minCellLength;
        return length;
    }
}

#pragma mark -
#pragma mark DDMenuImageView Delegate
- (void)clickTheCopy:(MenuImageView*)imageView
{
    //子类去继承
}

- (void)clickTheEarphonePlay:(MenuImageView*)imageView
{
    //子类去继承
    [_voiceImageView startAnimating];
    if (self.earphonePlay)
    {
        self.earphonePlay();
    }
}

- (void)clickTheSpeakerPlay:(MenuImageView*)imageView
{
    //子类去继承
    [_voiceImageView startAnimating];
    if (self.speakerPlay)
    {
        self.speakerPlay();
    }
}

- (void)clickTheSendAgain:(MenuImageView*)imageView
{
    //子类去继承
    if (self.sendAgain)
    {
        self.sendAgain();
    }
}

- (void)tapTheImageView:(MenuImageView*)imageView
{
    if (![_voiceImageView isAnimating])
    {
        [_voiceImageView startAnimating];
        [super tapTheImageView:imageView];
    }
}

-(void)sendVoiceAgain:(DDMessageEntity *)message
{
    [self showSending];
    NSString* filePath = message.msgContent;
    NSMutableData* muData = [[NSMutableData alloc] init];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    int length = [RecorderManager sharedManager].recordedTimeInterval;
    int8_t ch[4];
    for(int32_t i = 0;i<4;i++){
        ch[i] = ((length >> ((3 - i)*8)) & 0x0ff);
    }
    [muData appendBytes:ch length:4];
    [muData appendData:data];
    [[DDMessageSendManager instance] sendVoiceMessage:muData filePath:filePath forSessionID:message.sessionId isGroup:[message isGroupMessage] completion:^(DDMessageEntity *theMessage, NSError *error) {
        if (!error)
        {
            DDLog(@"发送语音消息成功");
            message.state = DDmessageSendSuccess;
            [[DDDatabaseUtil instance] updateMessageForMessage:message completion:^(BOOL result) {
                if (result)
                {
                    [self showSendSuccess];
                }
            }];
        }
        else
        {
            DDLog(@"发送语音消息失败");
            message.state = DDMessageSendFailure;
            [[DDDatabaseUtil instance] updateMessageForMessage:message completion:^(BOOL result) {
                if (result)
                {
                    [self showSendFailure];
                }
            }];
            
        }
    }];
}
@end
