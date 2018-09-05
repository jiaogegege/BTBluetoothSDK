//
//  BTCommandBuilder.h
//  PostpartumRehabilitation
//
//  Created by 蒋雪姣 on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
 指令构造器
 1.从指令枚举类型中创建发送指令对象
 2.从接收到的指令数据中创建已接收指令对象
 **/

#import <Foundation/Foundation.h>
#import "BTCommandDefine.h"
#import "SendCommandModel.h"
#import "ReceivedCommandModel.h"


@interface BTCommandBuilder : NSObject

/**
 获取单例方法
 */
+(BTCommandBuilder *)builder;

/**
 创建一个发送指令对象
 */
-(SendCommandModel *)buildSendCommand:(CommandType)type parameters:(NSDictionary *)parameters success:(CommandSuccessBlock)success failure:(CommandFailureBlock)failure;

/**
 创建一个接收指令对象
 */
-(ReceivedCommandModel *)buildReceivedCommand:(NSData *)data;







@end
