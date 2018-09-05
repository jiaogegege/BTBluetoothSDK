//
//  BTCommandContainer.m
//  PostpartumRehabilitation
//
//  Created by user on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//

#import "BTCommandContainer.h"
#import "BTPriorityQueue.h"
#import "BTVector.h"


@interface BTCommandContainer()
@property(nonatomic, strong)BTPriorityQueue *sendQueue;      //准备发送指令对象队列，优先级队列
@property(nonatomic, strong)BTQueue *receivedQueue;          //接收指令队列
@property(nonatomic, strong)BTVector *sendedVector;           //已发送指令队列


@end

@implementation BTCommandContainer

static BTCommandContainer *_container = nil;
    ///单例类方法
+(BTCommandContainer *)container
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _container = [[BTCommandContainer alloc] init];
    });
    return _container;
}

///初始化方法
-(instancetype)init
{
    if (self = [super init])
    {
        _sendQueue = [[BTPriorityQueue alloc] init];
        _receivedQueue = [[BTQueue alloc] init];
        _sendedVector = [[BTVector alloc] init];
    }
    return self;
}

    ///添加一个待发送指令
-(void)pushSendCommand:(SendCommandModel *)sendCommand
{
    [_sendQueue push:sendCommand];
}

    ///取出一个待发送指令，取出后，容器中不再存在
-(SendCommandModel *)popSendCommand
{
    return [_sendQueue pop];
}

    ///添加一个接收指令对象
-(void)pushReceivedCommand:(ReceivedCommandModel *)receivedCommand
{
    [_receivedQueue push:receivedCommand];
}

    ///取出一个接收指令对象，取出后，容器中不再存在
-(ReceivedCommandModel *)popReceivedCommand
{
    return [_receivedQueue pop];
}

    ///添加一个已发送指令对象
-(void)pushSendedCommand:(SendCommandModel *)sendedCommand
{
    [_sendedVector pushBack:sendedCommand];
}

    ///获得已发送队列元素数量
-(NSInteger)getSendedCount
{
    return [_sendedVector count];
}

    ///重置index到最前面，每次开始一次新命令的匹配都需要重置一下，直到返回nil
-(void)resetSended
{
    [_sendedVector moveToFront];
}

    ///获得已发送队列的下一个元素，元素还在容器中
-(SendCommandModel *)nextSendedCommand
{
    _currentSended = [_sendedVector next];
    return _currentSended;
}

    ///删除已发送队列的某个元素，元素不在容器中
-(BOOL)deleteSendedCommand:(SendCommandModel *)sendedCommand
{
    return [_sendedVector pop:sendedCommand];
}

    ///清空发送队列
-(void)clearSendQueue
{
    [_sendQueue clear];
}
    ///清空接收队列
-(void)clearReceivedQueue
{
    [_receivedQueue clear];
}
    ///清空已发送队列
-(void)clearSendedQueue
{
    [_sendedVector moveToFront];
    NSInteger count = [_sendedVector count];
    for (int i = 0; i < count; i++) //停止所有计时器
    {
        SendCommandModel *sendedModel = (SendCommandModel *)[_sendedVector objectAtIndex:i];
        [sendedModel stopTimer];
    }
    [_sendedVector clear];
}

    ///清空所有数据
-(void)clearAll
{
    [self clearSendQueue];
    [self clearSendedQueue];
    [self clearReceivedQueue];
}





@end
