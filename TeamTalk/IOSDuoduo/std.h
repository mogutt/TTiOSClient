//
//  std.h
//  IOSDuoduo
//
//  Created by 东邪 on 14-5-23.
//  Copyright (c) 2014年 dujia. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "XLog.h"
#import "MD5.h"


#define objectOrNull(obj) ((obj) ? (obj) : [NSNull null])
#define objectOrEmptyStr(obj) ((obj) ? (obj) : @"")

#define isNull(x)             (!x || [x isKindOfClass:[NSNull class]])
#define toInt(x)              (isNull(x) ? 0 : [x intValue])
#define isEmptyString(x)      (isNull(x) || [x isEqual:@""] || [x isEqual:@"(null)"])

#define sleep(s);             [NSThread sleepForTimeInterval:s];
#define Syn(x)                @synthesize x = _##x

#define RGBA(r,g,b,a)         [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define RGB(r,g,b)            [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define BoldSystemFont(size)  [UIFont boldSystemFontOfSize:size]
#define systemFont(size)      [UIFont systemFontOfSize:size]
#define beginAutoPool         NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init]; {
#define endAutoPool           } [pool release];
#define skipspace(c)          while (isspace(*c)) ++c
#define skipUntil(c,x)        while (x != *c) ++c
#define TheWindowHeight      ([UIDevice isAfterOS7] ? [UIScreen mainScreen].bounds.size.height : ([UIScreen mainScreen].bounds.size.height - 20))
#define IntToNumber(int)        ([NSNumber numberWithInt:int])
#define isIOS7 [[UIDevice currentDevice].systemVersion doubleValue]>=7.0?YES:NO
#define SYSTEM_VERSION        [[[UIDevice currentDevice] systemVersion] floatValue]
#define STATUSBAR_HEIGHT      [[UIApplication sharedApplication] statusBarFrame].size.height
#define NAVBAR_HEIGHT         (44.f + ((SYSTEM_VERSION >= 7) ? STATUSBAR_HEIGHT : 0))
#define FULL_WIDTH            SCREEN_WIDTH
#define FULL_HEIGHT           (SCREEN_HEIGHT - ((SYSTEM_VERSION >= 7) ? 0 : STATUSBAR_HEIGHT))
#define CONTENT_HEIGHT        (FULL_HEIGHT - NAVBAR_HEIGHT)
// 屏幕高度
#define SCREEN_HEIGHT         [[UIScreen mainScreen] bounds].size.height

// 屏幕宽度
#define SCREEN_WIDTH          [[UIScreen mainScreen] bounds].size.width
#define PhotosMessageDir ([[NSString documentPath] stringByAppendingPathComponent:@"/PhotosMessageDir/"])
#define IPHONE4 ( [ [ UIScreen mainScreen ] bounds ].size.height == 480 )
//字体颜色
#define GRAYCOLOR RGB(137, 139, 144)



#define FileManager     ([NSFileManager defaultManager])
#define TheUserDefaults ([NSUserDefaults standardUserDefaults])
#define VoiceMessageDir ([[NSString documentPath] stringByAppendingPathComponent:@"/VoiceMessageDir/"])
#define BlacklistDir ([[NSString documentPath] stringByAppendingPathComponent:@"/BlacklistDir/"])
#define Departmentlist ([[NSString documentPath] stringByAppendingPathComponent:@"/department.plist"])
#define fixedlist ([[NSString documentPath] stringByAppendingPathComponent:@"/fixed.plist"])
#define shieldinglist ([[NSString documentPath] stringByAppendingPathComponent:@"/shieldingArray.plist"])
#define TheBundleVerison (bundleVerison())
#undef	AS_SINGLETON
#define AS_SINGLETON( __class ) \
+ (__class *)sharedInstance;

#undef	DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
+ (__class *)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
return __singleton__; \
}

@protocol DDShareObjDelegate <NSObject>

- (NSString*)shareTypeName;

@end
char pinyinFirstLetter(unsigned short hanzi);
char getFirstChar(const NSString * str);
