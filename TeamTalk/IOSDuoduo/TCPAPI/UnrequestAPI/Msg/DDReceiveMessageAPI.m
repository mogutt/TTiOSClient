//
//  DDReceiveMessageAPI.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-6-5.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDReceiveMessageAPI.h"
#import "DDMessageEntity.h"
#import "Encapsulator.h"
#import "DDMessageModule.h"
@implementation DDReceiveMessageAPI
- (int)responseServiceID
{
    return DDSERVICE_MESSAGE;
}

- (int)responseCommandID
{
    return DDCMD_MSG_DATA;
}

- (UnrequestAPIAnalysis)unrequestAnalysis
{
    UnrequestAPIAnalysis analysis = (id)^(NSData *data)
    {
        DDDataInputStream* bodyData = [DDDataInputStream dataInputStreamWithData:data];
        UInt32 seqNo = [bodyData readInt];
        NSString *fromUserId = [bodyData readUTF];
        NSString *toUserId = [bodyData readUTF];
        UInt32 msgTime = [bodyData readInt];
        UInt8 msgType = [bodyData readChar];
       // UInt8 msgRenderType = [bodyData readChar];
        NSString* messageContent = nil;
        NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
        
        if (msgType == DDMessageTypeText || msgType == DDGroup_Message_TypeText ) {
            messageContent = [bodyData readUTF];
        }else if (msgType == DDMessageTypeVoice || msgType == DDGroup_MessageTypeVoice)
        {
            
            int32_t dataLength = [bodyData readInt];
            NSData* data = [bodyData readDataWithLength:dataLength];
            NSData* voiceData = [data subdataWithRange:NSMakeRange(4, [data length] - 4)];
            NSString* filename = [NSString stringWithString:[Encapsulator defaultFileName]];
            if ([voiceData writeToFile:filename atomically:YES])
            {
                messageContent = filename;
            }
            
            NSData* voiceLengthData = [data subdataWithRange:NSMakeRange(0, 4)];
            
            int8_t ch1;
            [voiceLengthData getBytes:&ch1 range:NSMakeRange(0,1)];
            ch1 = ch1 & 0x0ff;
            
            int8_t ch2;
            [voiceLengthData getBytes:&ch2 range:NSMakeRange(1,1)];
            ch2 = ch2 & 0x0ff;
            
            int32_t ch3;
            [voiceLengthData getBytes:&ch3 range:NSMakeRange(2,1)];
            ch3 = ch3 & 0x0ff;
            
            int32_t ch4;
            [voiceLengthData getBytes:&ch4 range:NSMakeRange(3,1)];
            ch4 = ch4 & 0x0ff;
            
            if ((ch1 | ch2 | ch3 | ch4) < 0){
                @throw [NSException exceptionWithName:@"Exception" reason:@"EOFException" userInfo:nil];
            }
            int voiceLength = ((ch1 << 24) + (ch2 << 16) + (ch3 << 8) + (ch4 << 0));
            [info setObject:@(voiceLength) forKey:VOICE_LENGTH];
            [info setObject:@(0) forKey:DDVOICE_PLAYED];
        }
        else if(msgType == DDMessageTypeImage)
        {
            messageContent = [bodyData readUTF];
            if ([messageContent hasPrefix:DD_MESSAGE_IMAGE_PREFIX])
            {
                msgType = DDMessageTypeImage;
            }
            

        }
        
        DDMessageEntity *msg = nil;
        if (msgType == 0)
        {
             return @[msg,@(seqNo)];
        }
        else
        {
            NSString *attach = [bodyData readUTF];
            
            NSUInteger messageID = [DDMessageModule getMessageID];
            msg = [[DDMessageEntity alloc ] initWithMsgID:messageID msgType:msgType msgTime:msgTime sessionID:fromUserId senderID:fromUserId msgContent:messageContent toUserID:toUserId];
            [msg setInfo:info];
            return @[msg,@(seqNo)];
        }
    };
    return analysis;
}
@end
