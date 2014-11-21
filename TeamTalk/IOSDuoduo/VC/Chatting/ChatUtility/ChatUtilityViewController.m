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
    [gridView deselectItemAtIndex:index animated:YES];
	UtililyItemCell * cell = (UtililyItemCell *)[self.gridView cellForItemAtIndex: index];
	if ([cell.title.text isEqualToString:@"拍摄"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            self.imagePicker.wantsFullScreenLayout=YES;
            [[ChattingMainViewController shareInstance].navigationController presentViewController:self.imagePicker animated:NO completion:nil];
        });
       
    }else if ([cell.title.text isEqualToString:@"照片"])
    {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                [self.navigationController pushViewController:[AlbumViewController new] animated:YES];
        
    }
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
      self.imagePicker=nil;
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
        UIImage *image = [self scaleImage:theImage toScale:0.3];
        NSData *imageData = UIImageJPEGRepresentation(image, (CGFloat)1.0);
        UIImage * m_selectImage = [UIImage imageWithData:imageData];
            __block Photo *photo = [Photo new];
            NSString *keyName = [[PhotosCache sharedPhotoCache] getKeyName];
            photo.localPath=keyName;
        [picker dismissViewControllerAnimated:NO completion:nil];
        self.imagePicker=nil;
            [[ChattingMainViewController shareInstance] sendImageMessage:photo Image:m_selectImage];
        
        
    }

}
#pragma mark -
#pragma mark 等比縮放image
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize, image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
