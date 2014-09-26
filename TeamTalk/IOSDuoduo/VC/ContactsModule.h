//
//  ContactsModel.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-07-21.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDUserEntity.h"
@interface ContactsModule : NSObject
@property(strong)NSMutableArray *contacts;
@property(strong)NSMutableArray *groups;
@property(assign)int contactsCount;
-(NSMutableDictionary *)sortByContactFirstLetter;
-(NSMutableDictionary *)sortByDepartment;
+(void)favContact:(DDUserEntity *)user;
+(NSArray *)getFavContact;
-(BOOL)isInFavContactList:(DDUserEntity *)user;
+(void)getDepartmentData:(void(^)(id response))block;
-(void)initContactsData:(void(^)(bool isOk))block;
@end
