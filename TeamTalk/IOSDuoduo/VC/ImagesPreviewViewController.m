//
//  DDImagesPreviewViewController.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-06-11.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "ImagesPreviewViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "Photo.h"
#import "DDDatabaseUtil.h"
#import "DDSendPhotoMessageAPI.h"
#import "ChattingMainViewController.h"
#import "DDMessageSendManager.h"
#import "std.h"
#import <objc/runtime.h>
#import "MWCommon.h"
#import "PhotosCache.h"
#import "MBProgressHUD.h"
@interface MWPhoto (MyMWPhoto)
@property(nonatomic,strong)id isSelected;
@property(nonatomic,strong)NSString *alassetUrl;
@end

@implementation MWPhoto (MyMWPhoto)
-(NSString *)alassetUrl
{
    return objc_getAssociatedObject(self, @selector(alassetUrl));
}
-(void)setAlassetUrl:(NSString *)alassetUrl
{
    objc_setAssociatedObject(self, @selector(alassetUrl),
                             alassetUrl,
                             OBJC_ASSOCIATION_RETAIN);
}
- (id)isSelected {
    return objc_getAssociatedObject(self, @selector(isSelected));
}
-(void)setIsSelected:(id)isSelected
{
    objc_setAssociatedObject(self, @selector(isSelected),
                             isSelected,
                             OBJC_ASSOCIATION_RETAIN);
}


@end
@interface ImagesPreviewViewController ()
@property(nonatomic,strong)NSMutableArray *photos;
@property(nonatomic,strong) MWPhotoBrowser *photoBrowser;
@property(nonatomic,strong)UIButton *button;
@end
@implementation ImagesPreviewViewController
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
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    
    MWPhoto *photo =[_photos objectAtIndex:index];
    photo.isSelected=[NSNumber numberWithBool:selected];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
    [self setSendButtonTitle];
}
- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    MWPhoto *photo =[_photos objectAtIndex:index];
    return [photo.isSelected boolValue];
}
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor blackColor];
    self.photoBrowser = [[MWPhotoBrowser alloc] init];
    self.photoBrowser.view.frame=self.view.frame;
    self.photoBrowser.displayActionButton = NO;
    self.photoBrowser.displayNavArrows = NO;
    self.photoBrowser.wantsFullScreenLayout = YES;
    self.photoBrowser.delayToHideElements=4;
    self.photoBrowser.zoomPhotosToFill = YES;
    self.photoBrowser.displaySelectionButtons = YES;
    self.photoBrowser.delegate=self;
    [self.photoBrowser setCurrentPhotoIndex:0];
    [self.view addSubview:self.photoBrowser.view];
    self.photos = [NSMutableArray new];
    for (int i =0; i<[self.imageArray count]; i++) {
        ALAsset *result = [self.imageArray objectAtIndex:i];
        ALAssetRepresentation* representation = [result defaultRepresentation];
        if (representation == nil) {
            CGImageRef ref = [result thumbnail];
            
            UIImage *img = [[UIImage alloc]initWithCGImage:ref];
            
            MWPhoto *photo =[MWPhoto photoWithImage:img];
            photo.alassetUrl=@" ";
            photo.isSelected=[NSNumber numberWithBool:YES];
            [self.photos addObject:photo];
        }else
        {
            NSURL* url = [representation url];
            CGImageRef ref = [[result defaultRepresentation] fullScreenImage];
            
            UIImage *img = [[UIImage alloc]initWithCGImage:ref];
            
            MWPhoto *photo =[MWPhoto photoWithImage:img];
            photo.alassetUrl=url.absoluteString;
            photo.isSelected=[NSNumber numberWithBool:YES];
            [self.photos addObject:photo];
        }
        
    }
    [self.photoBrowser reloadData];
    UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50, 320, 50)];
    [toolView setBackgroundColor:RGBA(0, 0, 0, 0.7)];
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setBackgroundColor:[UIColor clearColor]];
    [self.button setTitle:[NSString stringWithFormat:@"发送(%d)",[self.photos count]] forState:UIControlStateNormal];
    [self.button setTitle:[NSString stringWithFormat:@"发送(%d)",[self.photos count]] forState:UIControlStateSelected];
    [self.button setBackgroundImage:[UIImage imageNamed:@"dd_image_send"] forState:UIControlStateNormal];
    [self.button setBackgroundImage:[UIImage imageNamed:@"dd_image_send"] forState:UIControlStateSelected];
    
    [self.button addTarget:self action:@selector(sendPhotos:) forControlEvents:UIControlEventTouchUpInside];
    NSString *string = [NSString stringWithFormat:@"%@",self.button.titleLabel.text];
    CGSize feelSize = [string sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(190,0)];
    float  feelWidth = feelSize.width;
    self.button.frame=CGRectMake(225, 5, feelWidth+25, 35);
    [toolView addSubview:self.button];
    [self.view addSubview:toolView];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"dd_image_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goToBack) forControlEvents:UIControlEventTouchUpInside];
    float topviewY =self.photoBrowser.topview.frame.origin.y;
    backButton.frame=CGRectMake(0, (SYSTEM_VERSION_LESS_THAN(@"7")?topviewY+19:topviewY), 50, 45);
    [self.photoBrowser.view addSubview:backButton];
    
    // Do any additional setup after loading the view.
}
-(void)setSendButtonTitle
{
    int j = 0;
    for (int i = 0; i<[self.photos count]; i++) {
        MWPhoto *newPhoto = [self.photos objectAtIndex:i];
        if ([newPhoto.isSelected boolValue]) {
            j++;
        }
    }
    [self.button setTitle:[NSString stringWithFormat:@"发送( %d )",j] forState:UIControlStateNormal];
    
}
-(void)goToBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)sendPhotos:(id)sender
{
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.dimBackground = YES;
    HUD.labelText = @"正在发送";
    
    [HUD showAnimated:YES whileExecutingBlock:^{
        for (int i = 0; i<[self.photos count]; i++) {
            MWPhoto *newPhoto = [self.photos objectAtIndex:i];
            if ([newPhoto.isSelected boolValue]) {
                Photo *photo = [Photo new];
                NSString *keyName = [[PhotosCache sharedPhotoCache] getKeyName];
                NSData *photoData = UIImagePNGRepresentation(newPhoto.image);
                [[PhotosCache sharedPhotoCache] storePhoto:photoData forKey:keyName toDisk:YES];
                photo.localPath=keyName;
                photo.image=newPhoto.image;
                [[ChattingMainViewController shareInstance] sendImageMessage:photo Image:photo.image];
                
            }
        }
    } completionBlock:^{
        [HUD removeFromSuperview];
        [self.navigationController popToViewController:[ChattingMainViewController shareInstance] animated:YES];
    }];
    
    
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
