//
//  DDSuperAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-24.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDSuperAPI.h"
#import "DDAPISchedule.h"
//#import "DDSeqNoManager.h"

static uint16_t theSeqNo = 0;

@implementation DDSuperAPI
- (void)requestWithObject:(id)object Completion:(RequestCompletion)completion
{
    //seqNo
    theSeqNo ++;
    
    if ([(id<DDAPIScheduleProtocol>)self requestServiceID] == DDSERVICE_FRI && [(id<DDAPIScheduleProtocol>)self requestCommendID] == DDCMD_FRI_USER_SERVICE_REQ)
    {
        _seqNo = 0;
    }
    else
    {
        _seqNo = theSeqNo;
    }
    
    //注册接口
    BOOL registerAPI = [[DDAPISchedule instance] registerApi:(id<DDAPIScheduleProtocol>)self];
    
    if (!registerAPI)
    {
        return;
    }
    
    //注册请求超时
    if ([(id<DDAPIScheduleProtocol>)self requestTimeOutTimeInterval] > 0)
    {
        [[DDAPISchedule instance] registerTimeoutApi:(id<DDAPIScheduleProtocol>)self];
    }
    
    //保存完成块
    self.completion = completion;

    
    //数据打包
    Package package = [(id<DDAPIScheduleProtocol>)self packageRequestObject];
    NSMutableData* requestData = package(object,_seqNo);
    
    //发送
    if (requestData)
    {
        [[DDAPISchedule instance] sendData:requestData];
//        [[DDTcpClientManager instance] writeToSocket:requestData];
    }
}

@end
