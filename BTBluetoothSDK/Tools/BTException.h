//
//  BTException.h
//  PostpartumRehabilitation
//
//  Created by 蒋雪姣 on 2018/5/31.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
 异常对象，包含异常等级，异常状态码等
 */

#import <Foundation/Foundation.h>
#import "BTCommandDefine.h"

@interface BTException : NSException

/**
 异常码
 */
@property(nonatomic, assign, readonly)BTCommandException code;
/**
 异常等级
 */
@property(nonatomic, assign, readonly)BTExceptionSeverityRank rank;

/**初始化方法*/
-(instancetype)initWithName:(NSExceptionName)aName code:(BTCommandException)code rank:(BTExceptionSeverityRank)rank reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;


@end
