//
//  BTLogRecorder.h
//  PostpartumRehabilitation
//
//  Created by 蒋雪姣 on 2018/8/21.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
* Log记录器
* 记录SDK运行中的log，包括：
    (1)发送接收指令，`指令时间/指令数据`
    (2)
 * 单例模式
 */

#import <Foundation/Foundation.h>

@interface BTLogRecorder : NSObject

@property(nonatomic, assign)BOOL logEnabled;        //是否需要记录log


///单例类方法
+(BTLogRecorder *)recorder;

///记录一条指令数据，发送指令或接收指令；包括：发送接收时间/类型/二进制数据
-(void)logSendCommandData:(NSData *)data;
-(void)logReceivedCommandData:(NSData *)data;

///记录错误信息，包括：超时/指令错误/异常
-(void)logExceptionInfo:(NSString *)str;








@end
