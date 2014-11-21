//
//  DDChattingModule.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-28.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDSessionEntity.h"
#import "DDUserEntity.h"
#define DD_PAGE_ITEM_COUNT                  10

typedef void(^DDReuestServiceCompletion)(DDUserEntity* user);
typedef void(^DDRequestGoodDetailCompletion)(NSDictionary* detail,NSError* error);
@class DDCommodity;
@class DDMessageEntity;
typedef void(^DDChatLoadMoreHistoryCompletion)(NSUInteger addcount, NSError* error);

@interface ChattingModule : NSObject
@property (nonatomic,retain)DDSessionEntity* sessionEntity;
@property (nonatomic,readonly)NSMutableArray* showingMessages;
@property (assign) NSInteger isGroup;
/**
 *  加载历史消息接口，这里会适时插入时间
 *
 *  @param completion 加载完成
 */
- (void)loadMoreHistoryCompletion:(DDChatLoadMoreHistoryCompletion)completion;

- (void)loadHostoryUntilCommodity:(DDMessageEntity*)message completion:(DDChatLoadMoreHistoryCompletion)completion;

- (float)messageHeight:(DDMessageEntity*)message;

- (void)addShowMessage:(DDMessageEntity*)message;
- (void)addShowMessages:(NSArray*)messages;
- (void)requestServicesWithShopID:(NSString*)shopID type:(int)type completion:(DDReuestServiceCompletion)completion;

- (void)requestGoodDetailWithGoodID:(NSString*)googID shopID:(NSString*)shopID completion:(DDRequestGoodDetailCompletion)completion;

- (void)updateSessionUpdateTime:(NSUInteger)time;
- (void)checkBlackList:(NSString *)bid userID:(NSString*)uid Block:(void(^)(bool isBlock))block;

- (void)clearChatData;
- (void)showMessagesAddCommodity:(DDMessageEntity*)message;
-(void)getCurrentUser:(void(^)(DDUserEntity *))block;
@end


@interface DDPromptEntity : NSObject
@property(nonatomic,retain)NSString* message;

@end