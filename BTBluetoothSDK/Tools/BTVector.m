//
//  BTVector.m
//  PostpartumRehabilitation
//
//  Created by user on 2018/6/20.
//  Copyright © 2018年 dyimedical. All rights reserved.
//

#import "BTVector.h"


@interface BTVector()
@property(nonatomic, strong)NSMutableArray *vector;
@property(nonatomic, assign)NSInteger currentIndex;

@end

@implementation BTVector

///初始化方法
-(instancetype)init
{
    if (self = [super init])
    {
        _vector = [NSMutableArray array];
        _currentIndex = 0;
    }
    return self;
}

    ///在头部添加一个元素
-(void)pushFront:(id)obj
{
    if (obj)
    {
        [_vector insertObject:obj atIndex:0];
    }
}

    ///在尾部添加一个元素
-(void)pushBack:(id)obj
{
    if (obj)
    {
        [_vector addObject:obj];
    }
}

    ///返回头部元素，元素还在容器中，不存在返回nil
-(id)firstObject
{
    if (![self isEmpty])
    {
        return [_vector firstObject];
    }
    return nil;
}

    ///返回尾部元素，元素还在容器中
-(id)lastObject
{
    if (![self isEmpty])
    {
        return [_vector lastObject];
    }
    return nil;
}

    ///返回index的元素，元素还在容器中
-(id)objectAtIndex:(NSInteger)index
{
    if (![self isEmpty] && index < _vector.count)
    {
        return [_vector objectAtIndex:index];
    }
    return nil;
}

    ///弹出头部元素，元素不在容器中
-(id)popFirst
{
    if (![self isEmpty])
    {
        id obj = [_vector firstObject];
        [_vector removeObjectAtIndex:0];
        return obj;
    }
    return nil;
}

    ///弹出尾部元素，元素不在容器中
-(id)popLast
{
    if (![self isEmpty])
    {
        id obj = [_vector lastObject];
        [_vector removeLastObject];
        return obj;
    }
    return nil;
}

    ///弹出index的某个元素，元素不在容器中，如果index的元素不存在，返回nil
-(id)popAtIndex:(NSInteger)index
{
    if (![self isEmpty] && index < _vector.count)
    {
        id obj = [_vector objectAtIndex:index];
        [_vector removeObjectAtIndex:index];
        return obj;
    }
    return nil;
}

    ///弹出某个元素，元素不在容器中，如果元素不存在容器中，返回NO
-(BOOL)pop:(id)obj
{
    if (![self isEmpty])
    {
        if ([_vector containsObject:obj])
        {
            [_vector removeObject:obj];
            return YES;
        }
    }
    return NO;
}

    ///获得下一个元素，元素还在容器中，如果index超过容器最大范围或容器为空，返回nil，并自动返回容器头部，返回当前index成功后index再+1
-(id)next
{
    if (_currentIndex < _vector.count && _vector.count > 0)
    {
        return [_vector objectAtIndex:_currentIndex++];
    }
    //重置指针到头部
    [self moveToFront];
    return nil;
}

    ///重置指针为容器头部元素，index为0
-(void)moveToFront
{
    _currentIndex = 0;
}

    ///获得元素在容器中的index，不存在返回-1
-(NSInteger)indexOfObject:(id)obj
{
    if (![self isEmpty])
    {
        if ([_vector containsObject:obj])
        {
            return [_vector indexOfObject:obj];
        }
    }
    return -1;
}

    ///判断容器是否为空
-(BOOL)isEmpty
{
    if (_vector.count > 0)
    {
        return NO;
    }
    return YES;
}

    ///获得元素个数
-(NSInteger)count
{
    if (![self isEmpty])
    {
        return _vector.count;
    }
    return 0;
}

    ///清空容器
-(void)clear
{
    [_vector removeAllObjects];
    [self moveToFront];
}




@end
