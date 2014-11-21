//
//  DDGroupModule.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-11.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDGroupEntity.h"
typedef void(^GetGroupInfoCompletion)(DDGroupEntity* group);
@interface DDGroupModule : NSObject
+ (instancetype)instance;
@property(assign)NSInteger recentGroupCount;
@property(strong) NSMutableDictionary* allGroups;         //所有群列表,key:group id value:GroupEntity
@property(strong) NSMutableDictionary* allFixedGroup;     //所有固定群列表
@property(strong)NSMutableDictionary*      recentlyGroup;   
-(DDGroupEntity*)getGroupByGId:(NSString*)gId;
-(void)addGroup:(DDGroupEntity*)newGroup;
- (void)getGroupInfogroupID:(NSString*)groupID completion:(GetGroupInfoCompletion)completion;
-(NSArray*)getAllGroups;
-(void)addRecentlyGroup:(NSArray *)array;
-(void)saveRecentLyGroup;
@end
