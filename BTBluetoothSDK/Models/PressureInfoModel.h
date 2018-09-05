//
//  PressureInfoModel.h
//  PostpartumRehabilitation
//
//  Created by user on 2018/7/5.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
 负压信息
 */

#import <Foundation/Foundation.h>
#import "BTCommandDefine.h"


@interface PressureInfoModel : NSObject

@property(nonatomic, assign)Parameter_Pressure_Mode_Value mode;         //模式
@property(nonatomic, assign)Parameter_Pressure_Strength_Value strength;     //强度
@property(nonatomic, assign)NSInteger runningTime;          //运行时间
@property(nonatomic, assign)Parameter_Pressure_Timer_Symbol timeSymbol;     //计时标志
@property(nonatomic, assign)Parameter_Pressure_Running_Status status;       //运行状态


@end
