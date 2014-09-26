//
//  DDChatImageCell.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-06-09.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "DDChatImageCell.h"
#import "UIImageView+WebCache.h"
#import "DDChatImagePreviewViewController.h"
#import "UIView+DDAddition.h"
#import "NSDictionary+JSON.h"
#import "PhotosCache.h"
#import "DDAppDelegate.h"
#import "DDDatabaseUtil.h"
#import "DDMessageSendManager.h"
#import "DDSendPhotoMessageAPI.h"
@implementation DDChatImageCell
{
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.imgView =[[UIImageView alloc] init];
        self.imgView.userInteractionEnabled=NO;
        [self.imgView setClipsToBounds:YES];
        [self.imgView setContentMode:UIViewContentModeScaleAspectFill];
        [self.contentView addSubview:self.imgView];
        self.photos = [NSMutableArray new];
    }
    return self;
}
-(void)showPreview
{
    [self.photos removeAllObjects];
    [self.photos addObject:[MWPhoto photoWithImage:self.imgView.image]];
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = NO;
    browser.displayNavArrows = NO;
    browser.wantsFullScreenLayout = YES;
    browser.zoomPhotosToFill = YES;
    [browser setCurrentPhotoIndex:0];
    DDChatImagePreviewViewController *preViewControll = [DDChatImagePreviewViewController new];
    preViewControll.photos=self.photos;
    #warning 处理跳转
    [TheAppDel.nv pushViewController:preViewControll animated:YES];
}

- (void)setContent:(DDMessageEntity*)content
{
    
    [super setContent:content];
    NSDictionary* messageContent = [NSDictionary initWithJsonString:content.msgContent];
    if (!messageContent)
    {
        NSString* urlString = content.msgContent;
        urlString = [urlString stringByReplacingOccurrencesOfString:DD_MESSAGE_IMAGE_PREFIX withString:@""];
        urlString = [urlString stringByReplacingOccurrencesOfString:DD_MESSAGE_IMAGE_SUFFIX withString:@""];
        NSURL* url = [NSURL URLWithString:urlString];
        [self.imgView setImageWithURL:url placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            
        }];
        return;
    }
    if (messageContent[DD_IMAGE_LOCAL_KEY])
    {
        //加载本地图片
        NSString* localPath = messageContent[DD_IMAGE_LOCAL_KEY];
        NSData* data = [[PhotosCache sharedPhotoCache] photoFromDiskCacheForKey:localPath];
        UIImage *image = [[UIImage alloc] initWithData:data];
        [self.imgView setImage:image];
    }
    else{
        //加载服务器上的图片
        NSString* url = messageContent[DD_IMAGE_URL_KEY];
        __weak DDChatImageCell* weakSelf = self;
        [self.imgView setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            [weakSelf.imgView setImage:image];
        }];
    }
//dujia：以下代码会让TableView很卡
//    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
//    
//    {
//        
//        ALAssetRepresentation *rep = [myasset defaultRepresentation];
//        
//        CGImageRef iref = [rep fullResolutionImage];
//        
//        if (iref) {
//            UIImage *image = [UIImage imageWithCGImage:iref];
//            [self.imgView setImage:image];
//            
//           
//        }
//        
//    };
//    
//    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
//    
//    {
//        NSLog(@"cant get image - %@",[myerror localizedDescription]);
//        
//    };
//    
//    NSURL *asseturl = [NSURL URLWithString:content.msgContent];
//    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
//    [assetslibrary assetForURL:asseturl
//                   resultBlock:resultblock
//                  failureBlock:failureblock];
}
#pragma mark -
#pragma mark DDChatCellProtocol Protocol
- (CGSize)sizeForContent:(DDMessageEntity*)content
{
//    float leigth =180;
//    float width = 170;
    float height = 127;
    float width = 76;
    return CGSizeMake(width, height);
}

- (float)contentUpGapWithBubble
{
    return 2;
}

- (float)contentDownGapWithBubble
{
    return 2;
}

- (float)contentLeftGapWithBubble
{
    switch (self.location)
    {
        case DDBubbleRight:
            return 2;
        case DDBubbleLeft:
            return 10;
    }
    return 0;
}

- (float)contentRightGapWithBubble
{
    switch (self.location)
    {
        case DDBubbleRight:
            return 10;
            break;
        case DDBubbleLeft:
            return 2;
            break;
    }
    return 0;
}

- (void)layoutContentView:(DDMessageEntity*)content
{
    float x = self.bubbleImageView.left + [self contentLeftGapWithBubble];
    float y = self.bubbleImageView.top + [self contentUpGapWithBubble];
    CGSize size = [self sizeForContent:content];
    [self.imgView setFrame:CGRectMake(x, y, size.width, size.height)];
}

- (float)cellHeightForMessage:(DDMessageEntity*)message
{
    return 27 + 2 * dd_bubbleUpDown;
}
- (void)dealloc
{
    self.photos = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma mark -
#pragma mark DDMenuImageView Delegate
- (void)clickTheSendAgain:(MenuImageView*)imageView
{
    //子类去继承
    if (self.sendAgain)
    {
        self.sendAgain();
    }
}
- (void)sendImageAgain:(DDMessageEntity*)message
{
    //子类去继承
    [self showSending];
    NSDictionary* dic = [NSDictionary initWithJsonString:message.msgContent];
    NSString* locaPath = dic[DD_IMAGE_LOCAL_KEY];
    __block UIImage* image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:locaPath];
    if (!image)
    {
        [self showSendFailure];
        return ;
    }
    [[DDSendPhotoMessageAPI sharedPhotoCache] uploadImage:locaPath success:^(NSString *imageURL) {
        NSDictionary* tempMessageContent = [NSDictionary initWithJsonString:message.msgContent];
        NSMutableDictionary* mutalMessageContent = [[NSMutableDictionary alloc] initWithDictionary:tempMessageContent];
        [mutalMessageContent setValue:imageURL forKey:DD_IMAGE_URL_KEY];
        NSString* messageContent = [mutalMessageContent jsonString];
        message.msgContent = messageContent;
        DDLog(@"---------->上传图片成功!!!");
        image = nil;
        BOOL isGroup = message.msgType<5?NO:YES;
        [[DDMessageSendManager instance] sendMessage:imageURL isGroup:isGroup forSessionID:message.sessionId completion:^(DDMessageEntity* theMessage,NSError *error) {
            if (error)
            {
                DDLog(@"发送消息失败");
                message.state = DDMessageSendFailure;
                //刷新DB
                [[DDDatabaseUtil instance] updateMessageForMessage:message completion:^(BOOL result) {
                    if (result)
                    {
                        [self showSendFailure];
                    }
                }];
            }
            else
            {
                //刷新DB
                message.state = DDmessageSendSuccess;
                //刷新DB
                [[DDDatabaseUtil instance] updateMessageForMessage:message completion:^(BOOL result) {
                    if (result)
                    {
                        [self showSendSuccess];
                    }
                }];
            }
        }];
        
    } failure:^(id error) {
        message.state = DDMessageSendFailure;
        //刷新DB
        [[DDDatabaseUtil instance] updateMessageForMessage:message completion:^(BOOL result) {
            if (result)
            {
                [self showSendFailure];
            }
        }];
    }];
    
}
- (void)clickThePreview:(MenuImageView *)imageView
{
    //子类去继承
    if (self.preview)
    {
        self.preview();
    }
}
@end
