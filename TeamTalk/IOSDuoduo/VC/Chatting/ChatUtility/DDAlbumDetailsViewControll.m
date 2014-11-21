//
//  DDAlbumDetailsViewControllViewController.m
//  IOSDuoduo
//
//  Created by 东邪 on 14-6-4.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDAlbumDetailsViewControll.h"
#import "ImageGridViewCell.h"
#import "ChattingMainViewController.h"
#import "AlbumDetailsBottomBar.h"
#import "DDSendPhotoMessageAPI.h"
#import "Photo.h"
#import "DDDatabaseUtil.h"
#import "std.h"
#import "MWCommon.h"
#import "MBProgressHUD.h"
#import "PhotosCache.h"
#import "DDMessageSendManager.h"
#import "ImagesPreviewViewController.h"
@interface DDAlbumDetailsViewControll ()

@end

@implementation DDAlbumDetailsViewControll

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
    self.title=@"预览";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.gridView = [[AQGridView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-45)];
    self.gridView.delegate = self;
	self.gridView.dataSource = self;
    [self.view addSubview:self.gridView];
    self.assetsArray = [NSMutableArray new];
    self.choosePhotosArray = [NSMutableArray new];
    [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result) {
            [_assetsArray addObject:result];
            
        }
        if (stop)
        {
            [self.gridView reloadData];
        }
    }];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(backToRoot)];
    self.navigationItem.rightBarButtonItem=item;
    self.bar = [[AlbumDetailsBottomBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-45, 320, 45)];
    __weak typeof(self) weakSelf = self;
    self.bar.Block=^(int buttonIndex){
        if (buttonIndex == 0) {
            if ([weakSelf.choosePhotosArray count] == 0) {
                return ;
            }
            ImagesPreviewViewController *photoPreview = [ImagesPreviewViewController new];
            photoPreview.imageArray=weakSelf.choosePhotosArray;
            //            [TheAppDel.navigationController pushViewController:photoPreview animated:YES];
#warning 处理跳转
            [weakSelf.navigationController pushViewController:photoPreview  animated:YES];
            
        }else
        {
            //send picture
            if ([weakSelf.choosePhotosArray count] >0) {
                MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:weakSelf.view];
                [weakSelf.view addSubview:HUD];
                
                HUD.dimBackground = YES;
                HUD.labelText = @"正在发送";
                
                [HUD showAnimated:YES whileExecutingBlock:^{
                    for (int i = 0; i<[weakSelf.choosePhotosArray count]; i++) {
                        Photo *photo = [Photo new];
                        ALAsset *asset = [weakSelf.choosePhotosArray objectAtIndex:i];
                        ALAssetRepresentation* representation = [asset defaultRepresentation];
                        NSURL* url = [representation url];
                        photo.localPath=url.absoluteString;
                        UIImage *image = nil;
                        if (representation == nil) {
                            CGImageRef thum = [asset aspectRatioThumbnail];
                            image = [[UIImage alloc]initWithCGImage:thum];
                        }else
                        {
                            image =[[UIImage alloc]initWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                        }
                        NSString *keyName = [[PhotosCache sharedPhotoCache] getKeyName];
                        
                        photo.localPath=keyName;
                        [[ChattingMainViewController shareInstance] sendImageMessage:photo Image:image];
                    }
                    
                } completionBlock:^{
                    [HUD removeFromSuperview];
                    [weakSelf.navigationController popToViewController:[ChattingMainViewController shareInstance] animated:YES];
                }];
            }
        }
    };
    [self.view addSubview:self.bar];
    // Do any additional setup after loading the view.
    [self.gridView scrollToItemAtIndex:[self.assetsArray count] atScrollPosition:AQGridViewScrollPositionBottom animated:NO];
}

- (void)dealloc
{
    self.choosePhotosArray =nil;
    self.gridView=nil;
    self.assetsArray=nil;
    self.bar= nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        [self.tabBarController.tabBar setHidden:YES];
}
-(void)backToRoot
{
#warning 处理跳转
    
    //    [TheAppDel.navigationController popToViewController:[DDChattingMainViewController shareInstance] animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSUInteger) numberOfItemsInGridView: (AQGridView *) gridView
{
    return  [self.assetsArray count];
}
- (AQGridViewCell *) gridView: (AQGridView *) aGridView cellForItemAtIndex: (NSUInteger) index
{
    static NSString * PlainCellIdentifier = @"PlainCellIdentifier";
    
    ImageGridViewCell * cell = (ImageGridViewCell *)[self.gridView dequeueReusableCellWithIdentifier: PlainCellIdentifier];
	if ( cell == nil )
	{
		cell = [[ImageGridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 75.0, 75.0) reuseIdentifier: PlainCellIdentifier];
        
	}
    cell.isShowSelect=YES;
    cell.selectionGlowColor=[UIColor clearColor];
    ALAsset *asset = [self.assetsArray objectAtIndex:index];
    
    CGImageRef thum = [asset thumbnail];
    UIImage* ti = [UIImage imageWithCGImage:thum];
	cell.image = ti;
    cell.tag=index;
    if ([self.choosePhotosArray containsObject:asset]) {
        [cell setCellIsToHighlight:YES];
    }else
    {
        [cell setCellIsToHighlight:NO];
    }
    return cell ;
}
- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
    [gridView deselectItemAtIndex:index animated:YES];
    
    ALAsset *asset = [self.assetsArray objectAtIndex:index];
    ImageGridViewCell *cell =(ImageGridViewCell *) [self.gridView cellForItemAtIndex:index];
    if ([self.choosePhotosArray containsObject:asset]) {
        [cell setCellIsToHighlight:NO];
        [self.choosePhotosArray removeObject:asset];
    }else{
        if ([self.choosePhotosArray count] == 10) {
            return;
        }
        [cell setCellIsToHighlight:YES];
        [self.choosePhotosArray addObject:asset];
    }
    [self.bar setSendButtonTitle:[self.choosePhotosArray count]];
    
}
- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) gridView
{
    return CGSizeMake(75, 80);
}
@end
