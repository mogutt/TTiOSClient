//
//  DataOutputStream+Addition.h
//  Duoduo
//
//  Created by 独嘉 on 14-5-6.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDDataOutputStream.h"

@interface DDDataOutputStream (Addition)
-(void)writeTcpProtocolHeader:(int16_t)sId cId:(int16_t)cId seqNo:(uint16_t)seqNo;
@end
