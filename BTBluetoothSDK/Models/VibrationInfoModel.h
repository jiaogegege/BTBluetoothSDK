//
//  VibrationInfoModel.h
//  PostpartumRehabilitation
//
//  Created by user on 2018/6/26.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
 振动信息
 */

#import <Foundation/Foundation.h>
#import "BTCommandDefine.h"


@interface VibrationInfoModel : NSObject

@property(nonatomic, assign)Parameter_Vibartion_Mode_Setting_Value vibrationMode;       //振动模式
@property(nonatomic, assign)Parameter_Vibartion_Intensity_Setting_Value vibrationIntensity;         //振动强度
@property(nonatomic, assign)NSInteger vibrationTime;            //振动运行时间,秒
@property(nonatomic, assign)Parameter_Vibartion_Timer_Symbol timeSymbol;     //计时标志
@property(nonatomic, assign)Parameter_Vibartion_Running_Status status;      //运行状态


@end
