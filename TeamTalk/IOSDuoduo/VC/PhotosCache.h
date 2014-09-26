//
//  DDPhotosCache.h
//  IOSDuoduo
//
//  Created by 东邪 on 14-5-29.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^cacheblock)(BOOL isFinished);
@interface PhotosCache : NSObject
+(void)calculatePhotoSizeWithCompletionBlock:(void (^)(NSUInteger fileCount, NSUInteger totalSize))completionBlock;
+ (PhotosCache *)sharedPhotoCache;
- (void)storePhoto:(NSData *)photos forKey:(NSString *)key toDisk:(BOOL)toDisk ;
- (NSData *)photoFromDiskCacheForKey:(NSString *)key;
- (void)removePhotoForKey:(NSString *)key;
- (NSString *)defaultCachePathForKey:(NSString *)key;
- (NSUInteger)getSize;
- (int)getDiskCount;
- (void)removePhotoFromNSCacheForKey:(NSString *)key;
- (NSOperation *)queryDiskCacheForKey:(NSString *)key done:(void (^)(NSData *voice))doneBlock;
-(NSString *)getKeyName;
-(void)clearAllCache;
-(NSMutableArray *)getAllImageCache;
@end
