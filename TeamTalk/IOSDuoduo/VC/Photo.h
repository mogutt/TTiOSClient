//
//  DDPhoto.h
//  IOSDuoduo
//
//  Created by 东邪 on 14-6-6.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject
@property(nonatomic,strong)NSString *localPath;
@property(nonatomic,strong)NSString *resultUrl;
@property(nonatomic,assign)CGImageRef imageRef;
@property(nonatomic,strong)UIImage* image;
@end
