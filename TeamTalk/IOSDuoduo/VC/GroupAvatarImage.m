//
//  GroupAvatarImage.m
//  TeamTalk
//
//  Created by Michael Scofield on 2014-09-25.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "GroupAvatarImage.h"
#import "DDGroupEntity.h"
#import "DDDatabaseUtil.h"
#import "PhotosCache.h"
#import "DDUserEntity.h"
#import <SDWebImage/UIImageView+WebCache.h>
#define BIGSIZE CGSizeMake(22, 22)
#define SMALLSIZE CGSizeMake(12, 12)
@implementation GroupAvatarImage

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(GroupAvatarImage *)getGroupImage:(DDGroupEntity *)group Block:(void(^)(UIImage *))block
{
    GroupAvatarImage *groupAvatar = [[GroupAvatarImage alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    NSData *data = [[PhotosCache sharedPhotoCache] photoFromDiskCacheForKey:group.objID];
    if (data) {
        UIImage *image = [UIImage imageWithData:data];
        block(image);
        return nil;
    }else
    {
        [group.fixGroupUserIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            __block UIImageView *imagev;
            [[DDDatabaseUtil instance] getUserFromID:obj completion:^(DDUserEntity *user) {
                if (idx<=4) {
                    imagev = [[UIImageView alloc] initWithFrame:CGRectMake((idx%2)*BIGSIZE.width, (idx/2)*BIGSIZE.width, BIGSIZE.width, BIGSIZE.height)];
                    [imagev sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"user_placeholder"]];
                    [groupAvatar addSubview:imagev];
                    
                }else
                {
                    *stop = YES;
                    UIGraphicsBeginImageContext(groupAvatar.bounds.size);
                    [groupAvatar.layer renderInContext:UIGraphicsGetCurrentContext()];
                    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    [[PhotosCache sharedPhotoCache] storePhoto:UIImagePNGRepresentation(viewImage) forKey:group.objID toDisk:YES];
                    block(viewImage);
                }
            }];
        }];
    }
    
//    if ([group.fixGroupUserIds count] >4) {
//        [group.fixGroupUserIds enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
//            UIImage *img = [self makeUserAvaterImage:obj];
//            UIImageView *imageView =[self makeAvater:img];
//            imageView.frame=CGRectMake(idx*SMALLSIZE.width, idx>2?SMALLSIZE.height:0, SMALLSIZE.width, SMALLSIZE.height);
//            [groupAvatar addSubview:imageView];
//        }];
//    }else
//    {
//        [group.fixGroupUserIds enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
//           UIImage *img = [self makeUserAvaterImage:obj];
//            UIImageView *imageView =[self makeAvater:img];
//            imageView.frame=CGRectMake((idx%2)*BIGSIZE.width, idx>2?BIGSIZE.height:0, BIGSIZE.width, BIGSIZE.height);
//            [groupAvatar addSubview:imageView];
//        }];
//    }
    return groupAvatar;
}
-(UIImage *)makeUserAvaterImage:(NSString *)userID
{
    __block UIImage *newImage;
    [[DDDatabaseUtil instance] getUserFromID:userID completion:^(DDUserEntity *user) {
        NSData *data = [[PhotosCache sharedPhotoCache] photoFromDiskCacheForKey:user.avatar];
        UIImage *image = [UIImage imageWithData:data];
        newImage=image;
    }];
    return newImage;
}
-(UIImageView *)makeAvater:(UIImage *)image
{
    UIImageView *bigImageView = [[UIImageView alloc] initWithImage:image];
    return bigImageView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
