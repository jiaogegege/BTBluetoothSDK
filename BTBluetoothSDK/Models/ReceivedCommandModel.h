//
//  ReceivedCommandModel.h
//  PostpartumRehabilitation
//
//  Created by 蒋雪姣 on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
 接收到的指令对象
 **/


#import "BaseCommandModel.h"

@interface ReceivedCommandModel : BaseCommandModel

/**
 指令类型，标明该指令的具体类型，比如：数据指令/控制指令/设备主动发起的指令/等待回复的指令
 */
@property(nonatomic, assign, readonly)ReceivedCommandType receivedType;


/**
 初始化方法，初始化一个接收指令对象
 */
-(instancetype)initWithEnumFormat:(CommandType)type stringFormat:(NSString *)string dataFormat:(NSData *)data receivedType:(ReceivedCommandType)receivedType success:(CommandSuccessBlock)success failure:(CommandFailureBlock)failure;

/**
 获得回调block的方法
 返回值：true，赋值成功；false，赋值失败
 */
-(BOOL)getCallbackCommand:(BaseCommandModel *)sendCommand;





@end
