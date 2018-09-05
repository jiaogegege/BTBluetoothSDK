//
//  BTDataParser.h
//  PostpartumRehabilitation
//
//  Created by 蒋雪姣 on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
 指令数据解析器
 1.用于解析蓝牙返回的数据
 2.解析成功后，调用指令对象相应的block（success/failure），并传入解析后的数据。
 3.如果指令状态码不正确，说明发生了错误，交给异常处理器解析出错误信息并返回一个错误对象
 4.如果解析到了异常信息，那么调用代理方法将异常信息传出去
 **/
 
#import <Foundation/Foundation.h>



@class ReceivedCommandModel;
@class BTException;

@protocol BTDataParserDelegate<NSObject>
@required
///解析到了异常信息
-(void)dataParserDidCatchException:(BTException *)exception;


@end

@interface BTDataParser : NSObject

@property(nonatomic, weak)id<BTDataParserDelegate> delegate;

    ///单例类方法
+(BTDataParser *)parser;

///解析一个接收到的指令对象
-(void)parseReceivedCommand:(ReceivedCommandModel *)receivedCommand;



@end
