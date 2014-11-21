/************************************************************
 * @file         GroupEntity.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       群实体信息
 ************************************************************/

#import <Foundation/Foundation.h>
#import "DDBaseEntity.h"
static NSString* const GROUP_PRE = @"group_";          //group id 前缀

enum
{
    GROUP_TYPE_FIXED = 1,       //固定群
    GROUP_TYPE_TEMPORARY,       //临时群
};

@interface DDGroupEntity : DDBaseEntity

@property(nonatomic,strong) NSString* groupCreatorId;        //群创建者ID
@property(nonatomic,assign) int groupType;                //群类型
@property(nonatomic,strong) NSString* name;                  //群名称
@property(nonatomic,strong) NSString* avatar;                //群头像
@property(nonatomic,strong) NSMutableArray* groupUserIds;    //群用户列表ids
@property(nonatomic,readonly)NSMutableArray* fixGroupUserIds;//固定的群用户列表IDS，用户生成群头像
@property(strong)NSString *lastMsg;
@property(assign)BOOL isShield;
//对群成员排序
-(void)sortGroupUsers;

-(void)copyContent:(DDGroupEntity*)entity;


- (void)addFixOrderGroupUserIDS:(NSString*)ID;
+(DDGroupEntity *)dicToGroupEntity:(NSDictionary *)dic;
+(NSString *)getSessionId:(NSString *)groupId;
@end
