//
//  BTPeripheralModel.m
//  PostpartumRehabilitation
//
//  Created by user on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//

#import "BTPeripheralModel.h"

@implementation BTPeripheralModel

    ///初始化方法
-(instancetype)initWithID:(NSString *)identifier name:(NSString *)name
{
    if (self = [super init])
    {
        self.identifier = identifier;
        self.name = name;
    }
    return self;
}





@end
