//
//  BTDeviceModel.h
//  PostpartumRehabilitation
//
//  Created by 蒋雪姣 on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//

#import "BTPeripheralModel.h"
#import "BTConstDefine.h"
#import "BTCommandDefine.h"


/**
 蓝牙设备对象，包括设备id、设备名称、设备电量、设备型号等信息
 **/

@interface BTDeviceModel : BTPeripheralModel<NSCopying, NSMutableCopying>

@property(nonatomic, copy)NSString *battery;        //电量
@property(nonatomic, copy)NSString *model;      //型号
@property(nonatomic, copy)NSString *color;      //颜色
@property(nonatomic, assign)BTDeviceState state;        //连接状态
@property(nonatomic, copy)NSString *uuid;            //序列号
@property(nonatomic, copy)NSString *productDate;        //生产日期
@property(nonatomic, copy)NSString *softwareVersion;        //软件版本
@property(nonatomic, copy)NSString *hardwareVersion;        //硬件版本
@property(nonatomic, copy)NSString *releaseVersion;         //发布版本

//电极相关
@property(nonatomic, assign)BTElectrodeType channelAType;       //通道A类型
@property(nonatomic, assign)BTElectrodeType channelBType;           //通道B类型
@property(nonatomic, assign)BTStimulatorStatus channelAStatus;      //通道A电刺激状态
@property(nonatomic, assign)BTStimulatorStatus channelBStatus;      //通道B电刺激状态

@property(nonatomic, assign)BTDeviceWorkStatus workStatus;      //工作状态
@property(nonatomic, assign)BTDeviceWorkMode workMode;      //运行模式


///从父类创建一个子类
+(BTDeviceModel *)deviceFromPeripheral:(BTPeripheralModel *)peripheral;

///从一个对象实例中获取数据
-(void)getDataFromInstance:(BTDeviceModel *)model;



@end
