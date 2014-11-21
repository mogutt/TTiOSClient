//
//  DDChattingModule.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-28.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "ChattingModule.h"
#import "DDDatabaseUtil.h"
#import "DDChatTextCell.h"
#import "DDSessionEntity.h"
#import "LoginModule.h"
#import "DDAFClient.h"
#import "NSDate+DDAddition.h"
#import "DDAllotServiceAPI.h"
#import "DDAFClient.h"
static NSUInteger const showPromptGap = 300;
@interface ChattingModule(privateAPI)

- (NSUInteger)p_getMessageCount;
- (void)p_addHistoryMessages:(NSArray*)messages Completion:(DDChatLoadMoreHistoryCompletion)completion;

@end

@implementation ChattingModule
{    
    //只是用来获取cell的高度的
    DDChatTextCell* _textCell;
    
    NSUInteger _earliestDate;
    NSUInteger _lastestDate;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _showingMessages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setSessionEntity:(DDSessionEntity *)sessionEntity
{
    _sessionEntity = sessionEntity;
    
    _showingMessages = nil;
    _showingMessages = [[NSMutableArray alloc] init];
}

- (void)loadMoreHistoryCompletion:(DDChatLoadMoreHistoryCompletion)completion
{
    NSUInteger count = [self p_getMessageCount];
    [[DDDatabaseUtil instance] loadMessageForSessionID:self.sessionEntity.sessionID pageCount:DD_PAGE_ITEM_COUNT index:count completion:^(NSArray *messages, NSError *error) {
        [self p_addHistoryMessages:messages Completion:completion];
    }];
}

- (void)loadHostoryUntilCommodity:(DDMessageEntity*)message completion:(DDChatLoadMoreHistoryCompletion)completion
{
    [[DDDatabaseUtil instance] loadMessageForSessionID:self.sessionEntity.sessionID afterMessage:message completion:^(NSArray *messages, NSError *error) {
        [self p_addHistoryMessages:messages Completion:completion];
    }];
}

- (float)messageHeight:(DDMessageEntity*)message
{
    
    if (message.msgContentType == DDMessageTypeText ) {
        if (!_textCell)
        {
            _textCell = [[DDChatTextCell alloc] init];
        }
        return [_textCell cellHeightForMessage:message];

    }else if (message.msgContentType == DDMessageTypeVoice )
    {
        return 60;
    }else if(message.msgContentType == DDMessageTypeImage)
    {
         return 151;
    }
    else
    {
        return 135;
    }
    return 0;
}

- (void)addShowMessage:(DDMessageEntity*)message
{
    if (message.msgTime - _lastestDate > showPromptGap)
    {
        _lastestDate = message.msgTime;
        DDPromptEntity* prompt = [[DDPromptEntity alloc] init];
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:message.msgTime];
        prompt.message = [date promptDateString];
        [_showingMessages addObject:prompt];
    }
    //[_showingMessages addObject:message];
    [[self mutableArrayValueForKeyPath:@"showingMessages"] addObject:message];
}
-(void)insertObject:(id)object inShowingMessagesAtIndex:(NSUInteger)index
{
    [_showingMessages insertObject:object atIndex:index];
}
-(void)removeObjectFromShowingMessagesAtIndex:(NSUInteger)index
{
    [_showingMessages removeObjectAtIndex:index];
}

- (void)addShowMessages:(NSArray*)messages
{
   // [_showingMessages addObjectsFromArray:messages];
    [[self mutableArrayValueForKeyPath:@"showingMessages"] addObjectsFromArray:messages];
}
-(void)getCurrentUser:(void(^)(DDUserEntity *))block
{
    [[DDDatabaseUtil instance] getUserFromID:self.sessionEntity.sessionID completion:^(DDUserEntity *user) {
        block(user);
    }];
}
- (void)requestServicesWithShopID:(NSString*)shopID type:(int)type completion:(DDReuestServiceCompletion)completion
{
    DDAllotServiceAPI* allotServiceAPI = [[DDAllotServiceAPI alloc] init];
    [allotServiceAPI requestWithObject:@[shopID,@(type)] Completion:^(id response, NSError *error) {
        if (!error) {
            completion(response);
        }
        else
        {
            DDLog(@"%@",error);
            completion(nil);
        }
    }];
}



- (void)checkBlackList:(NSString *)bid userID:(NSString*)uid Block:(void(^)(bool isBlock))block
{
    
    NSMutableDictionary* param = [NSMutableDictionary dictionary];
    [param setValue:bid forKeyPath:@"bid"];
    [param setValue:uid forKeyPath:@"uid"];
    [DDAFClient jsonFormRequest:@"http://www.mogujie.com/mtalk/user/isblock" param:param fromBlock:^(id<AFMultipartFormData> formData) {
        
    } success:^(id result) {
        
        block([[result objectForKey:@"isBlock"] boolValue]);
        
    } failure:^(NSError *err) {
        
    }];
}

- (void)updateSessionUpdateTime:(NSUInteger)time
{
    [self.sessionEntity updateUpdateTime:time];
    _lastestDate = time;
}

- (void)clearChatData
{
    [self setSessionEntity:nil];
    [self.showingMessages removeAllObjects];
}

- (void)showMessagesAddCommodity:(DDMessageEntity*)message
{
    if ([self.showingMessages count] == 0)
    {
        DDPromptEntity* prompt = [[DDPromptEntity alloc] init];
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:message.msgTime];
        prompt.message = [date promptDateString];
        [_showingMessages addObject:prompt];
        [[self mutableArrayValueForKeyPath:@"showingMessages"] addObject:prompt];
        _lastestDate = message.msgTime;
        _earliestDate = message.msgTime;
    }
    [self.showingMessages addObject:message];
}

#pragma mark -
#pragma mark PrivateAPI
- (NSUInteger)p_getMessageCount
{
    __block NSUInteger count = 0;
    [_showingMessages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:NSClassFromString(@"DDMessageEntity")])
        {
            count ++;
        }
    }];
    return count;
}

- (void)p_addHistoryMessages:(NSArray*)messages Completion:(DDChatLoadMoreHistoryCompletion)completion
{
//    [[DDSundriesCenter instance] pushTaskToSerialQueue:^{
        NSUInteger tempEarliestDate = 0;
        NSUInteger tempLasteestDate = 0;
        NSUInteger itemCount = [_showingMessages count];
        NSMutableArray* tempMessages = [[NSMutableArray alloc] init];
        for (NSInteger index = [messages count] - 1; index >= 0;index --)
        {
            DDMessageEntity* message = messages[index];
            if (index == [messages count] - 1)
            {
                tempEarliestDate = message.msgTime;
            }
            if (message.msgTime - tempLasteestDate > showPromptGap)
            {
                DDPromptEntity* prompt = [[DDPromptEntity alloc] init];
                NSDate* date = [NSDate dateWithTimeIntervalSince1970:message.msgTime];
                prompt.message = [date promptDateString];
                [tempMessages addObject:prompt];
            }
            tempLasteestDate = message.msgTime;
            [tempMessages addObject:message];
        }
        
        if ([_showingMessages count] == 0)
        {
            [[self mutableArrayValueForKeyPath:@"showingMessages"] addObjectsFromArray:tempMessages];
            _earliestDate = tempEarliestDate;
            _lastestDate = tempLasteestDate;
        }
        else
        {
            [_showingMessages insertObjects:tempMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [tempMessages count])]];
            _earliestDate = tempEarliestDate;
        }
        NSUInteger newItemCount = [_showingMessages count];
//        dispatch_async(dispatch_get_main_queue(), ^{
            completion(newItemCount - itemCount,nil);
//        });
//    }];
}

@end

@implementation DDPromptEntity

@end
