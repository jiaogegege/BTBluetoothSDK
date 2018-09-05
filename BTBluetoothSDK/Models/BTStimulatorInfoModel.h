//
//  BTStimulatorInfoModel.h
//  PostpartumRehabilitation
//
//  Created by user on 2018/6/25.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
 电刺激信息
 */

#import <Foundation/Foundation.h>
#import "BTCommandDefine.h"
#import "BTConstDefine.h"


@interface BTStimulatorInfoModel : NSObject

@property(nonatomic, assign)BTStimulatorStatus channelAStimStatus;      //A通道电刺激状态
@property(nonatomic, copy)NSString *channelAPlanNumber;         //A通道方案编号
@property(nonatomic, assign)BOOL channelAEnabled;           //A通道是否可以调节电流
@property(nonatomic, copy)NSString *channelASmallNumber;            //A通道手法小编号
@property(nonatomic, assign)NSInteger channelAElectric;         //A通道电流强度
@property(nonatomic, assign)NSInteger channelATime;        //A通道运行时间

@property(nonatomic, assign)BTStimulatorStatus channelBStimStatus;      //B通道电刺激状态
@property(nonatomic, copy)NSString *channelBPlanNumber;         //B通道方案编号
@property(nonatomic, assign)BOOL channelBEnabled;           //B通道是否可以调节电流
@property(nonatomic, copy)NSString *channelBSmallNumber;            //B通道手法小编号
@property(nonatomic, assign)NSInteger channelBElectric;         //B通道电流强度
@property(nonatomic, assign)NSInteger channelBTime;        //B通道运行时间


@end
