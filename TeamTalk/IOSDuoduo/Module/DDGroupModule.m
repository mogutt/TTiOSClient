//
//  DDGroupModule.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-11.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "DDGroupModule.h"
#import "RuntimeStatus.h"
#import "DDGroupInfoAPI.h"
#import "DDReceiveGroupAddMemberAPI.h"
#import "DDRecentGroupAPI.h"
#import "DDDatabaseUtil.h"
#import "GroupAvatarImage.h"
#import "DDNotificationHelp.h"
@implementation DDGroupModule
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.allGroups = [NSMutableDictionary new];
        self.allFixedGroup = [NSMutableDictionary new];
        self.recentlyGroup = [NSMutableDictionary new];
        [[DDDatabaseUtil instance] loadGroupsCompletion:^(NSArray *contacts, NSError *error) {
            [contacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                DDGroupEntity *group = (DDGroupEntity *)obj;
                if(group.objID)
                {
                   [self.recentlyGroup setObject:group forKey:group.objID];
                }
            }];
              [DDNotificationHelp postNotification:DDNotificationLoadLocalGroupFinish userInfo:nil object:nil];
            
        }];
        [self registerAPI];
    }
    return self;
}

+ (instancetype)instance
{
    static DDGroupModule* group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        group = [[DDGroupModule alloc] init];
        
    });
    return group;
}
-(void)getGroupFromDB
{
    
}
-(void)addGroup:(DDGroupEntity*)newGroup
{
    if (!newGroup)
    {
        return;
    }
    DDGroupEntity* group = newGroup;
    if([self isContainGroup:newGroup.objID])
    {
        group = [_allGroups valueForKey:newGroup.objID];
        [group copyContent:newGroup];
    }
    [_allGroups setObject:group forKey:group.objID];
//    DDSessionModule* sessionModule = getDDSessionModule();
//    NSArray* recentleSession = [sessionModule recentlySessionIds];
//    if ([recentleSession containsObject:group.groupId] &&
//        ![sessionModule getSessionBySId:group.groupId])
//    {
//        //针对最近联系人列表中出现的空白行的情况
//        SessionEntity* session = [[SessionEntity alloc] init];
//        session.sessionId = group.groupId;
//        session.type = group.groupType + 1;
//        session.lastSessionTime = group.groupUpdated;
//        [sessionModule addSession:session];
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_RECENT_ESSION_ROW object:group.groupId];
//    }
    newGroup = nil;
}
-(NSArray*)getAllGroups
{
    return [_allGroups allValues];
}
-(DDGroupEntity*)getGroupByGId:(NSString*)gId
{
    return [_allGroups valueForKey:gId];
}
-(NSArray*)getAllFixedGroups
{
    return [_allFixedGroup allValues];
}

- (void)getGroupInfogroupID:(NSString*)groupID completion:(GetGroupInfoCompletion)completion
{
  
    DDGroupInfoAPI* groupInfo = [[DDGroupInfoAPI alloc] init];
    
    [groupInfo requestWithObject:groupID Completion:^(id response, NSError *error) {
        if (!error)
        {
            DDGroupEntity* group = (DDGroupEntity*)response;
            if (group)
            {
                [self addGroup:group];
            }
            completion(group);
        }
    }];
}

-(BOOL)isContainGroup:(NSString*)gId
{
    return ([_allGroups valueForKey:gId] != nil);
}

- (void)registerAPI
{
    //获取最近群
    

//    DDReceiveGroupAddMemberAPI* addmemberAPI = [[DDReceiveGroupAddMemberAPI alloc] init];
//    [addmemberAPI registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
//        if (!error)
//        {
//            
//            DDGroupEntity* groupEntity = (DDGroupEntity*)object;
//            if (!groupEntity)
//            {
//                return;
//            }
//            if ([self getGroupByGId:groupEntity.objID])
//            {
//                //自己本身就在组中
//                
//            }
//            else
//            {
//                //自己被添加进组中
//                
//                groupEntity.lastUpdateTime = [[NSDate date] timeIntervalSince1970];
//                [[DDGroupModule instance] addGroup:groupEntity];
////                [self addGroup:groupEntity];
////                DDSessionModule* sessionModule = getDDSessionModule();
////                [sessionModule createGroupSession:groupEntity.groupId type:GROUP_TYPE_TEMPORARY];
//                [[NSNotificationCenter defaultCenter] postNotificationName:DDNotificationRecentContactsUpdate object:nil];
//            }
//        }
//        else
//        {
//            DDLog(@"error:%@",[error domain]);
//        }
//    }];
    
//    DDReceiveGroupDeleteMemberAPI* deleteMemberAPI = [[DDReceiveGroupDeleteMemberAPI alloc] init];
//    [deleteMemberAPI registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
//        if (!error)
//        {
//            GroupEntity* groupEntity = (GroupEntity*)object;
//            if (!groupEntity)
//            {
//                return;
//            }
//            DDUserlistModule* userModule = getDDUserlistModule();
//            if ([groupEntity.groupUserIds containsObject:userModule.myUserId])
//            {
//                //别人被踢了
//                [[DDMainWindowController instance] updateCurrentChattingViewController];
//            }
//            else
//            {
//                //自己被踢了
//                [self.recentlyGroupIds removeObject:groupEntity.groupId];
//                DDSessionModule* sessionModule = getDDSessionModule();
//                [sessionModule.recentlySessionIds removeObject:groupEntity.groupId];
//                DDMessageModule* messageModule = getDDMessageModule();
//                [messageModule popArrayMessage:groupEntity.groupId];
//                [NotificationHelp postNotification:notificationReloadTheRecentContacts userInfo:nil object:nil];
//            }
//        }
//    }];
}
-(void)addRecentlyGroup:(NSArray *)array
{
    [array enumerateObjectsUsingBlock:^(DDGroupEntity * obj, NSUInteger idx, BOOL *stop) {
        if(obj.objID)
        {
            if (obj.isShield) {
                [TheRuntime addToShielding:obj.objID];
            }
            [self.recentlyGroup setObject:obj forKey:obj.objID];
            [self addGroup:obj];
            [[DDDatabaseUtil instance] updateRecentGroup:obj completion:^(NSError *error) {
                
            }];
        }
    }];
  
}
-(void)saveRecentLyGroup
{
    [[self.recentlyGroup allValues] enumerateObjectsUsingBlock:^(DDGroupEntity *obj, NSUInteger idx, BOOL *stop) {
        [[DDDatabaseUtil instance] updateRecentGroup:obj completion:^(NSError *error) {
            
        }];
    }];
}
@end
