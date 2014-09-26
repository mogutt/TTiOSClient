//
//  DDEmotionsModule.m
//  Mogujie4iPhone
//
//  Created by 独嘉 on 14-6-23.
//  Copyright (c) 2014年 juangua. All rights reserved.
//

#import "EmotionsModule.h"

@implementation EmotionsModule
{
//    NSDictionary* _emotionUnicodeDic;
//    NSDictionary* _unicodeEmotionDic;
//    NSArray* _emotions;
}

+ (instancetype)shareInstance
{
    static EmotionsModule* g_emotionsModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_emotionsModule = [[EmotionsModule alloc] init];
    });
    return g_emotionsModule;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _emotionUnicodeDic = @{@"[嘻嘻]":@"\U0001F601",
                               @"[偷笑]":@"\U0001F604",
                               @"[哈哈]":@"\U0001F606",
                               @"[呵呵]":@"\U0001F60A",
                               @"[馋嘴]":@"\U0001F60B",
                               @"[花心]":@"\U0001F60D",
                               @"[酷]":@"\U0001F60E",
                               @"[做鬼脸]":@"\U0001F60F",
                               @"[汗]":@"\U0001F611",
                               @"[困]":@"\U0001F613",
                               @"[生病]":@"\U0001F616",
                               @"[亲亲]":@"\U0001F618",
                               @"[右哼哼]":@"\U0001F617",
                               @"[闭嘴]":@"\U0001F620",
                               @"[怒]":@"\U0001F621",
                               @"[哼]":@"\U0001F624",
                               @"[失望]":@"\U0001F627",
                               @"[吃惊]":@"\U0001F62E",
                               @"[睡觉]":@"\U0001F634",
                               @"[泪]":@"\U0001F62D",
                               @"[抓狂]":@"\U0001F631", 
                               @"[晕]":@"\U0001F632", 
                               @"[嘘]":@"\U0001F636",
                               @"[感冒]":@"\U0001F637",
                               @"[挤眼]":@"\U0000263A",
                               @"[阴险]":@"\U0001F47F",
                               @"[热吻]":@"\U0001F48B",
                               @"[心]":@"\U00002764",
                               @"[ok]":@"\U0001F44C",
                               @"[不要]":@"\U0000261D",
                               @"[弱]":@"\U0001F44E",
                               @"[good]":@"\U0001F44D",
                               @"[拳头]":@"\U0000270A",
                               @"[耶]":@"\U0000270C",
                               @"[0]":@"0️⃣",
                               @"[1]":@"1️⃣",
                               @"[2]":@"2️⃣",
                               @"[3]":@"3️⃣",
                               @"[4]":@"4️⃣",
                               @"[5]":@"5️⃣",
                               @"[6]":@"6️⃣",
                               @"[7]":@"7️⃣",
                               @"[8]":@"8️⃣",
                               @"[9]":@"9️⃣"
                               };
        _unicodeEmotionDic = [[NSMutableDictionary alloc] init];
        [_emotionUnicodeDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [_unicodeEmotionDic setValue:key forKey:obj];
        }];
        
        _emotions = @[@"\U0001F601",
                      @"\U0001F604",
                      @"\U0001F606",
                      @"\U0001F60A",
                      @"\U0001F60B",
                      @"\U0001F60D",
                      @"\U0001F60E",
                      @"\U0001F60F",
                      @"\U0001F611",
                      @"\U0001F613",
                      @"\U0001F616",
                      @"\U0001F618",
                      @"\U0001F617",
                      @"\U0001F620",
                      @"\U0001F621",
                      @"\U0001F624",
                      @"\U0001F627",
                      @"\U0001F62E",
                      @"\U0001F634",
                      @"\U0001F62D",
                      @"\U0001F631", 
                      @"\U0001F632", 
                      @"\U0001F636",
                      @"\U0001F637",
                      @"\U0000263A",
                      @"\U0001F47F",
                      @"\U0001F48B",
                      @"\U00002764",
                      @"\U0001F44C",
                      @"\U0000261D",
                      @"\U0001F44E",
                      @"\U0001F44D",
                      @"\U0000270A",
                      @"\U0000270C",
                      @"0️⃣",
                      @"1️⃣",
                      @"2️⃣",
                      @"3️⃣",
                      @"4️⃣",
                      @"5️⃣",
                      @"6️⃣",
                      @"7️⃣",
                      @"8️⃣",
                      @"9️⃣"];
        
        _emotionLength = [[NSMutableDictionary alloc] init];
        [_emotions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_emotionLength setValue:@([obj length]) forKeyPath:obj];
        }];
    }
    return self;
}
@end
