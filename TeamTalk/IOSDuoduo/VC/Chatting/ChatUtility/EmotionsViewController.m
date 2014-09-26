//
//  DDEmotionsViewController.m
//  IOSDuoduo
//
//  Created by 东邪 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "EmotionsViewController.h"
#import "ChattingMainViewController.h"
#import "std.h"
@interface EmotionsViewController ()

- (void)clickTheSendButton:(id)sender;

@end
#define  keyboardHeight 216
#define  facialViewWidth 300
#define facialViewHeight 170
#define  DD_EMOTION_MENU_HEIGHT             50
@implementation EmotionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame=CGRectMake(0, 0, 320, 216);
    if (self.scrollView==nil) {
        self.scrollView=[[UIScrollView alloc] initWithFrame:self.view.frame];
        [self.scrollView setBackgroundColor:RGB(224, 224, 224)];
        for (int i=0; i<2; i++) {
            EmojiFaceView *fview=[[EmojiFaceView alloc] initWithFrame:CGRectMake(12+320*i, 15, facialViewWidth, facialViewHeight)];
            [fview setBackgroundColor:[UIColor clearColor]];
            [fview loadFacialView:i size:CGSizeMake(42, 42)];
            fview.delegate=self;
            [self.scrollView addSubview:fview];
        }
    }
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    self.scrollView.contentSize=CGSizeMake(320*2, keyboardHeight);
    self.scrollView.pagingEnabled=YES;
    self.scrollView.delegate=self;
    [self.view addSubview:self.scrollView];
    
    self.pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(85, self.view.frame.size.height-30 - DD_EMOTION_MENU_HEIGHT, 150, 30)];
    [self.pageControl setCurrentPage:0];
    self.pageControl.pageIndicatorTintColor=[UIColor whiteColor];
    self.pageControl.currentPageIndicatorTintColor=RGB(245, 62, 102);
    self.pageControl.numberOfPages = 2;
    [self.pageControl setBackgroundColor:[UIColor clearColor]];
    [self.pageControl addTarget:self action:@selector(changePage:)forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.pageControl];
    
    UIView* menuView = [[UIView alloc] initWithFrame:CGRectMake(0, keyboardHeight - DD_EMOTION_MENU_HEIGHT, 320, DD_EMOTION_MENU_HEIGHT)];
    [menuView setBackgroundColor:RGB(249, 249, 249)];
    UIButton* sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton addTarget:self action:@selector(clickTheSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [sendButton setFrame:CGRectMake(238, 11, 72, 28)];
    UIImage* backgroundImage = [UIImage imageNamed:@"dd_image_send"];
    [sendButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [menuView addSubview:sendButton];
    [self.view addSubview:menuView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    int page = self.scrollView.contentOffset.x / 320;
    self.pageControl.currentPage = page;
}
-(void)selectedFacialView:(NSString*)str
{
    if ([str isEqualToString:@"delete"]) {
        [[ChattingMainViewController shareInstance] deleteEmojiFace];
        return;
    }
    [[ChattingMainViewController shareInstance] insertEmojiFace:str];
}
- (IBAction)changePage:(id)sender {
    int page = self.pageControl.currentPage;
    [self.scrollView setContentOffset:CGPointMake(320 * page, 0)];
}

#pragma mark - privateAPI
- (void)clickTheSendButton:(id)sender
{
    if (self.delegate)
    {
        [self.delegate emotionViewClickSendButton];
    }
}
@end
