//
//  BTQueue.m
//  PostpartumRehabilitation
//
//  Created by user on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//

#import "BTQueue.h"
#import "BTConstDefine.h"


@interface BTQueue()
    ///默认队列
@property(nonatomic, strong, readonly)NSMutableArray *queue;

@end

@implementation BTQueue

-(instancetype)init
{
    if (self = [super init])
    {
        _queue = [NSMutableArray array];
    }
    return self;
}

    ///追加一个元素到容器尾部
-(void)push:(id)obj
{
    if (obj)
    {
        [_queue addObject:obj];
    }
    
}

    ///弹出最前面一个元素，弹出后该元素不再存在容器中，如果没有元素则返回nil
-(id)pop
{
    if (![self isEmpty])
    {
        id obj = [_queue objectAtIndex:0];
        [_queue removeObjectAtIndex:0];
        return obj;
    }
    return nil;
}

    ///获得容器最前面的元素，元素还在容器中
-(id)firstObject
{
    if (![self isEmpty])
    {
        return [_queue firstObject];
    }
    return nil;
}

    ///判断容器是否为空
-(BOOL)isEmpty
{
    if (_queue.count > 0)
    {
        return NO;
    }
    return YES;
}

    ///清空容器
-(void)clear
{
    [_queue removeAllObjects];
}


@end
