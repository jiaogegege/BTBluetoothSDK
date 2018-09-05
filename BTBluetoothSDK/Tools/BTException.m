//
//  BTException.m
//  PostpartumRehabilitation
//
//  Created by user on 2018/5/31.
//  Copyright © 2018年 dyimedical. All rights reserved.
//

#import "BTException.h"

@implementation BTException

/**初始化方法*/
-(instancetype)initWithName:(NSExceptionName)aName code:(BTCommandException)code rank:(BTExceptionSeverityRank)rank reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    if (self = [super initWithName:aName reason:aReason userInfo:aUserInfo])
    {
        _code = code;
        _rank = rank;
    }
    return self;
}


@end
