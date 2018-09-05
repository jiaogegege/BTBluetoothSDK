//
//  BaseCommandModel.h
//  PostpartumRehabilitation
//
//  Created by 蒋雪姣 on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
 指令对象基础
 1.定义指令对象的一些通用属性和方法
 **/

#import <Foundation/Foundation.h>
#import "BTCommandDefine.h"
#import "BTError.h"
#import "BTConstDefine.h"


#pragma - mark 指令回调类型定义
/**
 指令返回成功的回调
 参数1:指令类型
 参数2:传给回调对象的数据，一般指令成功的话，object为true，附带上一些信息，比如设备信息、电极信息、状态查询数据等；还会返回异常信息
 可用参数key：
 "Command_Status"：1成功，0有异常
 "Command_objValue"：数据对象，如果有的话
 "Command_Error"：异常对象
 */
typedef void(^CommandSuccessBlock)(CommandType commandType, NSDictionary *object);

/**
 指令失败的回调
 参数1:指令类型
 参数2:指令回调的数据，一般为错误对象
 参数2:错误信息。如果接收指令中有任何错误码出现，那么调用失败的回调
 */
typedef void(^CommandFailureBlock)(CommandType commandType, BTError *error);



#pragma - mark 指令基础类型定义
@interface BaseCommandModel : NSObject

/**
 指令枚举类型
 */
@property(nonatomic, assign, readonly)CommandType commandEnumFormat;
/**
 指令字符串格式，包含完整的指令格式，16进制字符串格式
 */
@property(nonatomic, copy, readonly)NSString *commandStringFormat;
/**
 指令二进制格式，包含完整的指令格式Byte数组
 */
@property(nonatomic, strong, readonly)NSData *commandDataFormat;
/**
 指令成功的回调
 */
@property(nonatomic, copy, readonly)CommandSuccessBlock success;
/**
 指令失败的回调
 */
@property(nonatomic, copy, readonly)CommandFailureBlock failure;



/**
 初始化方法，初始化一个新的指令对象
 参数1:指令枚举类型
 参数2:指令字符串类型
 参数3:指令二进制格式
 参数4:成功的回调
 参数5:失败的回调
 */
-(instancetype)initWithEnumFormat:(CommandType)type stringFormat:(NSString *)string dataFormat:(NSData *)data success:(CommandSuccessBlock)success failure:(CommandFailureBlock)failure;

/**
 单独给block赋值
 */
-(void)getCallback:(CommandSuccessBlock)success failure:(CommandFailureBlock)failure;



@end
