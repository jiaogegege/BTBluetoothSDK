//
//  SendCommandModel.h
//  PostpartumRehabilitation
//
//  Created by 蒋雪姣 on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
 发送出去的指令对象
 **/

#import "BaseCommandModel.h"
#import "BTConstDefine.h"


@class SendCommandModel;

/**
 重试的回调，3次重试的回调会传入新复制的发送指令对象，这个对象仅用于重试发送指令，不保存到已发送队列中，没有任何回调，这个对象希望直接被发送出去，该block在启动定时器时由任务派发器赋值
 */
typedef void(^CommandRetryBlock)(CommandType commandType, SendCommandModel *retryCommand);

/**
 3次重试失败后的回调，一般是告知外部代码重试失败，然后断开蓝牙连接，该block在启动定时器时被赋值
 参数1:指令类型
 参数2:指令错误信息，固定为通信超时错误
 */
typedef void(^CommandRetryFailureBlock)(CommandType commandType, BTError *error);


/**属性和方法定义*/

@interface SendCommandModel : BaseCommandModel

/**
 指令获得的参数
 */
@property(nonatomic, strong, readonly)NSDictionary *parameters;
/**
 指令的优先级
 */
@property(nonatomic, assign, readonly)CommandPriority priority;
/**
 指令是否需要回复，如果需要回复，那么要被放到已发送队列中等待回应并执行相应的block；如果不需要回应，说明是重试指令，发送后直接丢弃
 */
@property(nonatomic, assign, readonly)BOOL needResponse;

/**
 重试的block
 */
@property(nonatomic, copy, readonly)CommandRetryBlock retry;
/**
 3次重试失败的block
 */
@property(nonatomic, copy, readonly)CommandRetryFailureBlock retryFailure;


/**
 初始化方法：初始化一个新指令对象
 参数1:指令枚举类型
 参数2:指令获得的参数
 参数3:指令字符串格式
 参数4:指令二进制格式
 参数5:指令优先级
 参数6:指令成功的回调
 参数7:指令失败的回调
 参数8:是否需要回复
 */
-(instancetype)initWithEnumFormat:(CommandType)type parameters:(NSDictionary *)parameters stringFormat:(NSString *)string dataFormat:(NSData *)data priority:(CommandPriority)priority success:(CommandSuccessBlock)success failure:(CommandFailureBlock)failure response:(BOOL)response;

/**
 初始化方法：初始化一个重试指令对象
 参数1:指令类型
 参数2:指令获得的参数
 参数3:指令字符串类型
 参数4:指令二进制格式
 参数5:指令优先级
 参数6:指令是否需要回复，一般传NO
 */
-(instancetype)initWithEnumFormat:(CommandType)type parameters:(NSDictionary *)parameters stringFormat:(NSString *)string dataFormat:(NSData *)data priority:(CommandPriority)priority response:(BOOL)noResponse;

/**
 启动指令倒计时
 */
-(void)startTimerWithRetry:(CommandRetryBlock)retry retryFailure:(CommandRetryFailureBlock)retryFailure;

/**
 结束定时器，外部也有调用的需要
 */
-(void)stopTimer;

/**
 匹配接收到的指令，如果和属性中的枚举类型匹配，那么取消3次重试定时器，说明这个指令获得了回复
 返回值：参数bool，true为匹配成功
 */
-(BOOL)confirmReceivedCommand:(BaseCommandModel *)receivedCommand;



@end
