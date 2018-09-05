//
//  BigNumberInfoModel.h
//  PostpartumRehabilitation
//
//  Created by user on 2018/6/25.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
电刺激初始化时候大编号的信息
 */

#import <Foundation/Foundation.h>
#import "BTCommandDefine.h"


@interface BigNumberInfoModel : NSObject

@property(nonatomic, assign)Parameter_Channel_Value channel;        //通道信息
@property(nonatomic, copy)NSString *planNumber;         //方案编号
@property(nonatomic, strong)NSArray *bigNumberArray;        //大编号列表


@end
