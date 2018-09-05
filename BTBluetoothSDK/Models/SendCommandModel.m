//
//  SendCommandModel.m
//  PostpartumRehabilitation
//
//  Created by user on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//

#import "SendCommandModel.h"


@interface SendCommandModel()
///重试定时器，1s调用一次，调用3次
@property(nonatomic)dispatch_source_t retryTimer;
///重试次数，初始化为0
@property(nonatomic, assign)NSInteger retryCount;


 ///启动定时器
-(void)startTimer;



@end

@implementation SendCommandModel

/**
 初始化方法：初始化一个新指令
 参数1:指令枚举类型
 参数2:指令获得的参数
 参数3:指令字符串格式
 参数4:指令二进制格式
 参数5:指令优先级
 参数6:指令成功的回调
 参数7:指令失败的回调
 参数8:是否需要回复
 */
-(instancetype)initWithEnumFormat:(CommandType)type parameters:(NSDictionary *)parameters stringFormat:(NSString *)string dataFormat:(NSData *)data priority:(CommandPriority)priority success:(CommandSuccessBlock)success failure:(CommandFailureBlock)failure response:(BOOL)response
{
    if (self = [super initWithEnumFormat:type stringFormat:string dataFormat:data success:success failure:failure])
    {
        _parameters = parameters;
        _priority = priority;
        _needResponse = response;
    }
    return self;
}

/**
 初始化方法：初始化一个重试指令对象
 */
-(instancetype)initWithEnumFormat:(CommandType)type parameters:(NSDictionary *)parameters stringFormat:(NSString *)string dataFormat:(NSData *)data priority:(CommandPriority)priority response:(BOOL)noResponse
{
    if (self = [super initWithEnumFormat:type stringFormat:string dataFormat:data success:nil failure:nil])
    {
        _parameters = parameters;
        _priority = priority;
        _needResponse = noResponse;
    }
    return self;
}

/**
 启动指令倒计时
 */
-(void)startTimerWithRetry:(CommandRetryBlock)retry retryFailure:(CommandRetryFailureBlock)retryFailure
{
    _retry = retry;
    _retryFailure = retryFailure;
    [self startTimer];
}

/**
 启动定时器
 */
-(void)startTimer
{
    if (!_retryTimer)
    {
        self.retryCount = 0;
        __weak typeof(self) weak = self;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        _retryTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, (uint64_t)(RETRY_TIME_INTERVAL * NSEC_PER_SEC));
        uint64_t interval = (uint64_t)(RETRY_TIME_INTERVAL * NSEC_PER_SEC);
        dispatch_source_set_timer(_retryTimer, startTime, interval, 0);
        dispatch_source_set_event_handler(_retryTimer, ^{
            if (weak.retryCount < MAX_RETRY_COUNT)
            {
                NSLog(@"重试%ld次：%@", (long)weak.retryCount, self.commandStringFormat);
                    //执行一次重试代码
                SendCommandModel *m = [[SendCommandModel alloc] initWithEnumFormat:weak.commandEnumFormat parameters:weak.parameters stringFormat:weak.commandStringFormat dataFormat:weak.commandDataFormat priority:weak.priority response:NO];
                weak.retry(weak.commandEnumFormat, m);
                weak.retryCount++;
            }
            else
            {
                NSLog(@"超时:%@", self.commandStringFormat);
                    //如果超时，那么执行超时的block
                [weak stopTimer];
                BTError *error = [[BTError alloc] initWithDomain:NSCocoaErrorDomain code:BTCommandStatus_TimeoutError userInfo:@{NSLocalizedDescriptionKey: BTCommandStatusTimeoutError, NSLocalizedFailureReasonErrorKey: BTCommandStatusTimeoutError}];
                weak.failure(weak.commandEnumFormat, error);        //超时后也要回调给指令发送者
                weak.retryFailure(weak.commandEnumFormat, error);
            }
        });
        dispatch_resume(_retryTimer);
    }
}

/**
 结束定时器
 */
-(void)stopTimer
{
    if (_retryTimer)
    {
        dispatch_source_cancel(_retryTimer);
        _retryTimer = nil;
    }
}

/**
 匹配接收到的指令，如果和属性中的枚举类型匹配，那么取消3次重试定时器，说明这个指令获得了回复
 返回值：参数bool，true为匹配成功，false为匹配失败
 */
-(BOOL)confirmReceivedCommand:(BaseCommandModel *)receivedCommand
{
    if (receivedCommand.commandEnumFormat == self.commandEnumFormat)        //匹配成功
    {
        //停止定时器
        [self stopTimer];
        return YES;
    }
    return NO;
}







@end
