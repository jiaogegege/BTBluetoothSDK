//
//  ReceivedCommandModel.m
//  PostpartumRehabilitation
//
//  Created by user on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//

#import "ReceivedCommandModel.h"


@implementation ReceivedCommandModel


/**
 初始化方法，初始化一个接收指令对象
 */
-(instancetype)initWithEnumFormat:(CommandType)type stringFormat:(NSString *)string dataFormat:(NSData *)data receivedType:(ReceivedCommandType)receivedType success:(CommandSuccessBlock)success failure:(CommandFailureBlock)failure
{
    if (self = [super initWithEnumFormat:type stringFormat:string dataFormat:data success:success failure:failure])
    {
        _receivedType = receivedType;
    }
    return self;
}







/**
 获得回调block的方法
 */
-(BOOL)getCallbackCommand:(BaseCommandModel *)sendCommand
{
    BOOL ret = NO;
    if (sendCommand.commandEnumFormat == self.commandEnumFormat)
    {
        [self getCallback:sendCommand.success failure:sendCommand.failure];
        ret = YES;
    }
    return ret;
}




@end
