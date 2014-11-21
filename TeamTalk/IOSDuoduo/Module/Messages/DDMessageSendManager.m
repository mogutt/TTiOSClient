
//
//  DDMessageSendManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-30.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDMessageSendManager.h"
#import "DDUserModule.h"
#import "DDMessageEntity.h"
#import "DDMessageModule.h"
#import "DDTcpClientManager.h"
#import "DDSendMessageAPI.h"
#import "DDSendVoiceMessageAPI.h"
#import "RuntimeStatus.h"
#import "RecentUsersViewController.h"
#import "EmotionsModule.h"
#import "NSDictionary+JSON.h"
#import "UnAckMessageManager.h"
#import "DDGroupModule.h"
#import "DDClientState.h"
static uint32_t seqNo = 0;

@interface DDMessageSendManager(PrivateAPI)

- (NSString* )toSendmessageContentFromContent:(NSString*)content;

@end

@implementation DDMessageSendManager
{
    NSUInteger _uploadImageCount;
}
+ (instancetype)instance
{
    static DDMessageSendManager* g_messageSendManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_messageSendManager = [[DDMessageSendManager alloc] init];
    });
    return g_messageSendManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _uploadImageCount = 0;
        _waitToSendMessage = [[NSMutableArray alloc] init];
        _sendMessageSendQueue = dispatch_queue_create("com.mogujie.Duoduo.sendMessageSend", NULL);
        
    }
    return self;
}

- (void)sendMessage:(DDMessageEntity *)message isGroup:(BOOL)isGroup forSessionID:(NSString*)sessionID completion:(DDSendMessageCompletion)completion
{
    NSLog(@"%d.....>",[DDClientState shareInstance].userState);
    dispatch_async(self.sendMessageSendQueue, ^{
        DDSendMessageAPI* sendMessageAPI = [[DDSendMessageAPI alloc] init];
        uint32_t nowSeqNo = ++seqNo;
        message.seqNo=nowSeqNo;
        NSString* myUserID = [RuntimeStatus instance].user.objID;
        NSString* newContent = [self toSendmessageContentFromContent:message.msgContent];
        if ([message isImageMessage]) {
            NSDictionary* dic = [NSDictionary initWithJsonString:message.msgContent];
            NSString* urlPath = dic[DD_IMAGE_URL_KEY];
            newContent=urlPath;
        }
        NSArray* object = @[myUserID,sessionID,newContent,@(nowSeqNo),@(isGroup?DDGroup_Message_TypeText:DDMessageTypeText)];
        if (!isGroup) {
            [[DDUserModule shareInstance] getUserForUserID:sessionID Block:^(DDUserEntity *user) {
                if (user) {
                    if (user.lastUpdateTime == 0) {
                        user.lastUpdateTime =[[NSDate date] timeIntervalSince1970];
                    }
                    [[DDUserModule shareInstance] addMaintanceUser:user];
                    [[DDUserModule shareInstance] addRecentUser:user];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SentMessageSuccessfull" object:sessionID];
                }
            }];
        }else
        {
            DDGroupEntity *group = [[DDGroupModule instance] getGroupByGId:sessionID];
            group.lastUpdateTime = [[NSDate date] timeIntervalSince1970];
          //  [[DDGroupModule instance] addRecentlyGroup:@[group]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SentMessageSuccessfull" object:sessionID];
        }
        [[UnAckMessageManager instance] addMessageToUnAckQueue:message];
        [sendMessageAPI requestWithObject:object Completion:^(id response, NSError *error) {
            if (!error)
            {
                uint32_t returnSeqNo = [response intValue];
                if (returnSeqNo == nowSeqNo)
                {
                    
                    NSUInteger messageTime = [[NSDate date] timeIntervalSince1970];
                    message.msgTime=messageTime;
                    message.seqNo=returnSeqNo;
                    message.state=DDmessageSendSuccess;
                    [[UnAckMessageManager instance] removeMessageFromUnAckQueue:message];
                    completion(message,nil);
                   
                }
                else
                {
                    message.state=DDMessageSendFailure;
                    NSError* error = [NSError errorWithDomain:@"发送消息失败,seqNo对不上" code:0 userInfo:nil];
                    completion(message,error);
                }
                
            }
            else
            {
                message.state=DDMessageSendFailure;
                NSError* error = [NSError errorWithDomain:@"发送消息失败" code:0 userInfo:nil];
                completion(message,error);
            }
        }];
        
    });
}

- (void)sendVoiceMessage:(NSData*)voice filePath:(NSString*)filePath forSessionID:(NSString*)sessionID isGroup:(BOOL)isGroup completion:(DDSendMessageCompletion)completion
{
    dispatch_async(self.sendMessageSendQueue, ^{
        DDSendVoiceMessageAPI* sendVoiceMessageAPI = [[DDSendVoiceMessageAPI alloc] init];
        uint32_t nowSeqNo = ++seqNo;
        NSString* myUserID = [RuntimeStatus instance].user.objID;
        
        NSArray* object = @[myUserID,sessionID,@(nowSeqNo),isGroup?@(DDGroup_MessageTypeVoice):@(DDMessageTypeVoice),@(1),voice,@""];
        [sendVoiceMessageAPI requestWithObject:object Completion:^(id response, NSError *error) {
            if (!error)
            {
                uint32_t returnSeqNo = [response intValue];
                if (returnSeqNo == nowSeqNo)
                {
                    NSUInteger messageTime = [[NSDate date] timeIntervalSince1970];
                    
                    DDMessageEntity* message = [[DDMessageEntity alloc] initWithMsgID:0 msgType:MESSAGE_TYPE_TEMP_GROUP msgTime:messageTime sessionID:sessionID senderID:myUserID msgContent:filePath toUserID:sessionID];
                    if (isGroup) {
                        message.msgContentType=DDGroup_MessageTypeVoice;
                    }else
                    {
                        message.msgContentType = DDMessageTypeVoice;
                    }
                    completion(message,nil);
                }
                else
                {
                    NSError* error = [NSError errorWithDomain:@"发送消息失败,seqNo对不上" code:0 userInfo:nil];
                    completion(nil,error);
                }
                
            }
            else
            {
                NSError* error = [NSError errorWithDomain:@"发送消息失败" code:0 userInfo:nil];
                completion(nil,error);
            }
        }];

    });
}

//- (void)sendMessage:(NSAttributedString*)content forSession:(SessionEntity*)session success:(void(^)(NSString* sendedContent))success failure:(void(^)(NSString*))failure
//{
//    MessageType messageType = [content messageType];
//    if (messageType == AllString)
//    {
//        [self sendSimpleMessage:content forSession:session success:^(NSString *sendedContent) {
//            success(sendedContent);
//        } failure:^(NSString *content) {
//            failure(content);
//        } ];
//    }
//    else if (messageType == HasImage)
//    {
//        [self sendMixMessage:content forSession:session success:^(NSString *sendedContent) {
//            success(sendedContent);
//        } failure:^(NSString *content){
//            failure(content);
//        }];
//    }
//}

#pragma mark Private API

- (NSString* )toSendmessageContentFromContent:(NSString*)content
{
    EmotionsModule* emotionModule = [EmotionsModule shareInstance];
    NSDictionary* unicodeDic = emotionModule.unicodeEmotionDic;
    NSArray* allEmotions = emotionModule.emotions;
    NSMutableString* newContent = [NSMutableString stringWithString:content];
    [allEmotions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString* emotion = (NSString*)obj;
        if ([newContent rangeOfString:emotion].length > 0)
        {
            NSString* placeholder = unicodeDic[emotion];
            NSRange range = NSMakeRange(0, newContent.length);
            [newContent replaceOccurrencesOfString:emotion withString:placeholder options:0 range:range];
        }
    }];
    return newContent;
}

//- (void)sendMixMessage:(NSAttributedString *)content forSession:(SessionEntity *)session success:(void (^)(NSString *))success failure:(void(^)(NSString* ))failure
//{
//    dispatch_async(self.sendMessageSendQueue, ^{
//        NSString* string = [content getHasImageContentFromInput];
//        DDUserlistModule* userListModule = getDDUserlistModule();
//
//        DDSendMessageAPI* sendMessageAPI = [[DDSendMessageAPI alloc] init];
//        uint32_t nowSeqNo = ++seqNo;
//        NSArray* object = @[userListModule.myUserId,session.orginId,string,[NSNumber numberWithInt:nowSeqNo],[NSNumber numberWithInt:session.type]];
//        
//        [sendMessageAPI requestWithObject:object Completion:^(id response, NSError *error) {
//            if (!error)
//            {
//                uint32_t returnSeqNo = [response intValue];
//                if (returnSeqNo == nowSeqNo)
//                {
//                    success(string);
//                }
//                else
//                {
//                    failure(@"seqNo不同");
//                    DDLog(@"different seqNo");
//                }
//                
//            }
//            else
//            {
//                failure(@"发送超时");
//            }
//        }];
//    });
//}

@end
