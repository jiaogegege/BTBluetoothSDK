//
//  BTTaskDispatcher.h
//  PostpartumRehabilitation
//
//  Created by 蒋雪姣 on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
 任务调度器，主要管理各个线程的任务调度
 1.发送指令线程，从外部程序发送的指令进入任务调度器进行指令对象生成，指令进入派遣容器，从派遣容器中按规则读取指令并发送给中心管理器
 2.接收指令线程，从容器中读取接收到的指令对象，匹配已发送队列中的指令对象，匹配到后就删除这个已发送指令，并将接收指令进行解析
 3.待发送指令通过这个被放到容器中
 4.接收到的指令通过这里被放入容器中
 **/

#import <Foundation/Foundation.h>
#import "BTCommandDefine.h"
#import "BTException.h"
#import "BTError.h"
#import "SendCommandModel.h"
#import "ReceivedCommandModel.h"


/**
 * 代理协议，提供以下功能：
 * 1.告知主管理器是否发生了异常
 
 */
@protocol BTTaskDispatcherDelegate <NSObject>
@required
///调度器想要发送一条指令
-(void)taskDispatcherWantSendCommand:(SendCommandModel *)sendCommand;

///通信超时，返回发生超时的指令对象
-(void)taskDispatcherDidCatchCommunicationTimeout:(BTError *)error commandType:(CommandType)type;

///发生了异常，通知主管理器；同时，清空容器；但是，发送接收的线程还在工作，因为要提供异常恢复后的验证解析服务
///主管理器应该停止轮询操作并告知外部程序出现了异常，外部程序应该提供一种异常处理机制
-(void)taskDispatcherDidFoundException:(BTException *)exception;

@optional
///发生了指令错误，如果解析到了错误指令，通知感兴趣的代理对象，DEPRECATED_ATTRIBUTE
-(void)taskDispatcherDidFoundCommandError:(BTError *)error commandType:(CommandType)commandType;


@end


@interface BTTaskDispatcher : NSObject

///代理对象
@property(nonatomic, weak)id <BTTaskDispatcherDelegate> delegate;


///单例类方法
+(BTTaskDispatcher *)dispatcher;

///设置工作模式，前台或后台
-(void)setWorkMode:(BTManagerWorkMode)mode;

///发送一条指令，调用指令构造器
-(void)sendCommand:(CommandType)commandType parameters:(NSDictionary *)parameters success:(CommandSuccessBlock)success failure:(CommandFailureBlock)failure;

///接收到返回数据，调用指令构造器
-(void)receivedData:(NSData *)data;

///开始工作，一般在连接上设备之后，主管理器发送开始工作命令，这个方法将执行上面的两个开启线程方法
-(void)startWorking;
///结束工作，一般在断开设备连接后，停止所有的发送接收任务，这个方法将执行上面的两个结束线程方法
-(void)stopWorking;







@end
