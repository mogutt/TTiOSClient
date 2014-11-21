//
//  DDUserEntity.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDUserEntity.h"
#import "NSDictionary+Safe.h"
#import "PublicProfileViewControll.h"
@implementation DDUserEntity
- (id)initWithUserID:(NSString*)userID name:(NSString*)name nick:(NSString*)nick avatar:(NSString*)avatar userRole:(NSInteger)userRole userUpdated:(NSUInteger)updated
{
    self = [super init];
    if (self)
    {
        self.objID = [userID copy];
        _name = [name copy];
        _nick = [nick copy];
        _avatar = [avatar copy];
        _userRole = userRole;
        self.lastUpdateTime = updated;
        _info = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSString*)avatar
{
    if (![_avatar hasSuffix:@"_100x100"])
    {
        return [NSString stringWithFormat:@"%@_100x100",_avatar];
    }
    return _avatar;
}

+(NSMutableDictionary *)userToDic:(DDUserEntity *)user
{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic safeSetObject:user.objID forKey:@"userId"];
    [dic safeSetObject:user.name forKey:@"name"];
    [dic safeSetObject:user.nick forKey:@"nick"];
    [dic safeSetObject:user.avatar forKey:@"avatar"];
    [dic safeSetObject:user.departId forKey:@"departId"];
    [dic safeSetObject:user.email forKey:@"email"];
    [dic safeSetObject:user.department forKey:@"department"];
    [dic safeSetObject:user.position forKey:@"position"];
    [dic safeSetObject:user.token forKey:@"token"];
    [dic safeSetObject:[NSNumber numberWithInt:user.jobNum] forKey:@"jobNum"];
    [dic safeSetObject:user.telphone forKey:@"telphone"];
    [dic safeSetObject:user.department forKey:@"departName"];
    [dic safeSetObject:[NSNumber numberWithInt:user.sex ]forKey:@"sex"];
    [dic safeSetObject:[NSNumber numberWithInt:user.roleStatus] forKey:@"roleStatus"];
    [dic safeSetObject:[NSNumber numberWithInt:user.userRole] forKey:@"userRole"];
    [dic safeSetObject:[NSNumber numberWithInt:user.lastUpdateTime] forKey:@"lastUpdateTime"];
    return dic;
}
- (void) encodeWithCoder:(NSCoder *)encoder {

    [encoder encodeObject:self.objID forKey:@"userId"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.nick forKey:@"nick"];
    [encoder encodeObject:self.avatar forKey:@"avatar"];
    [encoder encodeObject:self.departId forKey:@"departId"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.department forKey:@"department"];
    [encoder encodeObject:self.position forKey:@"position"];
    [encoder encodeObject:self.token forKey:@"token"];
    [encoder encodeObject:[NSNumber numberWithInt:self.jobNum] forKey:@"jobNum"];
    [encoder encodeObject:self.telphone forKey:@"telphone"];
    [encoder encodeObject:[NSNumber numberWithInt:self.sex ]forKey:@"sex"];
    [encoder encodeObject:[NSNumber numberWithInt:self.roleStatus] forKey:@"roleStatus"];
    [encoder encodeObject:[NSNumber numberWithInt:self.userRole] forKey:@"userRole"];
    [encoder encodeObject:[NSNumber numberWithInt:self.lastUpdateTime] forKey:@"lastUpdateTime"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super init])) {
        self.objID = [aDecoder decodeObjectForKey:@"userId"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.nick = [aDecoder decodeObjectForKey:@"nickName"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.avatar = [aDecoder decodeObjectForKey:@"avatar"];
        self.department = [aDecoder decodeObjectForKey:@"department"];
        self.departId = [aDecoder decodeObjectForKey:@"departId"];
        self.email = [aDecoder decodeObjectForKey:@"email"];
        self.position = [aDecoder decodeObjectForKey:@"position"];
        self.token = [aDecoder decodeObjectForKey:@"token"];
        self.jobNum = [[aDecoder
                        decodeObjectForKey:@"jobNum"] integerValue];
        self.telphone = [aDecoder decodeObjectForKey:@"telphone"];
        self.sex = [[aDecoder decodeObjectForKey:@"sex"] integerValue];
        self.roleStatus = [[aDecoder decodeObjectForKey:@"roleStatus"] integerValue];

    }
    return self;
    
}
//@"serverTime":@(serverTime),
//@"result":@(loginResult),
//@"state":@(state),
//@"nickName":nickName,
//@"userId":userId,
//@"title":title,
//@"position":position,
//@"isDeleted":@(isDeleted),
//@"sex":@(sex),
//@"departId":departId,
//@"jobNum":@(jobNum),
//@"telphone":telphone,
//@"email":email,
//@"creatTime":@(creatTime),
//@"updateTime":@(updateTime),
//@"token":token,
//@"userType":@(userType)
+(id)dicToUserEntity:(NSDictionary *)dic
{
    DDUserEntity *user = [DDUserEntity new];
    user.objID = [dic safeObjectForKey:@"userId"];
    user.name = [dic safeObjectForKey:@"name"];
    user.nick = [dic safeObjectForKey:@"nickName"];
    user.title = [dic safeObjectForKey:@"title"];
    user.avatar = [dic safeObjectForKey:@"avatar"];
    user.department = [dic safeObjectForKey:@"department"];
    user.departId =[dic safeObjectForKey:@"departId"];
    user.email = [dic safeObjectForKey:@"email"];
    user.position = [dic safeObjectForKey:@"position"];
    user.token = [dic safeObjectForKey:@"token"];
    user.jobNum = [[dic
                   safeObjectForKey:@"jobNum"] integerValue];
    user.telphone = [dic safeObjectForKey:@"telphone"];
    user.sex = [[dic safeObjectForKey:@"sex"] integerValue];
    user.roleStatus = [[dic safeObjectForKey:@"roleStatus"] integerValue];
    user.lastUpdateTime = [[dic safeObjectForKey:@"lastUpdateTime"] integerValue];
    user.pyname = [dic safeObjectForKey:@"pyname"];
    return user;

}
-(void)sendEmail
{
    NSString *stringURL =[NSString stringWithFormat:@"mailto:%@",self.email];
    NSURL *url = [NSURL URLWithString:stringURL];
    [[UIApplication sharedApplication] openURL:url];
}
-(void)callPhoneNum
{
    NSString *string = [NSString stringWithFormat:@"tel:%@",self.telphone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
}

@end
