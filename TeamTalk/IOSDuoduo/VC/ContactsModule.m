//
//  ContactsModel.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-07-21.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "ContactsModule.h"
#import "std.h"
#import "NSDictionary+Safe.h"
#import "DDDepartmentAPI.h"
#import "DDepartment.h"
#import "DDFixedGroupAPI.h"
#import "DDDatabaseUtil.h"
#import "DDGroupModule.h"
#import "RuntimeStatus.h"
#import "DDUserModule.h"
#import "DDGroupEntity.h"
#import "SpellLibrary.h"
@implementation ContactsModule
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contacts = [NSMutableArray new];
        self.groups = [NSMutableArray new];
        [self initContactsData];
    }
    return self;
}
-(void)initContactsData
{
   
    [[DDDatabaseUtil instance] getAllUsers:^(NSArray *contacts, NSError *error) {
        for (DDUserEntity *user in contacts) {
            [[DDDatabaseUtil instance] getDepartmentFromID:user.departId completion:^(DDepartment *department) {
                if (department) {
                    if ([user.departId isEqualToString:department.ID]) {
                        user.department= department.title;
                    }
                }
                [self.contacts addObject:user];
                if ([user isEqual:[contacts lastObject]]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshAllContacts" object:nil];
                }
            }];
        }
    }];
    
    
}

-(void)addContact:(DDUserEntity *)user
{
    
}
/**
 *  按首字母展示
 *
 *  @return 返回界面需要的字典类型
 */
-(NSMutableDictionary *)sortByContactFirstLetter 
{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    for (DDUserEntity * user in self.contacts) {
        char firstLetter = getFirstChar(user.name);
        NSString *fl = [NSString stringWithFormat:@"%c",firstLetter];
        if ([dic safeObjectForKey:fl]) {
            NSMutableArray *arr = [dic safeObjectForKey:fl];
            [arr addObject:user];
        }else
        {
            NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:@[user]];
            [dic setObject:arr forKey:fl];
        }
    }
     return dic;
}
/**
 *  按部门分类展示
 *
 *  @return 返回界面需要的字典类型
 */
-(NSMutableDictionary *)sortByDepartment
{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    for (DDUserEntity * user in self.contacts) {
            if ([dic safeObjectForKey:user.department]) {
            NSMutableArray *arr = [dic safeObjectForKey:user.department];
            [arr addObject:user];
        }else
        {
            NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:@[user]];
            [dic safeSetObject:arr forKey:user.department];
        }
    }
    return dic;
    
}
/**
 *  获取本地收藏的联系人
 *
 *  @return 界面收藏联系人列表
 */
+(NSArray *)getFavContact
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [userDefaults objectForKey:@"favuser"];
    NSMutableArray *contacts = [NSMutableArray new];
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       [contacts addObject:[DDUserEntity dicToUserEntity:(NSDictionary *)obj]] ;
    }];
    return contacts;
}
/**
 *  收藏联系人接口
 *
 *  @param user 联系人对象
 */
+(void)favContact:(DDUserEntity *)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"favuser"] == nil) {
        [userDefaults setObject:@[[DDUserEntity userToDic:user]] forKey:@"favuser"];
    }else
    {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[userDefaults objectForKey:@"favuser"]];
        if ([arr count] == 0) {
            [arr addObject:[DDUserEntity userToDic:user]];
            [userDefaults setObject:arr forKey:@"favuser"];
            return;
        }
        for (int i = 0;i<[arr count];i++) {
            NSDictionary *dic = [arr objectAtIndex:i];
            if ([[dic objectForKey:@"userId"] isEqualToString:user.objID]) {
                [arr removeObject:dic];
                [userDefaults setObject:arr forKey:@"favuser"];
                return;
            }else
            {
                if ([[arr objectAtIndex:i] isEqualToDictionary:[arr lastObject]]) {
                    [arr addObject:[DDUserEntity userToDic:user]];
                    [userDefaults setObject:arr forKey:@"favuser"];
                    return;
                }
                
            }
        }
        
      
    }
}
/**
 *  检查是否在收藏的联系人里
 *
 *  @param user 用户对象
 *
 *  @return 返回yes表示在收藏的联系人里
 */
-(BOOL)isInFavContactList:(DDUserEntity *)user
{
      NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[userDefaults objectForKey:@"favuser"]];
    for (int i = 0;i<[arr count];i++) {
        NSDictionary *dic = [arr objectAtIndex:i];
        if ([[dic objectForKey:@"userId"] isEqualToString:user.objID]) {
            return YES;
        }
    }
    return NO;
}
+(void)getDepartmentData:(void(^)(id response))block
{
    DDDepartmentAPI* api = [[DDDepartmentAPI alloc] init];
    [api requestWithObject:nil Completion:^(id response, NSError *error) {
        if (!error)
        {
            if (response)
            {
                block(response);
                
            }
            else
            {
                block(nil);
            }
        }
        else
        {
            DDLog(@"error:%@",[error domain]);
            block(nil);
        }
    }];
}

@end
