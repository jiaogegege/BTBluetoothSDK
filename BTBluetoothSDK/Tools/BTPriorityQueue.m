//
//  BTPriorityQueue.m
//  PostpartumRehabilitation
//
//  Created by user on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//

#import "BTPriorityQueue.h"
#import "BTCommandDefine.h"
#import "SendCommandModel.h"


@interface BTPriorityQueue()
@property(nonatomic, strong, readonly)NSMutableArray *highPriorityQueue;      //高优先级队列
@property(nonatomic, strong, readonly)NSMutableArray *defaultPriorityQueue;           //默认队列
@property(nonatomic, strong, readonly)NSMutableArray *lowPriorityQueue;       //低优先级队列


@end

@implementation BTPriorityQueue

-(instancetype)init
{
    if (self = [super init])
    {
        _lowPriorityQueue = [NSMutableArray array];
        _highPriorityQueue = [NSMutableArray array];
        _defaultPriorityQueue = [NSMutableArray array];
    }
    return self;
}

    ///追加一个元素到容器尾部，容器中最多存在相同指令对象3个
-(void)push:(id)obj
{
    if ([obj isKindOfClass:[SendCommandModel class]])
    {
        SendCommandModel *m = (SendCommandModel *)obj;
        switch (m.priority)
        {
            case CommandPriorityHigh:
            {
                BOOL exist = NO;
                int count = 0;
                for (SendCommandModel *mm in _highPriorityQueue)
                {
                    if (m.commandEnumFormat == mm.commandEnumFormat)    //如果数组中已经存在，那么不添加
                    {
                        exist = YES;
                        count++;
                    }
                }
                if (count < 3)
                {
                    [_highPriorityQueue addObject:m];
                }
                break;
            }
            case CommandPriorityDefault:
            {
                BOOL exist = NO;
                int count = 0;
                for (SendCommandModel *mm in _defaultPriorityQueue)
                {
                    if (m.commandEnumFormat == mm.commandEnumFormat)    //如果数组中已经存在，那么不添加
                    {
                        exist = YES;
                        count++;
                    }
                }
                if (count < 3)
                {
                    [_defaultPriorityQueue addObject:m];
                }
                break;
            }
            case CommandPriorityLow:
            {
                BOOL exist = NO;
                int count = 0;
                for (SendCommandModel *mm in _lowPriorityQueue)
                {
                    if (m.commandEnumFormat == mm.commandEnumFormat)    //如果数组中已经存在，那么不添加
                    {
                        exist = YES;
                        count++;
                    }
                }
                if (count < 3)
                {
                    [_lowPriorityQueue addObject:m];
                }
                break;
            }
            default:
            {
                [super push:m];
                break;
            }
        }
    }
    else
    {
        [super push:obj];
    }
    
}

    ///弹出最前面一个元素，弹出后该元素不再存在容器中，如果没有元素则返回nil
-(id)pop
{
    if (_highPriorityQueue.count > 0)       //高优先级队列
    {
        id obj = [_highPriorityQueue objectAtIndex:0];
        [_highPriorityQueue removeObjectAtIndex:0];
        return obj;
    }
    else if (_defaultPriorityQueue.count > 0)       //默认优先级队列
    {
        id obj = [_defaultPriorityQueue objectAtIndex:0];
        [_defaultPriorityQueue removeObjectAtIndex:0];
        return obj;
    }
    else if (_lowPriorityQueue.count > 0)       //低优先级队列
    {
        id obj = [_lowPriorityQueue objectAtIndex:0];
        [_lowPriorityQueue removeObjectAtIndex:0];
        return obj;
    }
    else if (![super isEmpty])      //取父类的队列
    {
        id obj = [super pop];
        return obj;
    }
    return nil;
}
    ///获得容器最前面的元素，元素还在容器中
-(id)firstObject
{
    if (_highPriorityQueue.count > 0)
    {
        return [_highPriorityQueue firstObject];
    }
    else if (_defaultPriorityQueue.count > 0)
    {
        return [_defaultPriorityQueue firstObject];
    }
    else if (_lowPriorityQueue.count > 0)
    {
        return [_lowPriorityQueue firstObject];
    }
    else if (![super isEmpty])
    {
        return [super firstObject];
    }
    return nil;
}

    ///判断容器是否为空
-(BOOL)isEmpty
{
    if (_highPriorityQueue.count > 0)
    {
        return NO;
    }
    else if (_defaultPriorityQueue.count > 0)
    {
        return NO;
    }
    else if (_lowPriorityQueue.count > 0)
    {
        return NO;
    }
    else
    {
        return [super isEmpty];
    }
}

-(void)clear
{
    [_lowPriorityQueue removeAllObjects];
    [_highPriorityQueue removeAllObjects];
    [_defaultPriorityQueue removeAllObjects];
    [super clear];
}



@end
