//
//  BTTaskDispatcher.m
//  PostpartumRehabilitation
//
//  Created by user on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//

#import "BTTaskDispatcher.h"
#import "BTCommandContainer.h"
#import "BTCommandBuilder.h"
#import "BTUtility.h"
#import "BTDataParser.h"
#import "BTLogRecorder.h"


@interface BTTaskDispatcher()<BTDataParserDelegate>
{
    BOOL _canSend;      //是否可以发送指令
    BOOL _canReceive;       //是否可以处理接收指令
    BTManagerWorkMode _workMode;        //工作模式
    dispatch_queue_t _sendQueue;       //发送指令线程
    dispatch_queue_t _receivedQueue;        //接收处理指令线程
}
    //指令和数据容器
@property(nonatomic, strong)BTCommandContainer *container;
//指令构造器
@property(nonatomic, strong)BTCommandBuilder *builder;
//指令解析器
@property(nonatomic, strong)BTDataParser *parser;
//指令并发信号量
@property(nonatomic, strong)dispatch_semaphore_t semaphore;
@property(nonatomic, assign)NSInteger semaphoreCount;           //使用了的信号量个数
@property(nonatomic, strong)NSRecursiveLock *semaphoreLock;     //用于控制访问`semaphoreCount`变量的锁
//锁
@property(nonatomic, strong)NSRecursiveLock *sendLock;      //发送指令的锁
@property(nonatomic, strong)NSRecursiveLock *receiveLock;       //接收指令的锁
@property(nonatomic, strong)NSRecursiveLock *sendedLock;        //已发送指令的锁


    ///开始发送线程
-(void)startSendingCommandThread;
    ///结束发送线程
-(void)stopSendingCommandThread;

    ///开始接收线程
-(void)startReceivedCommandThread;
    ///结束接收线程
-(void)stopReceivedCommandThread;


@end

@implementation BTTaskDispatcher

static BTTaskDispatcher *_dispatcher = nil;
    ///单例类方法
+(BTTaskDispatcher *)dispatcher
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dispatcher = [[BTTaskDispatcher alloc] init];
    });
    return _dispatcher;
}

///初始化方法
-(instancetype)init
{
    if (self = [super init])
    {
        _container = [BTCommandContainer container];
        _builder = [BTCommandBuilder builder];
        _parser = [BTDataParser parser];
        _parser.delegate = self;
        _canSend = NO;
        _canReceive = NO;
        _workMode = BTManagerWorkModeActive;
        _semaphore = dispatch_semaphore_create(MAX_COMMAND_CONCURRENCY);
        _semaphoreCount = 0;
        _semaphoreLock = [[NSRecursiveLock alloc] init];
        _sendLock = [[NSRecursiveLock alloc] init];
        _receiveLock = [[NSRecursiveLock alloc] init];
        _sendedLock = [[NSRecursiveLock alloc] init];
        
    }
    return self;
}

    ///设置工作模式，前台或后台
-(void)setWorkMode:(BTManagerWorkMode)mode
{
    _workMode = mode;
    switch (mode) {
        case BTManagerWorkModeActive:       //前台
        {
            
            break;
        }
        case BTManagerWorkModeSilent:       //后台
        {
            
            break;
        }
        default:
            break;
    }
}

    ///发送一条指令，调用指令构造器
-(void)sendCommand:(CommandType)commandType parameters:(NSDictionary *)parameters success:(CommandSuccessBlock)success failure:(CommandFailureBlock)failure
{
    SendCommandModel *sendCommand = [_builder buildSendCommand:commandType parameters:parameters success:success failure:failure];
    if (sendCommand)
    {
        [_sendLock lock];
        [_container pushSendCommand:sendCommand];
        [_sendLock unlock];
    }
}

    ///接收到返回数据，调用指令构造器
-(void)receivedData:(NSData *)data
{
//    NSLog(@"dispatcher接收到数据:%@", data);
    ReceivedCommandModel *receivedCommand = [_builder buildReceivedCommand:data];
    if (receivedCommand)
    {
        //判断在前台还是后台，在前台，那么进入容器中
        if (_workMode == BTManagerWorkModeActive)
        {
            if (receivedCommand.receivedType != ReceivedCommandTypeNone)      //如果接收指令不是设备主动发起的异常信息，那么进入队列
            {
                    //加锁
                [_receiveLock lock];
                [_container pushReceivedCommand:receivedCommand];
                [_receiveLock unlock];
            }
        }
        else    //在后台那么直接解析，在后台主动传过来的数据只有异常信息
        {
            [_parser parseReceivedCommand:receivedCommand];
        }
    }
}

    ///开始发送线程
-(void)startSendingCommandThread
{
    if (_canSend == NO || _sendQueue == nil)        //如果发送线程为空也需要重新开启线程
    {
        _canSend = YES;
        __weak typeof(self) weak = self;
        _sendQueue = dispatch_queue_create("send_command", DISPATCH_QUEUE_SERIAL);
        dispatch_async(_sendQueue, ^{
            @autoreleasepool {
                [weak sendingCommandThread];
            }
        });
    }
}

///真正的发送指令线程
-(void)sendingCommandThread
{
    while (_canSend)
    {
        @autoreleasepool {
                //在循环中不停地取容器中的发送指令对象
            [_sendLock lock];
            SendCommandModel *sendCommand = [_container popSendCommand];
            [_sendLock unlock];
            if (sendCommand)
            {
                [self semaphoreUse];
                if (_canSend)   //如果发送标志符为true，那么可以进行接下来的处理，否则不处理
                {
                    if (_delegate)
                    {       //将指令发送给BTManager进行处理
                        if ([_delegate conformsToProtocol:@protocol(BTTaskDispatcherDelegate)] && [_delegate respondsToSelector:@selector(taskDispatcherWantSendCommand:)])
                        {
                            [_delegate taskDispatcherWantSendCommand:sendCommand];      //dispatcher发送了指令
                            [[BTLogRecorder recorder] logSendCommandData:sendCommand.commandDataFormat];
                        }
                    }
                        //如果指令需要回复，那么启动重试定时器并加入已发送队列
                    if (sendCommand.needResponse)
                    {
                            //启动发送指令的重试定时器
                        [sendCommand startTimerWithRetry:^(CommandType commandType, SendCommandModel *retryCommand) {
                                //重试block
                            if (self->_delegate)
                            {
                                if ([self->_delegate conformsToProtocol:@protocol(BTTaskDispatcherDelegate)] && [self->_delegate respondsToSelector:@selector(taskDispatcherWantSendCommand:)])
                                {
                                    [self->_delegate taskDispatcherWantSendCommand:retryCommand];
                                }
                            }
                        } retryFailure:^(CommandType commandType, BTError *error) {
                                //重试失败block，也就是通信超时
                            [[BTLogRecorder recorder] logExceptionInfo:[NSString stringWithFormat:@"超时: %lx %@", (long)commandType, error.localizedDescription]];
                            if (self->_delegate)
                            {
                                if ([self->_delegate conformsToProtocol:@protocol(BTTaskDispatcherDelegate)] && [self->_delegate respondsToSelector:@selector(taskDispatcherDidCatchCommunicationTimeout:commandType:)])
                                {
                                    [self -> _delegate taskDispatcherDidCatchCommunicationTimeout:error commandType:commandType];
                                }
                            }
                        }];
                            //将发送指令放到已发送指令队列中
                        [_sendedLock lock];
                        [_container pushSendedCommand:sendCommand];
                        [_sendedLock unlock];
                    }
                }
                else
                {
                    //如果不能运行，那么清理容器并重置信号量
                    [self semaphoreFree];
                    [_container clearAll];
                }
            }
            sendCommand = nil;
        }
            //发送完一个指令后，休息10~100ms
        [NSThread sleepForTimeInterval:TIME_INTERVAL_FOR_SEND_COMMAND];
    }
    NSLog(@"发送线程退出");
    _sendQueue = nil;
}

    ///结束发送线程
-(void)stopSendingCommandThread
{
    _canSend = NO;
    [_container clearSendQueue];
}

    ///开始接收线程
-(void)startReceivedCommandThread
{
    if (_canReceive == NO || _receivedQueue == nil)
    {
        _canReceive = YES;
        __weak typeof(self) weak = self;
        _receivedQueue = dispatch_queue_create("received_command", DISPATCH_QUEUE_SERIAL);
        dispatch_async(_receivedQueue, ^{
            @autoreleasepool {
                [weak receivedCommandThread];
            }
        });
    }
}

///真正的开始处理接收指令线程
-(void)receivedCommandThread
{
    while (_canReceive)
    {
        @autoreleasepool {
                //在循环中不停地取容器中的接收指令对象
            [_receiveLock lock];
            ReceivedCommandModel *receivedCommand = [_container popReceivedCommand];
//            NSLog(@"-----------------receiver-------------------");
            [_receiveLock unlock];

            if (receivedCommand)
            {
                    ///log
                if (![receivedCommand.commandStringFormat hasPrefix:@"02"] && ![receivedCommand.commandStringFormat hasPrefix:@"03"] && ![receivedCommand.commandStringFormat hasPrefix:@"0d"] && ![receivedCommand.commandStringFormat hasPrefix:@"1a"])
                {
                    NSLog(@"dispatcher处理数据:%@", receivedCommand.commandDataFormat);
                }
                [[BTLogRecorder recorder] logReceivedCommandData:receivedCommand.commandDataFormat];
                //是否匹配到了已发送指令
                BOOL isOK = NO;
                //取到数据后，去已发送队列匹配发送指令，每次匹配数据都将容器的指针移动到最前面，保证从头开始匹配
                [_container resetSended];
                [_sendedLock lock];
//                NSLog(@"dispatcher开始处理数据:%@", receivedCommand.commandDataFormat);
                while ([_container nextSendedCommand])      //如果还没有到容器边界，那么一直取数据，如果返回nil，那么容器中没有数据了
                {
                    SendCommandModel *send = _container.currentSended;
                    if ([send confirmReceivedCommand:receivedCommand])        //指令类型匹配，那么弹出这个已发送指令
                    {
                            //获取回调block
                        BOOL result = [receivedCommand getCallbackCommand:send];
                        if (!result)
                        {
                            NSLog(@"从已发送指令中获取回调方法失败，请检查");
                        }
                        BOOL ret = [_container deleteSendedCommand:send];
                        if (!ret)
                        {
                            NSLog(@"已发送指令不在容器中");
                        }
                        isOK = YES;
                            //解析指令对象
                        [_parser parseReceivedCommand:receivedCommand];
                        
                            //发出信号量，可以继续发送指令，只有匹配到了指令才发送信号量，因为如果指令是从app中发出，那么一定会接收到返回信息，如果没有匹配到已发送指令，说明是设备主动发过来的，不需要释放信号量
                        [self semaphoreFree];
                        break;      //匹配到之后一定要退出循环，防止把后面发送的指令也匹配到了
                    }
                    send = nil;
                }
                [_sendedLock unlock];
                    //循环结束之后应该做点什么，是否需要对没有匹配到的指令做额外处理
                if (isOK == NO)
                {
                        //没有匹配到指令的默认处理，如果是异常报警指令，判断是否有异常，如果有异常，那么处理异常
                    [_parser parseReceivedCommand:receivedCommand];
                }
//                NSLog(@"dispatcher处理完数据：%@", receivedCommand.commandDataFormat);
            }
            receivedCommand = nil;
        }
        [NSThread sleepForTimeInterval:TIME_INTERVAL_FOR_RECEIVE_COMMAND];
    }
    NSLog(@"接收线程退出");
    _receivedQueue = nil;
}

///使用一个信号量
-(void)semaphoreUse
{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_semaphoreLock lock];
    _semaphoreCount++;      //如果使用了一个信号量，那么使用量标记+1
    [_semaphoreLock unlock];
}

///释放一个信号量
-(void)semaphoreFree
{
    dispatch_semaphore_signal(_semaphore);
    [_semaphoreLock lock];
    _semaphoreCount--;
    [_semaphoreLock unlock];
}

    ///结束接收线程，不在处理接收数据，所以要清空接收队列和已发送队列
-(void)stopReceivedCommandThread
{
    _canReceive = NO;
    [_container clearSendedQueue];
    [_container clearReceivedQueue];
}

    ///开始工作，一般在连接上设备之后，主管理器发送开始工作命令，这个方法将执行上面的两个开启线程方法
-(void)startWorking
{
    [_container clearAll];
    [self startSendingCommandThread];
    [self startReceivedCommandThread];
}
    ///结束工作，一般在断开设备连接后，停止所有的发送接收任务，这个方法将执行上面的两个结束线程方法
-(void)stopWorking
{
    [self stopSendingCommandThread];
    [self stopReceivedCommandThread];
    //将所有信号量重置
    NSInteger count = _semaphoreCount;
    for (int i = 0; i < count; ++i)
    {
        [self semaphoreFree];
    }
    [_container clearAll];
}



#pragma mark 代理方法
///解析到了异常信息
-(void)dataParserDidCatchException:(BTException *)exception
{
//    [_container clearSendQueue];    //清空发送队列，不能有新的指令被发送；保持已发送队列和接收队列的数据
    //告知主管理器出现了异常
    [[BTLogRecorder recorder] logExceptionInfo:[NSString stringWithFormat:@"异常: %lx %@", (long)exception.code, exception.reason]];
    if (_delegate)
    {
        if ([_delegate conformsToProtocol:@protocol(BTTaskDispatcherDelegate)] && [_delegate respondsToSelector:@selector(taskDispatcherDidFoundException:)])
        {
            __weak typeof(self) weak = self;
            [BTUtility asyncPerformActionOnGlobalThread:^{
                [weak.delegate taskDispatcherDidFoundException:exception];
            }];
        }
    }
        //清空容器，但是不能停止工作，两个轮询线程依然在运行，为了处理恢复后的指令
//    [_container clearSendQueue];
}



@end
