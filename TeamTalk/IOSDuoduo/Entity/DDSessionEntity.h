//
//  DDSessionEntity.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-6-5.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum
{
    SESSIONTYPE_SINGLE = 1,          //单个用户会话
    SESSIONTYPE_GROUP = 2,           //群会话
    SESSIONTYPE_TEMP_GROUP = 3,      //临时群会话.
    
}SessionType;

@interface DDSessionEntity : NSObject
@property (nonatomic,retain)NSString* sessionID;
@property (nonatomic,assign)SessionType sessionType;
@property (nonatomic,readonly)NSString* name;
@property (nonatomic,readonly)NSUInteger timeInterval;
@property(nonatomic,strong,readonly)NSString* orginId;
//@property(nonatomic,strong,readonly)NSArray*  groupUsers;
-(NSArray*)groupUsers;
@property(nonatomic,strong,readonly)NSArray*  groupName;

/**
 *  创建一个session，只需赋值sessionID和Type即可
 *
 *  @param sessionID 会话ID，群组传入groupid，p2p传入对方的userid
 *  @param type      会话的类型
 *
 *  @return 
 */
- (id)initWithSessionID:(NSString*)sessionID type:(SessionType)type;
- (void)updateUpdateTime:(NSUInteger)date;
-(NSString *)getSessionGroupID;
-(void)setSessionName:(NSString *)theName;
-(BOOL)isGroup;
@end
