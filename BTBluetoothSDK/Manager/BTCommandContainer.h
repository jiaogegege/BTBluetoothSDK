//
//  BTCommandContainer.h
//  PostpartumRehabilitation
//
//  Created by 蒋雪姣 on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
 指令和数据容器
 1.所有的发送指令和接收指令都存放在这个地方
 2.任务调度器开启发送和接收指令的线程，从容器中存储和读取指令和数据
 3.提供发送指令队列，其中的指令有优先级，优先级高的指令先出队列
 4.提供接收指令队列，接收到的指令放在这里，先进先出
 5.提供已发送指令队列，已发送的指令放在这里，用于等待指令返回结果
 6.只提供指令和数据的存储和删除，不参与任何数据的操作和解析工作
 **/

#import <Foundation/Foundation.h>
#import "SendCommandModel.h"
#import "ReceivedCommandModel.h"


@interface BTCommandContainer : NSObject

@property(nonatomic, strong, readonly)SendCommandModel *currentSended;        //当前取出的已发送指令对象，让线程调度器来读取

///单例类方法
+(BTCommandContainer *)container;

///添加一个待发送指令
-(void)pushSendCommand:(SendCommandModel *)sendCommand;

///取出一个待发送指令，取出后，容器中不再存在
-(SendCommandModel *)popSendCommand;

///添加一个接收指令对象
-(void)pushReceivedCommand:(ReceivedCommandModel *)receivedCommand;

///取出一个接收指令对象，取出后，容器中不再存在
-(ReceivedCommandModel *)popReceivedCommand;

///添加一个已发送指令对象
-(void)pushSendedCommand:(SendCommandModel *)sendedCommand;

///获得已发送队列元素数量
-(NSInteger)getSendedCount;

///重置index到最前面，每次开始一次新命令的匹配都需要重置一下，直到返回nil
-(void)resetSended;

///获得已发送队列的下一个元素，元素还在容器中
-(SendCommandModel *)nextSendedCommand;

///删除已发送队列的某个元素，元素不在容器中
-(BOOL)deleteSendedCommand:(SendCommandModel *)sendedCommand;

///清空发送队列
-(void)clearSendQueue;
///清空接收队列
-(void)clearReceivedQueue;
///清空已发送队列
-(void)clearSendedQueue;
///清空所有数据
-(void)clearAll;






@end
