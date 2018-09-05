//
//  BTExceptionProcessor.h
//  PostpartumRehabilitation
//
//  Created by 蒋雪姣 on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
 异常处理器
 1.解析轮询中发现的异常信息，并返回一个异常对象
 2.解析指令中发生的错误，并返回一个错误对象
 **/

#import <Foundation/Foundation.h>
#import "BTCommandDefine.h"


@class BTException;
@class BTError;

@interface BTExceptionProcessor : NSObject

///单例类方法
+(BTExceptionProcessor *)processor;

///解析指令错误
-(BTError *)processorCommandError:(Byte)errorByte;

///解析异常信息
-(BTException *)processorExceptionInfo:(NSString *)exceptionStr;

    ///获得异常的等级，类方法，给外部调用
+(BTExceptionSeverityRank)getExceptionSeverityRank:(BTCommandException)exception;



@end
