//
//  DDChattingMainViewController.m
//  IOSDuoduo
//
//  Created by 东邪 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "ChattingMainViewController.h"
#import "ChatUtilityViewController.h"
#import "std.h"
#import "DDGroupModule.h"
#import "DDMessageSendManager.h"
#import "DDGroupMsgReadACKAPI.h"
#import "DDDatabaseUtil.h"
#import "DDChatTextCell.h"
#import "DDChatVoiceCell.h"
#import "DDChatImageCell.h"
#import "QuickReplyView.h"
#import "DDChattingEditViewController.h"
#import "DDPromptCell.h"
#import "UIView+DDAddition.h"
#import "DDMessageModule.h"
#import "RecordingView.h"
#import "AnalysisImage.h"
#import "TouchDownGestureRecognizer.h"
#import "DDSendMessageReadACKAPI.h"
#import "DDSendPhotoMessageAPI.h"
#import "NSDictionary+JSON.h"
#import "EmotionsModule.h"
#import "RuntimeStatus.h"

typedef NS_ENUM(NSUInteger, DDBottomShowComponent)
{
    DDInputViewUp                       = 1,
    DDShowKeyboard                      = 1 << 1,
    DDShowEmotion                       = 1 << 2,
    DDShowUtility                       = 1 << 3
};

typedef NS_ENUM(NSUInteger, DDBottomHiddComponent)
{
    DDInputViewDown                     = 14,
    DDHideKeyboard                      = 13,
    DDHideEmotion                       = 11,
    DDHideUtility                       = 7
};
//

typedef NS_ENUM(NSUInteger, DDInputType)
{
    DDVoiceInput,
    DDTextInput
};

typedef NS_ENUM(NSUInteger, PanelStatus)
{
    VoiceStatus,
    TextInputStatus,
    EmotionStatus,
    ImageStatus
};

#define DDINPUT_MIN_HEIGHT          44.0f
#define DDINPUT_HEIGHT              self.chatInputView.size.height
#define DDINPUT_BOTTOM_FRAME        CGRectMake(0, CONTENT_HEIGHT - self.chatInputView.height + NAVBAR_HEIGHT,FULL_WIDTH,self.chatInputView.height)
#define DDINPUT_TOP_FRAME           CGRectMake(0, CONTENT_HEIGHT - self.chatInputView.height + NAVBAR_HEIGHT - 216, 320, self.chatInputView.height)
#define DDUTILITY_FRAME             CGRectMake(0, CONTENT_HEIGHT + NAVBAR_HEIGHT -216, 320, 216)
#define DDEMOTION_FRAME             CGRectMake(0, CONTENT_HEIGHT + NAVBAR_HEIGHT-216, 320, 216)
#define DDCOMPONENT_BOTTOM          CGRectMake(0, CONTENT_HEIGHT + NAVBAR_HEIGHT, 320, 216)

@interface ChattingMainViewController ()<UIGestureRecognizerDelegate>
@property(nonatomic,assign)CGPoint inputViewCenter;
@property(nonatomic,strong)UIActivityIndicatorView *activity;
@property(assign)PanelStatus panelStatus;
@property(strong)NSString *chatObjectID;
@property(strong)QuickReplyView *replyView;
- (void)recentViewController;

- (UITableViewCell*)p_textCell_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath message:(DDMessageEntity*)message;
- (UITableViewCell*)p_voiceCell_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath message:(DDMessageEntity*)message;
- (UITableViewCell*)p_promptCell_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath message:(DDPromptEntity*)prompt;
- (UITableViewCell*)p_commodityCell_tableView:(UITableView* )tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath message:(DDMessageEntity*)commodity;

- (void)n_receiveMessage:(NSNotification*)notification;
- (void)n_receiveUnreadMessageUpdateNotification:(NSNotification*)notification;
- (void)n_receiveStartLoginNotification:(NSNotification*)notification;
- (void)n_receiveLoginSuccessNotification:(NSNotification*)notification;
- (void)n_receiveLoginFailureNotification:(NSNotification*)notification;
- (void)n_receiveUserKickoffNotification:(NSNotification*)notification;

- (void)p_clickThRecordButton:(UIButton*)button;
- (void)p_record:(UIButton*)button;
- (void)p_willCancelRecord:(UIButton*)button;
- (void)p_cancelRecord:(UIButton*)button;
- (void)p_sendRecord:(UIButton*)button;
- (void)p_endCancelRecord:(UIButton*)button;

- (void)p_tapOnTableView:(UIGestureRecognizer*)sender;
- (void)p_hideBottomComponent;

- (void)p_enableChatFunction;
- (void)p_unableChatFunction;

@end

@implementation ChattingMainViewController
{
    TouchDownGestureRecognizer* _touchDownGestureRecognizer;
    NSString* _currentInputContent;
    UIButton *_recordButton;
    DDBottomShowComponent _bottomShowComponent;
    float _inputViewY;
    NSString* _goodID;
    NSString* _shopID;
    int _type;
}
+(instancetype )shareInstance
{
    static dispatch_once_t onceToken;
    static ChattingMainViewController *_sharedManager = nil;
    dispatch_once(&onceToken, ^{
        _sharedManager = [ChattingMainViewController new];
    });
    return _sharedManager;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.view];
    if (CGRectContainsPoint(DDINPUT_BOTTOM_FRAME, location))
    {
        return NO;
    }
    return YES;
}

-(void)sendImageMessage:(Photo *)photo
{
    NSDictionary* messageContentDic = @{DD_IMAGE_LOCAL_KEY:photo.localPath};
    NSString* messageContent = [messageContentDic jsonString];

    DDMessageEntity *message = [DDMessageEntity makeMessage:messageContent Module:self.module MsgType:DDMessageTypeImage];
    [self.chatInputView.textView setText:nil];
    [self.tableView reloadData];
    [[DDDatabaseUtil instance] insertMessages:@[message] success:^{
        DDLog(@"消息插入DB成功");
        
    } failure:^(NSString *errorDescripe) {
        DDLog(@"消息插入DB失败");
    }];
    [[DDSendPhotoMessageAPI sharedPhotoCache] uploadImage:photo.localPath success:^(NSString *imageURL) {
        NSDictionary* tempMessageContent = [NSDictionary initWithJsonString:message.msgContent];
        NSMutableDictionary* mutalMessageContent = [[NSMutableDictionary alloc] initWithDictionary:tempMessageContent];
        [mutalMessageContent setValue:imageURL forKey:DD_IMAGE_URL_KEY];
        NSString* messageContent = [mutalMessageContent jsonString];
        message.msgContent = messageContent;
        [self sendMessage:imageURL messageEntity:message];
    } failure:^(id error) {
        message.state = DDMessageSendFailure;
        //刷新DB
        [[DDDatabaseUtil instance] updateMessageForMessage:message completion:^(BOOL result) {
            if (result)
            {
                [self.tableView reloadData];
            }
        }];
        
    }];
    
}
- (void)textViewEnterSend
{
    //发送消息
    NSString* text = [self.chatInputView.textView text];
    if ([text length] == 0)
    {
        return;
    }
      DDMessageType msgtype = self.module.sessionEntity.sessionType == SESSIONTYPE_SINGLE?DDMessageTypeText:DDGroup_Message_TypeText;
    DDMessageEntity *message = [DDMessageEntity makeMessage:text Module:self.module MsgType:msgtype];
    [self.chatInputView.textView setText:nil];
    [[DDDatabaseUtil instance] insertMessages:@[message] success:^{
        DDLog(@"消息插入DB成功");
    } failure:^(NSString *errorDescripe) {
        DDLog(@"消息插入DB失败");
    }];
    [self sendMessage:text messageEntity:message];
}

-(void)sendMessage:(NSString *)msg messageEntity:(DDMessageEntity *)message
{
  
    BOOL isGroup = self.module.sessionEntity.sessionType == SESSIONTYPE_SINGLE?NO:YES;
    [[DDMessageSendManager instance] sendMessage:msg isGroup:isGroup forSessionID:self.module.sessionEntity.sessionID  completion:^(DDMessageEntity* theMessage,NSError *error) {
        if (error)
        {
            DDLog(@"发送消息失败");
            //刷新消息所在行
            message.state = DDMessageSendFailure;
            [[DDDatabaseUtil instance] updateMessageForMessage:message completion:^(BOOL result) {
                if (result)
                {
                    [self.tableView reloadData];
                    [self scrollToBottomAnimated:YES];
                }
            }];
        }
        else
        {
            //刷新消息所在行
            message.state = DDmessageSendSuccess;
            //刷新DB
            [[DDDatabaseUtil instance] updateMessageForMessage:message completion:^(BOOL result) {
                if (result)
                {
                    [self.tableView reloadData];
                    [self scrollToBottomAnimated:YES];
                }
            }];
        }
    }];
}
//--------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark RecordingDelegate
- (void)recordingFinishedWithFileName:(NSString *)filePath time:(NSTimeInterval)interval
{
    NSMutableData* muData = [[NSMutableData alloc] init];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    int length = [RecorderManager sharedManager].recordedTimeInterval;
    if (length < 1 )
    {
        DDLog(@"录音时间太短");
        dispatch_async(dispatch_get_main_queue(), ^{
            [_recordingView setHidden:NO];
            [_recordingView setRecordingState:DDShowRecordTimeTooShort];
        });
        return;
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_recordingView setHidden:YES];
        });
    }
    int8_t ch[4];
    for(int32_t i = 0;i<4;i++){
        ch[i] = ((length >> ((3 - i)*8)) & 0x0ff);
    }
    [muData appendBytes:ch length:4];
    [muData appendData:data];
     DDMessageType msgtype = self.module.sessionEntity.sessionType == SESSIONTYPE_SINGLE?DDMessageTypeVoice:DDGroup_MessageTypeVoice;
    DDMessageEntity* message = [DDMessageEntity makeMessage:filePath Module:self.module MsgType:msgtype];
    [message.info setObject:@(length) forKey:VOICE_LENGTH];
    [message.info setObject:@(1) forKey:DDVOICE_PLAYED];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [[DDDatabaseUtil instance] insertMessages:@[message] success:^{
            NSLog(@"消息插入DB成功");
        } failure:^(NSString *errorDescripe) {
            NSLog(@"消息插入DB失败");
        }];
        
    });
    
    [[DDMessageSendManager instance] sendVoiceMessage:muData filePath:filePath forSessionID:self.module.sessionEntity.sessionID completion:^(DDMessageEntity *theMessage, NSError *error) {
        if (!error)
        {
            DDLog(@"发送语音消息成功");
            [[PlayerManager sharedManager] playAudioWithFileName:@"msg.caf" playerType:DDSpeaker delegate:self];
            message.state = DDmessageSendSuccess;
            [[DDDatabaseUtil instance] updateMessageForMessage:message completion:^(BOOL result) {
                if (result)
                {
                    [self.tableView reloadData];
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
                    [self.tableView reloadData];
                }
            }];
            
        }
    }];
}

- (void)playingStoped
{
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)notificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(n_receiveMessage:)
                                                 name:DDNotificationReceiveMessage
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(n_receiveUnreadMessageUpdateNotification:)
                                                 name:DDNotificationUpdateUnReadMessage
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(n_receiveStartLoginNotification:) name:DDNotificationStartLogin object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(n_receiveLoginSuccessNotification:)
                                                 name:DDNotificationUserLoginSuccess
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(n_receiveLoginFailureNotification:)
                                                 name:DDNotificationUserLoginFailure
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveUserKickoffNotification:) name:DDNotificationUserKickouted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillShowKeyboard:)
												 name:UIKeyboardWillShowNotification
                                               object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillHideKeyboard:)
												 name:UIKeyboardWillHideNotification
                                               object:nil];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self notificationCenter];
    [self initialInput];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(p_tapOnTableView:)];
    [self.tableView addGestureRecognizer:tap];
    
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(p_tapOnTableView:)];
    pan.delegate = self;
    [self.tableView addGestureRecognizer:pan];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self scrollToBottomAnimated:NO];
    
    _originalTableViewContentInset = self.tableView.contentInset;
    
     self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
     self.activity.frame=CGRectMake(self.view.frame.size.width/2, 70, 20, 20);
    [self.view addSubview:self.activity];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(Edit:)];
    self.navigationItem.rightBarButtonItem=item;
    [self.module addObserver:self forKeyPath:@"showingMessages" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
    [self.module addObserver:self forKeyPath:@"sessionEntity.sessionID" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    self.replyView = [QuickReplyView new];
    [self.view addSubview:self.replyView];

    
}

-(IBAction)Edit:(id)sender
{
    DDChattingEditViewController *chattingedit = [DDChattingEditViewController new];
    chattingedit.session=self.module.sessionEntity;
    [self.navigationController pushViewController:chattingedit animated:YES];
}

- (void)back
{
    [self.chatInputView.textView resignFirstResponder];
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    
    if(rows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
        if(self.tableView.contentOffset.y < -10)
        {
            //[self.tableView setContentOffset:CGPointMake(0, -10)];
        }
    }
}

- (ChattingModule*)module
{
    if (!_module)
    {
        _module = [[ChattingModule alloc] init];
    }
    return _module;
}

#pragma mark -
#pragma mark ActionMethods  发送sendAction 音频 voiceChange  显示表情 disFaceKeyboard
-(IBAction)sendAction:(id)sender{
    if (self.chatInputView.textView.text.length>0) {
        NSLog(@"点击发送");
        [self.chatInputView.textView setText:@""];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self.chatInputView.textView setText:nil];
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.chatInputView.textView resignFirstResponder];
    [self p_hideBottomComponent];
    [self.tabBarController.tabBar setHidden:NO];
  
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark UIGesture Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer.view isEqual:_tableView])
    {
        return YES;
    }
    return NO;
}

#pragma mark - EmojiFace Funcation
-(void)insertEmojiFace:(NSString *)string
{
    NSMutableString* content = [NSMutableString stringWithString:self.chatInputView.textView.text];
    [content appendString:string];
    [self.chatInputView.textView setText:content];
}
-(void)deleteEmojiFace
{
    EmotionsModule* emotionModule = [EmotionsModule shareInstance];
    NSString* toDeleteString = nil;
    if (self.chatInputView.textView.text.length == 0)
    {
        return;
    }
    if (self.chatInputView.textView.text.length == 1)
    {
        self.chatInputView.textView.text = @"";
    }
    else
    {
        toDeleteString = [self.chatInputView.textView.text substringFromIndex:self.chatInputView.textView.text.length - 1];
        int length = [emotionModule.emotionLength[toDeleteString] intValue];
        if (length == 0)
        {
            toDeleteString = [self.chatInputView.textView.text substringFromIndex:self.chatInputView.textView.text.length - 2];
            length = [emotionModule.emotionLength[toDeleteString] intValue];
        }
        length = length == 0 ? 1 : length;
        self.chatInputView.textView.text = [self.chatInputView.textView.text substringToIndex:self.chatInputView.textView.text.length - length];
    }
    
}
#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.module.showingMessages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 0;
    id object = self.module.showingMessages[indexPath.row];
    if ([object isKindOfClass:[DDMessageEntity class]])
    {
        DDMessageEntity* message = object;
        height = [self.module messageHeight:message];
    }
    else if([object isKindOfClass:[DDPromptEntity class]])
    {
        height = 30;
    }
    return height+10;
//    return 84;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    id object = self.module.showingMessages[indexPath.row];
    UITableViewCell* cell = nil;
    if ([object isKindOfClass:[DDMessageEntity class]])
    {
        DDMessageEntity* message = (DDMessageEntity*)object;
        if (message.msgType == DDMessageTypeText || message.msgType == DDGroup_Message_TypeText ) {
            cell = [self p_textCell_tableView:tableView cellForRowAtIndexPath:indexPath message:message];
        }else if (message.msgType == DDMessageTypeVoice || message.msgType == DDGroup_MessageTypeVoice)
        {
             cell = [self p_voiceCell_tableView:tableView cellForRowAtIndexPath:indexPath message:message];
        }
        else if(message.msgType == DDMessageTypeImage)
        {
             cell = [self p_imageCell_tableView:tableView cellForRowAtIndexPath:indexPath message:message];
        }
        else
        {
             cell = [self p_textCell_tableView:tableView cellForRowAtIndexPath:indexPath message:message];
        }

    }
    else if ([object isKindOfClass:[DDPromptEntity class]])
    {
        DDPromptEntity* prompt = (DDPromptEntity*)object;
        cell = [self p_promptCell_tableView:tableView cellForRowAtIndexPath:indexPath message:prompt];
    }
    
    return cell;

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static BOOL loadingHistory = NO;
     if (scrollView.contentOffset.y < -100 && [self.module.showingMessages count] > 0 && !loadingHistory)
     {
         loadingHistory = YES;
         [self.activity startAnimating];
         NSString* sessionID = self.module.sessionEntity.sessionID;
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self.module loadMoreHistoryCompletion:^(NSUInteger addCount,NSError *error) {
                 loadingHistory = NO;
                 if ([sessionID isEqualToString:self.module.sessionEntity.sessionID])
                 {
                        [_tableView reloadData];
                      [self.activity stopAnimating];
                     if ([self.module.showingMessages count] > addCount)
                     {
                        
                         [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:addCount inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                     }
                 }
             }];
         });
     }
}
#pragma mark PublicAPI
- (void)showChattingContentForSession:(DDSessionEntity*)session
{
    self.title = @"正在联系用户";
    [self.module.showingMessages removeAllObjects];
    self.module.sessionEntity = nil;
    [self p_unableChatFunction];
    [self p_enableChatFunction];
    [self.activity startAnimating];
    if (![session.sessionID isEqualToString:self.module.sessionEntity.sessionID])
    {
        [self.module.showingMessages removeAllObjects];
        self.module.sessionEntity = session;
    }
    [self setTitle:session.name];
    NSUInteger unreadMessageCount = [[DDMessageModule shareInstance] getUnreadMessageCountForSessionID:session.sessionID];
    if (unreadMessageCount > 0)
    {
    NSArray* unreadMessages = [[DDMessageModule shareInstance]popAllUnreadMessagesForSessionID:session.sessionID];
    [[DDDatabaseUtil instance] insertMessages:unreadMessages success:^{
        DDSendMessageReadACKAPI* sendMessageReadACKAPI = [[DDSendMessageReadACKAPI alloc] init];
        [sendMessageReadACKAPI requestWithObject:session.sessionID Completion:nil];
        
        } failure:^(NSString *errorDescripe) {
                    
                }];
                [self.module addShowMessages:unreadMessages];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                    [self scrollToBottomAnimated:NO];
                });
            }
            else
            {
                [self.module loadMoreHistoryCompletion:^(NSUInteger addCount,NSError *error) {
                    [_tableView reloadData];
                    if (addCount < DD_PAGE_ITEM_COUNT)
                    {
                        [self.activity stopAnimating];
                    }
                    else
                    {
                        [self scrollToBottomAnimated:NO];
                    }
                }];
            }
}
#pragma mark - Text view delegatef

- (void)viewheightChanged:(float)height
{
    [self setValue:@(self.chatInputView.origin.y) forKeyPath:@"_inputViewY"];
}

#pragma mark PrivateAPI

- (UITableViewCell*)p_textCell_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath message:(DDMessageEntity*)message
{
    static NSString* identifier = @"DDChatTextCellIdentifier";
    DDChatBaseCell* cell = (DDChatBaseCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[DDChatTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString* myUserID = [RuntimeStatus instance].user.userId;
    if ([message.senderId isEqualToString:myUserID])
    {
        [cell setLocation:DDBubbleRight];
    }
    else
    {
        [cell setLocation:DDBubbleLeft];
    }
    [cell setContent:message];
    __weak DDChatTextCell* weakCell = (DDChatTextCell*)cell;
    cell.sendAgain = ^{
        [weakCell showSending];
        [weakCell sendTextAgain:message];
    
    };
    
    return cell;
}

- (UITableViewCell*)p_voiceCell_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath message:(DDMessageEntity*)message
{
    static NSString* identifier = @"DDVoiceCellIdentifier";
    DDChatBaseCell* cell = (DDChatBaseCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[DDChatVoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString* myUserID = [RuntimeStatus instance].user.userId;
    if ([message.senderId isEqualToString:myUserID])
    {
        [cell setLocation:DDBubbleRight];
    }
    else
    {
        [cell setLocation:DDBubbleLeft];
    }
    [cell setContent:message];
    __weak DDChatVoiceCell* weakCell = (DDChatVoiceCell*)cell;
    [(DDChatVoiceCell*)cell setTapInBubble:^{
        //播放语音
        NSString* fileName = message.msgContent;
        [[PlayerManager sharedManager] playAudioWithFileName:fileName delegate:self];
        [message.info setObject:@(1) forKey:DDVOICE_PLAYED];
        [weakCell showVoicePlayed];
        [[DDDatabaseUtil instance] updateMessageForMessage:message completion:^(BOOL result) {
            
        }];

    }];
    
    [(DDChatVoiceCell*)cell setEarphonePlay:^{
        //听筒播放
        NSString* fileName = message.msgContent;
        [[PlayerManager sharedManager] playAudioWithFileName:fileName playerType:DDEarPhone delegate:self];
        [message.info setObject:@(1) forKey:DDVOICE_PLAYED];
        [weakCell showVoicePlayed];

        [[DDDatabaseUtil instance] updateMessageForMessage:message completion:^(BOOL result) {
            
        }];

    }];
    
    [(DDChatVoiceCell*)cell setSpeakerPlay:^{
        //扬声器播放
        NSString* fileName = message.msgContent;
        [[PlayerManager sharedManager] playAudioWithFileName:fileName playerType:DDSpeaker delegate:self];
        [message.info setObject:@(1) forKey:DDVOICE_PLAYED];
        [weakCell showVoicePlayed];
        [[DDDatabaseUtil instance] updateMessageForMessage:message completion:^(BOOL result) {
            
        }];

    }];
    [(DDChatVoiceCell *)cell setSendAgain:^{
        //重发
         [weakCell showSending];
        [weakCell sendVoiceAgain:message];
    }];
    return cell;
}

- (UITableViewCell*)p_promptCell_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath message:(DDPromptEntity*)prompt
{
    static NSString* identifier = @"DDPromptCellIdentifier";
    DDPromptCell* cell = (DDPromptCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[DDPromptCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString* promptMessage = prompt.message;
    [cell setprompt:promptMessage];
    return cell;
}
- (UITableViewCell*)p_imageCell_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath message:(DDMessageEntity*)message
{
    static NSString* identifier = @"DDImageCellIdentifier";
    DDChatImageCell* cell = (DDChatImageCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[DDChatImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString* myUserID =[RuntimeStatus instance].user.userId;
    if ([message.senderId isEqualToString:myUserID])
    {
        [cell setLocation:DDBubbleRight];
    }
    else
    {
        [cell setLocation:DDBubbleLeft];
    }
    
    [cell setContent:message];
    __weak DDChatImageCell* weakCell = cell;
  
    [cell setSendAgain:^{
        [weakCell sendImageAgain:message];

    }];
    
    [cell setTapInBubble:^{
        [weakCell showPreview];
    }];
    
    [cell setPreview:cell.tapInBubble];
    
    return cell;
}

- (void)n_receiveMessage:(NSNotification*)notification
{
    if (![self.navigationController.topViewController isEqual:self])
    {
        //当前不是聊天界面直接返回
        return;
    }
    DDMessageEntity* message = [notification object];
    [AnalysisImage analysisImage:message Block:^(NSMutableArray *array) {
        for (DDMessageEntity *msg in array) {
            NSString *msgID= nil;
            if (message.msgType <5) {
                msgID = msg.sessionId;
            }else
            {
                msgID =msg.toUserID;
            }
            if ([msgID isEqualToString:self.module.sessionEntity.sessionID])
            {
                //显示消息
                [[DDSundriesCenter instance] pushTaskToParallelQueue:^{
                    msg.state=DDmessageSendSuccess;
                    [self.module addShowMessage:msg];
                    [self.module updateSessionUpdateTime:msg.msgTime];
                    [[DDDatabaseUtil instance] updateMessageForMessage:msg completion:^(BOOL result) {
                        
                    }];
                    [[DDMessageModule shareInstance] clearUnreadMessagesForSessionID:self.module.sessionEntity.sessionID];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                        [self scrollToBottomAnimated:YES];
                    });
                    if (message.msgType >5) {
                        DDGroupMsgReadACKAPI *groupACK = [[DDGroupMsgReadACKAPI alloc] init];
                        [groupACK requestWithObject:self.module.sessionEntity.sessionID Completion:^(id response, NSError *error) {
                            
                        }];
                    }else
                    {
                        DDSendMessageReadACKAPI* readACKAPI = [[DDSendMessageReadACKAPI alloc] init];
                        [readACKAPI requestWithObject:self.module.sessionEntity.sessionID Completion:^(id response, NSError *error) {
                            
                        }];
                    }
                   
                }];
            }
            else
            {
                  [self.replyView setDescriptionInfo:msg];
//                UIImage* image = [UIImage imageNamed:@"dd_has_unread_message"];
//                [_recentButton setImage:image forState:UIControlStateNormal];
//                //TODO:右上角显示有未读消息
            }
        }
    }];
    
}

- (void)n_receiveUnreadMessageUpdateNotification:(NSNotification*)notification
{
    if (![self.navigationController.topViewController isEqual:self])
    {
        //当前不是聊天界面直接返回
        return;
    }
    NSString* userID = [notification object];
    NSUInteger oldMessageCount = [self.module.showingMessages count];
    NSArray* unreadMessage = [[DDMessageModule shareInstance] popAllUnreadMessagesForSessionID:userID];
    [self.module.showingMessages addObjectsFromArray:unreadMessage];
    NSMutableArray* addIndexpaths = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < [unreadMessage count]; index ++)
    {
        [addIndexpaths addObject:[NSIndexPath indexPathForRow:oldMessageCount + index inSection:0]];
    }
    [self.tableView insertRowsAtIndexPaths:addIndexpaths withRowAnimation:UITableViewRowAnimationAutomatic];
    if (self.module.sessionEntity.sessionType == SESSIONTYPE_SINGLE) {
        DDSendMessageReadACKAPI* readACKAPI = [[DDSendMessageReadACKAPI alloc] init];
        [readACKAPI requestWithObject:self.module.sessionEntity.sessionID Completion:^(id response, NSError *error) {
            
        }];
    }else
    {
        DDGroupMsgReadACKAPI *groupReadACK = [[DDGroupMsgReadACKAPI alloc] init];
        [groupReadACK requestWithObject:self.module.sessionEntity.sessionID Completion:^(id response, NSError *error) {
            
        }];
    }
    
}

- (void)n_receiveStartLoginNotification:(NSNotification*)notification
{
    self.title = @"正在连接...";
}

- (void)n_receiveLoginSuccessNotification:(NSNotification*)notification
{
    if (self.module.sessionEntity)
        self.title = self.module.sessionEntity.name;
}

- (void)n_receiveLoginFailureNotification:(NSNotification*)notification
{
    self.title = @"未连接";
}

- (void)n_receiveUserKickoffNotification:(NSNotification*)notification
{
    if ([self.navigationController.topViewController isEqual:self])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您的帐号在别处登录" delegate:self cancelButtonTitle:nil otherButtonTitles:@"重连", nil];
        [alert show];
    }
}

- (void)p_clickThRecordButton:(UIButton*)button
{
    switch (button.tag) {
        case DDVoiceInput:
            //开始录音
            [self p_hideBottomComponent];
            [button setImage:[UIImage imageNamed:@"dd_input_normal"] forState:UIControlStateNormal];
            button.tag = DDTextInput;
            [self.chatInputView willBeginRecord];
            [self.chatInputView.textView resignFirstResponder];
            _currentInputContent = self.chatInputView.textView.text;
            if ([_currentInputContent length] > 0)
            {
                [self.chatInputView.textView setText:nil];
            }
            break;
        case DDTextInput:
            //开始输入文字
            [button setImage:[UIImage imageNamed:@"dd_record_normal"] forState:UIControlStateNormal];
            button.tag = DDVoiceInput;
            [self.chatInputView willBeginInput];
            if ([_currentInputContent length] > 0)
            {
                [self.chatInputView.textView setText:_currentInputContent];
            }
            [self.chatInputView.textView becomeFirstResponder];
            break;
    }
}

- (void)p_record:(UIButton*)button
{
    [self.chatInputView.recordButton setHighlighted:YES];
    if (![[self.view subviews] containsObject:_recordingView])
    {
        [self.view addSubview:_recordingView];
    }
    [_recordingView setHidden:NO];
    [_recordingView setRecordingState:DDShowVolumnState];
    [[RecorderManager sharedManager] setDelegate:self];
    [[RecorderManager sharedManager] startRecording];
    DDLog(@"record");
}

- (void)p_willCancelRecord:(UIButton*)button
{
    [_recordingView setHidden:NO];
    [_recordingView setRecordingState:DDShowCancelSendState];
    DDLog(@"will cancel record");
}

- (void)p_cancelRecord:(UIButton*)button
{
    [self.chatInputView.recordButton setHighlighted:NO];
    [_recordingView setHidden:YES];
    [[RecorderManager sharedManager] cancelRecording];
    DDLog(@"cancel record");
}

- (void)p_sendRecord:(UIButton*)button
{
    [self.chatInputView.recordButton setHighlighted:NO];
    [[RecorderManager sharedManager] stopRecording];
    DDLog(@"send record");
}


- (void)p_endCancelRecord:(UIButton*)button
{
    [_recordingView setHidden:NO];
    [_recordingView setRecordingState:DDShowVolumnState];
}

- (void)p_tapOnTableView:(UIGestureRecognizer*)sender
{
    if (_bottomShowComponent)
    {
        [self p_hideBottomComponent];
    }
}

- (void)p_hideBottomComponent
{
    _bottomShowComponent = _bottomShowComponent & 0;
    //隐藏所有
    [self.chatInputView.textView resignFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        [self.ddUtility.view setFrame:DDCOMPONENT_BOTTOM];
        [self.emotions.view setFrame:DDCOMPONENT_BOTTOM];
        
        [self.chatInputView setFrame:DDINPUT_BOTTOM_FRAME];
    }];
    DDLog(@"%@",NSStringFromCGRect(DDINPUT_BOTTOM_FRAME));
    [self setValue:@(self.chatInputView.origin.y) forKeyPath:@"_inputViewY"];
}

- (void)p_enableChatFunction
{
    [self.chatInputView setUserInteractionEnabled:YES];
}

- (void)p_unableChatFunction
{
    [self.chatInputView setUserInteractionEnabled:NO];
}

#pragma mark -
#pragma mark DDEmotionViewCOntroller Delegate
- (void)emotionViewClickSendButton
{
    [self textViewEnterSend];
}


- (void)recordingTimeout
{
    
}

- (void)recordingStopped  //录音机停止采集声音
{
    
}

- (void)recordingFailed:(NSString *)failureInfoString
{
    
}

- (void)levelMeterChanged:(float)levelMeter
{
    [_recordingView setVolume:levelMeter];
}
#pragma mark -
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"sessionEntity.sessionID"]) {
        if ([change objectForKey:@"new"] !=nil) {
            self.title=self.module.sessionEntity.name;
        }
    }
    if ([keyPath isEqualToString:@"showingMessages"]) {
 
        [self.tableView reloadData];
    }
    if ([keyPath isEqualToString:@"_inputViewY"])
    {
        if (![change[@"new"] isEqualToNumber:change[@"old"]]) {
            float maxY = self.view.height - DDINPUT_MIN_HEIGHT;
            float gap = maxY - _inputViewY;
            [UIView animateWithDuration:0.25 animations:^{
                _tableView.contentInset = UIEdgeInsetsMake(_tableView.contentInset.top, 0, gap, 0);
                _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, gap, 0);
            }];
            [self scrollToBottomAnimated:YES];
        }
        
    }
    
}
@end

@implementation ChattingMainViewController(ChattingInput)

- (void)initialInput
{
    CGRect inputFrame = CGRectMake(0, CONTENT_HEIGHT - DDINPUT_MIN_HEIGHT + NAVBAR_HEIGHT,FULL_WIDTH,DDINPUT_MIN_HEIGHT);
    self.chatInputView = [[JSMessageInputView alloc] initWithFrame:inputFrame delegate:self];
    [self.chatInputView setBackgroundColor:RGB(249, 249, 249)];
    [self.view addSubview:self.chatInputView];
    [self.chatInputView.emotionbutton addTarget:self
                      action:@selector(showEmotions:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.chatInputView.showUtilitysbutton addTarget:self
                           action:@selector(showUtilitys:)
                 forControlEvents:UIControlEventTouchDown];
    
    [self.chatInputView.voiceButton addTarget:self
                      action:@selector(p_clickThRecordButton:)
            forControlEvents:UIControlEventTouchUpInside];


    _touchDownGestureRecognizer = [[TouchDownGestureRecognizer alloc] initWithTarget:self action:nil];
    __weak ChattingMainViewController* weakSelf = self;
    _touchDownGestureRecognizer.touchDown = ^{
        [weakSelf p_record:nil];
    };
    
    _touchDownGestureRecognizer.moveInside = ^{
        [weakSelf p_endCancelRecord:nil];
    };
    
    _touchDownGestureRecognizer.moveOutside = ^{
        [weakSelf p_willCancelRecord:nil];
    };
    
    _touchDownGestureRecognizer.touchEnd = ^(BOOL inside){
        if (inside)
        {
            [weakSelf p_sendRecord:nil];
        }
        else
        {
            [weakSelf p_cancelRecord:nil];
        }
    };
    [self.chatInputView.recordButton addGestureRecognizer:_touchDownGestureRecognizer];
    _recordingView = [[RecordingView alloc] initWithState:DDShowVolumnState];
    [_recordingView setHidden:YES];
    [_recordingView setCenter:CGPointMake(self.view.centerX, self.view.centerY)];
    [self addObserver:self forKeyPath:@"_inputViewY" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

-(IBAction)showUtilitys:(id)sender
{
    [_recordButton setImage:[UIImage imageNamed:@"dd_record_normal"] forState:UIControlStateNormal];
    _recordButton.tag = DDVoiceInput;
    [self.chatInputView willBeginInput];
    if ([_currentInputContent length] > 0)
    {
        [self.chatInputView.textView setText:_currentInputContent];
    }
    
    if (self.ddUtility == nil)
    {
        self.ddUtility = [ChatUtilityViewController new];
        [self addChildViewController:self.ddUtility];
        self.ddUtility.view.frame=CGRectMake(0, self.view.size.height,320 , 280);
        [self.view addSubview:self.ddUtility.view];
    }
    
    if (_bottomShowComponent & DDShowKeyboard)
    {
        //显示的是键盘,这是需要隐藏键盘，显示插件，不需要动画
        _bottomShowComponent = (_bottomShowComponent & 0) | DDShowUtility;
        [self.chatInputView.textView resignFirstResponder];
        [self.ddUtility.view setFrame:DDUTILITY_FRAME];
        [self.emotions.view setFrame:DDCOMPONENT_BOTTOM];
    }
    else if (_bottomShowComponent & DDShowUtility)
    {
        //插件面板本来就是显示的,这时需要隐藏所有底部界面
        [self p_hideBottomComponent];
        _bottomShowComponent = _bottomShowComponent & DDHideUtility;
    }
    else if (_bottomShowComponent & DDShowEmotion)
    {
        //显示的是表情，这时需要隐藏表情，显示插件
        [self.emotions.view setFrame:DDCOMPONENT_BOTTOM];
        [self.ddUtility.view setFrame:DDUTILITY_FRAME];
        _bottomShowComponent = (_bottomShowComponent & DDHideEmotion) | DDShowUtility;
    }
    else
    {
        //这是什么都没有显示，需用动画显示插件
        _bottomShowComponent = _bottomShowComponent | DDShowUtility;
        [UIView animateWithDuration:0.25 animations:^{
            [self.ddUtility.view setFrame:DDUTILITY_FRAME];
            [self.chatInputView setFrame:DDINPUT_TOP_FRAME];
        }];
        [self setValue:@(DDINPUT_TOP_FRAME.origin.y) forKeyPath:@"_inputViewY"];

    }
    
}

-(IBAction)showEmotions:(id)sender
{
    [_recordButton setImage:[UIImage imageNamed:@"dd_record_normal"] forState:UIControlStateNormal];
    _recordButton.tag = DDVoiceInput;
    [self.chatInputView willBeginInput];
    if ([_currentInputContent length] > 0)
    {
        [self.chatInputView.textView setText:_currentInputContent];
    }
    
    if (self.emotions == nil) {
        self.emotions = [EmotionsViewController new];
        [self.emotions.view setBackgroundColor:[UIColor darkGrayColor]];
        self.emotions.view.frame=DDCOMPONENT_BOTTOM;
        self.emotions.delegate = self;
        [self.view addSubview:self.emotions.view];
    }
    if (_bottomShowComponent & DDShowKeyboard)
    {
        //显示的是键盘,这是需要隐藏键盘，显示表情，不需要动画
        _bottomShowComponent = (_bottomShowComponent & 0) | DDShowEmotion;
        [self.chatInputView.textView resignFirstResponder];
        [self.emotions.view setFrame:DDEMOTION_FRAME];
        [self.ddUtility.view setFrame:DDCOMPONENT_BOTTOM];
    }
    
    else if (_bottomShowComponent & DDShowUtility)
    {
        //显示的是插件，这时需要隐藏插件，显示表情
        [self.ddUtility.view setFrame:DDCOMPONENT_BOTTOM];
        [self.emotions.view setFrame:DDEMOTION_FRAME];
        _bottomShowComponent = (_bottomShowComponent & DDHideUtility) | DDShowEmotion;
    }
    else
    {
        //这是什么都没有显示，需用动画显示表情
        _bottomShowComponent = _bottomShowComponent | DDShowEmotion;
        [UIView animateWithDuration:0.25 animations:^{
            [self.emotions.view setFrame:DDEMOTION_FRAME];
            [self.chatInputView setFrame:DDINPUT_TOP_FRAME];
        }];
        [self setValue:@(DDINPUT_TOP_FRAME.origin.y) forKeyPath:@"_inputViewY"];
    }
}
#pragma mark - KeyBoardNotification
- (void)handleWillShowKeyboard:(NSNotification *)notification
{
    CGRect keyboardRect;
    keyboardRect = [(notification.userInfo)[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    _bottomShowComponent = _bottomShowComponent | DDShowKeyboard;
    //什么都没有显示
    [UIView animateWithDuration:0.25 animations:^{
        [self.chatInputView setFrame:CGRectMake(0, keyboardRect.origin.y - DDINPUT_HEIGHT, self.view.size.width, DDINPUT_HEIGHT)];
    }];
    [self setValue:@(keyboardRect.origin.y - DDINPUT_HEIGHT) forKeyPath:@"_inputViewY"];

}

- (void)handleWillHideKeyboard:(NSNotification *)notification
{
    CGRect keyboardRect;
    keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    _bottomShowComponent = _bottomShowComponent & DDHideKeyboard;
    if (_bottomShowComponent & DDShowUtility)
    {
        //显示的是插件
        [UIView animateWithDuration:0.25 animations:^{
            [self.chatInputView setFrame:DDINPUT_TOP_FRAME];
        }];
        [self setValue:@(self.chatInputView.origin.y) forKeyPath:@"_inputViewY"];
    }
    else if (_bottomShowComponent & DDShowEmotion)
    {
        //显示的是表情
        [UIView animateWithDuration:0.25 animations:^{
            [self.chatInputView setFrame:DDINPUT_TOP_FRAME];
        }];
        [self setValue:@(self.chatInputView.origin.y) forKeyPath:@"_inputViewY"];

    }
    else
    {
        [self p_hideBottomComponent];
    }
}
@end
