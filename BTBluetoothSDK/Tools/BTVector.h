//
//  BTVector.h
//  PostpartumRehabilitation
//
//  Created by 蒋雪姣 on 2018/6/20.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
 向量容器：序列存储
 1.可以返回头尾元素，有一个指针可以移动用来操作容器中的元素
 2.在头尾都可添加元素，一般在尾部添加
 */

#import <Foundation/Foundation.h>

@interface BTVector : NSObject

///在头部添加一个元素
-(void)pushFront:(id)obj;

///在尾部添加一个元素
-(void)pushBack:(id)obj;

///返回头部元素，元素还在容器中，不存在返回nil
-(id)firstObject;

///返回尾部元素，元素还在容器中，不存在返回nil
-(id)lastObject;

///返回index的元素，元素还在容器中
-(id)objectAtIndex:(NSInteger)index;

///弹出头部元素，元素不在容器中
-(id)popFirst;

///弹出尾部元素，元素不在容器中
-(id)popLast;

///弹出index的某个元素，元素不在容器中，如果index的元素不存在，返回nil
-(id)popAtIndex:(NSInteger)index;

///弹出某个元素，返回YES，元素不在容器中，如果元素不存在容器中，返回NO
-(BOOL)pop:(id)obj;

///获得下一个元素，元素还在容器中，如果index超过容器最大范围或容器为空，返回nil，并自动返回容器头部，返回当前index成功后index再+1
-(id)next;

///重置指针为容器头部元素，index为0
-(void)moveToFront;

///获得元素在容器中的index，不存在返回-1
-(NSInteger)indexOfObject:(id)obj;

///判断容器是否为空
-(BOOL)isEmpty;

///获得元素个数
-(NSInteger)count;

///清空容器
-(void)clear;




@end
