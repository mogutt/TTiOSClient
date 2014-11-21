//
//  DDSessionEntity.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-6-5.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDSessionEntity.h"
#import "DDUserModule.h"
#import "DDDatabaseUtil.h"
#import "DDGroupEntity.h"
#import "DDGroupModule.h"

@implementation DDSessionEntity
@synthesize  name;
@synthesize timeInterval;
- (void)setSessionID:(NSString *)sessionID
{
    _sessionID = [sessionID copy];
    name = nil;
    timeInterval = 0;
}

- (void)setSessionType:(SessionType)sessionType
{
    _sessionType = sessionType;
    name = nil;
    timeInterval = 0;
}

- (NSString*)name
{
    if (!name)
    {
        switch (self.sessionType)
        {
            case SESSIONTYPE_SINGLE:
            {
                [[DDUserModule shareInstance] getUserForUserID:_sessionID Block:^(DDUserEntity *user) {
                    if ([user.nick length] > 0)
                    {
                        name = user.nick;
                    }
                    else
                    {
                        name = user.name;
                    }

                }];
        }
                break;
            case SESSIONTYPE_TEMP_GROUP:
            {
                DDGroupEntity* group = [[DDGroupModule instance] getGroupByGId:_sessionID];
                name=group.name;
            }
                break;
        }
    }
    return name;
}
-(void)setSessionName:(NSString *)theName
{
    name = theName;
}
- (NSUInteger)timeInterval
{
    if (timeInterval == 0)
    {
        switch (_sessionType)
        {
            case SESSIONTYPE_SINGLE:
            {
                 [[DDUserModule shareInstance] getUserForUserID:_sessionID Block:^(DDUserEntity *user) {
                      timeInterval = user.lastUpdateTime;
                }];
              
            }
            break;
        }
    }
    return timeInterval;
}

#pragma mark -
#pragma mark Public API
- (id)initWithSessionID:(NSString*)sessionID type:(SessionType)type
{
    self = [super init];
    if (self)
    {
        self.sessionID = sessionID;
        self.sessionType = type;
    }
    return self;
}

- (void)updateUpdateTime:(NSUInteger)date
{
     timeInterval = date;
    if (_sessionType == SESSIONTYPE_SINGLE ) {
       
        [[DDUserModule shareInstance] getUserForUserID:_sessionID Block:^(DDUserEntity *user) {
            if (user)
            {
                user.lastUpdateTime = timeInterval;
                [[DDDatabaseUtil instance] updateContact:user inDBCompletion:^(NSError *error) {
                    
                }];
            }
            
        }];
    }else
    {
//       DDGroupEntity *group= [[DDGroupModule instance] getGroupByGId:_sessionID];
//        group.lastUpdateTime=timeInterval;
//        [[DDDatabaseUtil instance] updateRecentGroup:group completion:^(NSError *error) {
//            
//        }];
    }
}
-(NSArray*)groupUsers
{
    if(SESSIONTYPE_GROUP == self.sessionType || SESSIONTYPE_TEMP_GROUP == self.sessionType)
    {
        DDGroupEntity* group = [[DDGroupModule instance] getGroupByGId:_sessionID];
        return group.groupUserIds;
    }
    else
    {
        DDLog(@"groupUsers error session type is :%d",self.sessionType);
        return  nil;
    }
}
-(NSString *)getSessionGroupID
{
    return _sessionID;
}
-(BOOL)isGroup
{
    if(SESSIONTYPE_GROUP == self.sessionType || SESSIONTYPE_TEMP_GROUP == self.sessionType)
    {
        return YES;
    }
    return NO;
}
@end
