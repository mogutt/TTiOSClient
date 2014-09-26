//
//  NSObject+Property.m
//  IOSDuoduo
//
//  Created by 东邪 on 14-5-23.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "NSObject+Property.h"

@implementation DDTypeEncoding
DEF_INT( UNKNOWN,	0 )
DEF_INT( NSNUMBER,	1 )
DEF_INT( INT,       2 )
DEF_INT( LONG,      3 )
DEF_INT( FLOAT,     4 )
DEF_INT( NSSTRING,	5 )
DEF_INT( NSDATE,	6 )
+ (NSUInteger)typeOf:(const char *)attr
{
	if ( attr[0] != 'T' )
		return DDTypeEncoding.UNKNOWN;
	
	const char * type = &attr[1];
	if ( type[0] == '@' )
	{
		if ( type[1] != '"' )
			return DDTypeEncoding.UNKNOWN;
		
		char typeClazz[64] = { 0 };
		
		const char * clazz = &type[2];
		const char * clazzEnd = strchr( clazz, '"' );
		
		if ( clazzEnd && clazz != clazzEnd )
		{
			unsigned int size = (unsigned int)(clazzEnd - clazz);
			strncpy( &typeClazz[0], clazz, size );
		}
		
		if ( 0 == strcmp((const char *)typeClazz, "NSNumber") )
		{
			return DDTypeEncoding.NSNUMBER;
		}
		else if ( 0 == strcmp((const char *)typeClazz, "NSString") )
		{
			return DDTypeEncoding.NSSTRING;
		}
		else if ( 0 == strcmp((const char *)typeClazz, "NSDate") )
		{
			return DDTypeEncoding.NSDATE;
		}
	}
	else
	{
		if ( type[0] == 'c' || type[0] == 'C' )
		{
			return DDTypeEncoding.UNKNOWN;
		}
		else if ( type[0] == 'i' || type[0] == 'I'  )
		{
			return DDTypeEncoding.INT;
		}
		else if ( type[0] == 'l' || type[0] == 'L' )
		{
			return DDTypeEncoding.LONG;
		}
		else if ( type[0] == 'f' )
		{
			return DDTypeEncoding.FLOAT;
		}
		else if ( type[0] == 'd' )
		{
			return DDTypeEncoding.FLOAT;
		}
		else if ( type[0] == 'B' )
		{
			return DDTypeEncoding.UNKNOWN;
		}
		else if ( type[0] == 'v' )
		{
			return DDTypeEncoding.UNKNOWN;
		}
		else if ( type[0] == '*' )
		{
			return DDTypeEncoding.UNKNOWN;
		}
		else if ( type[0] == ':' )
		{
			return DDTypeEncoding.UNKNOWN;
		}
		else if ( 0 == strcmp(type, "bnum") )
		{
			return DDTypeEncoding.UNKNOWN;
		}
		else if ( type[0] == '^' )
		{
			return DDTypeEncoding.UNKNOWN;
		}
		else if ( type[0] == '?' )
		{
			return DDTypeEncoding.UNKNOWN;
		}
		else
		{
			return DDTypeEncoding.UNKNOWN;
		}
	}
	
	return DDTypeEncoding.UNKNOWN;
}
@end
@implementation NSObject (Property)

- (NSArray *)getPropertyList{
    return [self getPropertyList:[self class]];
}

- (NSArray *)getPropertyList: (Class)clazz
{
    NSMutableArray *propertyArray = [NSMutableArray array];

    Class cla = clazz;
    while (cla != [NSObject class]) {
        u_int count;
        objc_property_t *properties  = class_copyPropertyList(cla, &count);
        
        for (int i = 0; i < count ; i++)
        {
            const char* propertyName = property_getName(properties[i]);
            
            [propertyArray addObject: [NSString  stringWithUTF8String: propertyName]];
        }
        free(properties);
        cla = class_getSuperclass(cla);
    }
    
    return propertyArray;
}
- (NSArray *)getAttributeList{
    return [self getAttributeList:[self class]];
}
- (NSArray *)getAttributeList: (Class)clazz
{
    u_int count;
    objc_property_t *properties  = class_copyPropertyList(clazz, &count);
    NSMutableArray *attributeArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getAttributes(properties[i]);
        
        [attributeArray addObject: [NSString  stringWithUTF8String: propertyName]];
    }
    
    free(properties);
    
    return attributeArray;
}
-(NSDictionary *)getPropertyNameAndType{
    return  [self  getPropertyNameAndType:[self class]];
}
-(NSDictionary *)getPropertyNameAndType: (Class)clazz{
    u_int count;
    objc_property_t *properties  = class_copyPropertyList(clazz, &count);
    NSMutableDictionary *attributeArray = [NSMutableDictionary dictionaryWithCapacity:count];
    
    for (int i = 0; i < count ; i++)
    {
        const char* attr = property_getAttributes(properties[i]);
        const char* propertyName = property_getName(properties[i]);
        [attributeArray setValue: [NSNumber numberWithInt: [DDTypeEncoding typeOf:attr]] forKey:[NSString  stringWithUTF8String: propertyName]];
        //        [attributeArray addObject: [NSString  stringWithUTF8String: propertyName]];
    }
    
    free(properties);
    
    return attributeArray;
}
- (NSDictionary *)convertDictionary{
    NSArray *properties=[self getPropertyList];
    if (![properties isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSMutableDictionary *dic=[NSMutableDictionary new];
    for ( NSString *propertyName in properties) {
        id value =[self valueForKey:propertyName];
        if ([value isKindOfClass:[NSDate class]]) {
            value = [NSString stringWithFormat:@"%f", [value timeIntervalSince1970]];
        }
        if ([propertyName isEqualToString:@"hashString"]) {
            NSLog(@"error");
        }
        [dic setValue:value  forKey:propertyName];
    }
    return dic;
}
- (id)initWithDictionary:(NSDictionary *)dict{
    self = [self init];
    if(self)
        [self dictionaryForObject:dict];
    return self;
    
}
- (NSString *)className{
    return NSStringFromClass([self class]);
}

- (BOOL)checkPropertyName:(NSString *)name {
    unsigned int propCount, i;
    objc_property_t* properties = class_copyPropertyList([self class], &propCount);
    for (i = 0; i < propCount; i++) {
        objc_property_t prop = properties[i];
        const char *propName = property_getName(prop);
        if(propName) {
            NSString *_name = [NSString stringWithCString:propName encoding:NSUTF8StringEncoding];
            if ([name isEqualToString:_name]) {
                return YES;
            }
        }
    }
    return NO;
}


- (void)dictionaryForObject:(NSDictionary*) dict{
    for (NSString *key in [dict allKeys]) {
        id value = [dict objectForKey:key];
        
        if (value==[NSNull null] || value == nil || value == 0) {
            continue;
        }
        if ([value isKindOfClass:[NSDictionary class]]) {
            id subObj = [self valueForKey:key];
            if (subObj)
                [subObj dictionaryForObject:value];
        }
        else{
            @try {
                [self setValue:value forKeyPath:key];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }
            @finally {
                
            }
            
        }
    }
}
- (void)decodeFromDictionary:(NSDictionary *)dic{
    NSArray *properties=[self getPropertyList];
    for (NSString *propertyName in properties) {
        id value =[dic objectForKey:propertyName];
        if (value==nil) {
            continue;
        }
        [self setValue:value forKey:propertyName];
    }
}

@end


