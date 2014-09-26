//
//  NSObject+Property.h
//  IOSDuoduo
//
//  Created by 东邪 on 14-5-23.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <objc/runtime.h>
#import <Foundation/Foundation.h>
//#import "FMResultSet.h"
#undef	AS_STATIC_PROPERTY_INT
#define AS_STATIC_PROPERTY_INT( __name ) \
@property (nonatomic, readonly) NSInteger __name; \
+ (NSInteger)__name;

#undef	DEF_STATIC_PROPERTY_INT
#define DEF_STATIC_PROPERTY_INT( __name, __value ) \
@dynamic __name; \
+ (NSInteger)__name \
{ \
return __value; \
}

#undef	AS_INT
#define AS_INT	AS_STATIC_PROPERTY_INT

#undef	DEF_INT
#define DEF_INT	DEF_STATIC_PROPERTY_INT

@interface DDTypeEncoding :NSObject
AS_INT( UNKNOWN )
AS_INT( NSNUMBER )
AS_INT( INT )
AS_INT( LONG)
AS_INT( FLOAT )
AS_INT( NSSTRING )
AS_INT( NSDATE )
+ (NSUInteger)typeOf:(const char *)attr;
@end

@interface NSObject (Property)
- (NSArray *)getAttributeList;
- (NSArray *)getPropertyList;
- (NSArray *)getPropertyList: (Class)clazz;
- (NSDictionary *)convertDictionary;
- (void)dictionaryForObject:(NSDictionary*) dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSString *)className;
- (void)decodeFromDictionary:(NSDictionary *)dic;
- (NSDictionary *)getPropertyNameAndType;
@end