//
//  BTQueue.h
//  PostpartumRehabilitation
//
//  Created by 蒋雪姣 on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
指令队列
 基础队列，先进先出
 **/

#import <Foundation/Foundation.h>

@interface BTQueue : NSObject

/**容器方法*/
///追加一个元素到容器尾部
-(void)push:(id)obj;

///弹出最前面一个元素，弹出后该元素不再存在容器中，如果没有元素则返回nil
-(id)pop;

///获得容器最前面的元素，元素还在容器中
-(id)firstObject;

///判断容器是否为空
-(BOOL)isEmpty;

///清空容器
-(void)clear;



@end
