//
//  DataOutputStream+Addition.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-6.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DataOutputStream+Addition.h"
#import "NSStream+NSStreamAddition.h"
@implementation DDDataOutputStream (Addition)
-(void)writeTcpProtocolHeader:(int16_t)sId cId:(int16_t)cId seqNo:(uint16_t)seqNo
{
    [self writeShort:sId];
    [self writeShort:cId];
    [self writeShort:IM_PDU_VERSION];
    [self writeShort:seqNo]; //默认值
}
@end
