//
//  DDDDChatUtilityViewController.m
//  IOSDuoduo
//
//  Created by 东邪 on 14-5-23.
//  Copyright (c) 2014年 dujia. All rights reserved.
//
static NSString * const ItemCellIdentifier = @"ItemCellIdentifier";
#import "ChatUtilityViewController.h"
#import "UtililyItemCell.h"
#import "AQGridView.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "ChattingMainViewController.h"
#import "ChatUtilityItem.h"
#import "AlbumViewController.h"
#import "DDSendPhotoMessageAPI.h"
#import "ChattingMainViewController.h"
#import "DDMessageSendManager.h"
#import "DDDatabaseUtil.h"
#import "SDImageCache.h"
#import "std.h"
#import "DDAppDelegate.h"
#import "PhotosCache.h"
@interface ChatUtilityViewController ()
@property(nonatomic,strong)NSArray *itemsArray;
@end

@implementation ChatUtilityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.animation = AnimationSlideVertical;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    ChatUtilityItem *item1 = [ChatUtilityItem new];
    item1.itemName=@"拍摄";
    item1.itemLogo=@"dd_take-photo";
    ChatUtilityItem *item2 = [ChatUtilityItem new];
    item2.itemName=@"照片";
    item2.itemLogo=@"dd_album";
    self.itemsArray =@[item1,item2];
    self.gridView =[[AQGridView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    [self.view addSubview:self.gridView];
    
    self.gridView.delegate = self;
	self.gridView.dataSource = self;
    [self.gridView reloadData];
    self.view.backgroundColor=RGB(224, 224, 224);
    // Do any additional setup after loading the view from its nib.
}
- (void) viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    self.gridView = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    
}
#pragma mark AQGridViewControll Delegate
- (NSUInteger) numberOfItemsInGridView: (AQGridView *) gridView
{
    return  [self.itemsArray count];
}
- (AQGridViewCell *) gridView: (AQGridView *) aGridView cellForItemAtIndex: (NSUInteger) index
{
    static NSString * PlainCellIdentifier = @"PlainCellIdentifier";
    
    UtililyItemCell * cell = (UtililyItemCell *)[self.gridView dequeueReusableCellWithIdentifier: PlainCellIdentifier];
    if ( cell == nil )
    {
        cell = [[UtililyItemCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 55.0, 55.0) reuseIdentifier: PlainCellIdentifier] ;
        // cell.selectionGlowColor = [UIColor purpleColor];
    }
    ChatUtilityItem *item =[self.itemsArray objectAtIndex: index];
    cell.icon.image = [UIImage imageNamed: item.itemLogo];
    cell.title.text=item.itemName;
    return cell;
}
- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.delegate = self;
    [gridView deselectItemAtIndex:index animated:YES];
	UtililyItemCell * cell = (UtililyItemCell *)[self.gridView cellForItemAtIndex: index];
	if ([cell.title.text isEqualToString:@"拍摄"]) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        self.imagePicker.allowsEditing=NO;
        self.imagePicker.wantsFullScreenLayout=YES;
        self.imagePicker.allowsEditing = YES;
        [self.navigationController presentViewController:self.imagePicker animated:YES completion:^{
        }];
    }else if ([cell.title.text isEqualToString:@"照片"])
    {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        self.imagePicker.allowsEditing = YES;
                [self.navigationController pushViewController:[AlbumViewController new] animated:YES];
        
    }
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"Picker returned successfully.");
    NSLog(@"%@", info);
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:( NSString *)kUTTypeImage]){
        __block UIImage *theImage = nil;
        if ([picker allowsEditing]){
            theImage = [info objectForKey:UIImagePickerControllerEditedImage];
        } else {
            theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            
        }
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary writeImageToSavedPhotosAlbum:[theImage CGImage] orientation:(ALAssetOrientation)theImage.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
            NSLog(@"pickImage======%@",[assetURL absoluteString]);
            Photo *photo = [Photo new];
            NSString *keyName = [[PhotosCache sharedPhotoCache] getKeyName];
            NSData *photoData = UIImagePNGRepresentation(theImage);
            [[PhotosCache sharedPhotoCache] storePhoto:photoData forKey:keyName toDisk:YES];
            photo.localPath=keyName;
            [[ChattingMainViewController shareInstance] sendImageMessage:photo];
        }];
        
    }
    [picker dismissModalViewControllerAnimated:YES];
}
- (void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
    if (paramError == nil){
        NSLog(@"Image was saved successfully.");
    } else {
        NSLog(@"An error happened while saving the image.");
        NSLog(@"Error = %@", paramError);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
