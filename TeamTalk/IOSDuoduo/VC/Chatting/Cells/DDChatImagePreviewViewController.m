//
//  DDChatImagePreviewViewController.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-06-11.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "DDChatImagePreviewViewController.h"
@interface DDChatImagePreviewViewController ()
@property(nonatomic,strong)MWPhotoBrowser *browser ;
@end

@implementation DDChatImagePreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title=@"预览";
    self.view.backgroundColor=[UIColor whiteColor];
    self.browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    self.browser.displayActionButton = NO;
    self.browser.displayNavArrows = NO;
    self.browser.wantsFullScreenLayout = YES;
    self.browser.zoomPhotosToFill = YES;
    [self.browser setCurrentPhotoIndex:0];
    [self.view addSubview:self.browser.view];
    
    // Do any additional setup after loading the view.
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    
    return [self.photos count];
}
- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
