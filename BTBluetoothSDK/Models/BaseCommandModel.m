//
//  BaseCommandModel.m
//  PostpartumRehabilitation
//
//  Created by user on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//

#import "BaseCommandModel.h"


@implementation BaseCommandModel

/**
 初始化方法，初始化一个新的指令对象
 参数1:指令枚举类型
 参数2:指令字符串类型
 参数3:指令二进制格式
 参数4:成功的回调
 参数5:失败的回调
 */
-(instancetype)initWithEnumFormat:(CommandType)type stringFormat:(NSString *)string dataFormat:(NSData *)data success:(CommandSuccessBlock)success failure:(CommandFailureBlock)failure
{
    if (self = [super init])
    {
        _commandEnumFormat = type;
        _commandStringFormat = string;
        _commandDataFormat = data;
        _success = success;
        _failure = failure;
    }
    return self;
}

/**
 单独给block赋值
 */
-(void)getCallback:(CommandSuccessBlock)success failure:(CommandFailureBlock)failure
{
    _success = success;
    _failure = failure;
}



@end
